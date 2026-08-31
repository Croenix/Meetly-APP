const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
const http = require('http');
const WebSocket = require('ws');
const crypto = require('crypto');
const admin = require('firebase-admin');
const bigQueryService = require('./bigquery_service');

// Initialize Firebase Admin SDK with Resilient Fallbacks
let db;
try {
  const serviceAccountPath = path.join(__dirname, 'service-account.json');
  if (fs.existsSync(serviceAccountPath)) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccountPath),
      databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app'
    });
    db = admin.database();
    console.log("Firebase Admin SDK: Initialized with local service-account.json");
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app'
    });
    db = admin.database();
    console.log("Firebase Admin SDK: Initialized with Application Default Credentials");
  } else {
    admin.initializeApp({
      databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app'
    });
    db = admin.database();
    console.log("Firebase Admin SDK: Initialized without explicit credential (open rules)");
  }
} catch (err) {
  console.warn("Firebase Admin SDK Warning: Fallback to REST fetch for Firebase RTDB sync operations:", err.message);
}

const app = express();
const PORT = process.env.PORT || 5000;
const SHARED_APP_SECRET = 'meetly_secure_secret_2026';

// In-Memory Valid Handshake Session Tokens Store (Token -> Session Info)
const validHandshakeTokens = new Map();

// File databases
const SETTINGS_FILE = path.join(__dirname, 'settings.json');
const CATEGORIES_FILE = path.join(__dirname, 'categories.json');
const PROVIDERS_FILE = path.join(__dirname, 'providers.json');
const BANNERS_FILE = path.join(__dirname, 'banners.json');
const BOOKINGS_FILE = path.join(__dirname, 'bookings.json');
const USERS_FILE = path.join(__dirname, 'users.json');

// Firebase RTDB URL regional endpoints
const FIREBASE_SETTINGS_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/settings.json';
const FIREBASE_SERVER_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/server_url.json';
const FIREBASE_WS_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/ws_url.json';
const FIREBASE_BANNERS_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/banners.json';
const FIREBASE_CATEGORIES_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/categories.json';
const FIREBASE_BOOKINGS_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/bookings.json';
const FIREBASE_PROVIDERS_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/providers.json';
const FIREBASE_USERS_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/users.json';

app.use(cors());
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

// --- SECURE HANDSHAKE ENDPOINT ---
app.post('/api/v1/auth/handshake', (req, res) => {
  const clientSecret = req.headers['x-app-secret'];
  const { userId, deviceId } = req.body;

  if (!clientSecret || clientSecret !== SHARED_APP_SECRET) {
    console.warn(`[Handshake Security Guard] Unauthorized handshake attempt from IP ${req.ip} (Invalid X-App-Secret)`);
    return res.status(401).json({ status: "error", message: "Unauthorized: Invalid application client secret header" });
  }

  if (!userId || !deviceId) {
    return res.status(400).json({ status: "error", message: "BadRequest: Missing userId or deviceId parameter" });
  }

  // Generate cryptographically secure Session Key
  const tokenBytes = crypto.randomBytes(24).toString('hex');
  const sessionKey = `sess_${tokenBytes}`;
  const now = Date.now();

  const tokenPayload = {
    sessionKey,
    userId,
    deviceId,
    clientIp: req.ip || req.socket.remoteAddress || '127.0.0.1',
    issuedAt: now,
    expiresAt: now + 24 * 60 * 60 * 1000 // 24 hours
  };

  validHandshakeTokens.set(sessionKey, tokenPayload);
  console.log(`[Handshake API] Issued verified Session Key "${sessionKey}" for User "${userId}" on Device "${deviceId}"`);

  res.json({
    status: "success",
    sessionKey: sessionKey,
    serverTimestamp: now
  });
});

// --- DEFAULT SEED DATA ---
const defaultSettings = {
  promoSubtitle: "Save 30% Today!",
  promoTitle: "Exclusive discounts on home services",
  promoDiscount: "30%",
  bannerImageUrl: "",
  updatedAt: new Date().toISOString()
};

const defaultCategories = [
  'Cleaning',
  'Plumbing',
  'Electrical',
  'Appliance',
  'Painting',
  'Carpentry',
  'Pest Control',
  'Salon'
];

const defaultUsers = [
  { id: 'u1', name: 'Alex Johnson', email: 'alex@example.com', role: 'customer', createdAt: '2026-01-15' },
  { id: 'u2', name: 'Maria Garcia', email: 'maria@example.com', role: 'customer', createdAt: '2026-02-10' },
  { id: 'u3', name: 'Devon Smith', email: 'devon@example.com', role: 'customer', createdAt: '2026-03-01' },
  { id: 'p1', name: 'Rajesh Electrical Solutions', email: 'rajesh@meetly.pro', role: 'provider', createdAt: '2026-01-01' },
  { id: 'p2', name: 'Anil Electrical Works', email: 'anil@meetly.pro', role: 'provider', createdAt: '2026-01-05' },
  { id: 'p4', name: 'Kochi Cleaning Crew', email: 'clean@meetly.pro', role: 'provider', createdAt: '2026-01-10' },
  { id: 'p7', name: 'Express Plumbers Kochi', email: 'plumbing@meetly.pro', role: 'provider', createdAt: '2026-01-12' },
  { id: 'admin1', name: 'System Admin', email: 'admin@meetly.com', role: 'admin', createdAt: '2026-01-01' }
];

const defaultBookings = [
  { id: 'b_101', customerId: 'u1', customerName: 'Alex Johnson', providerId: 'p1', serviceTitle: 'Home Rewiring & Switchboard Repair', bookingDate: '2026-08-25', status: 'completed', totalAmount: 499.0 },
  { id: 'b_102', customerId: 'u2', customerName: 'Maria Garcia', providerId: 'p4', serviceTitle: 'Full Home Deep Cleaning', bookingDate: '2026-08-28', status: 'completed', totalAmount: 1299.0 },
  { id: 'b_103', customerId: 'u3', customerName: 'Devon Smith', providerId: 'p7', serviceTitle: 'Emergency Pipe Leak Fix', bookingDate: '2026-08-30', status: 'confirmed', totalAmount: 349.0 },
  { id: 'b_104', customerId: 'u1', customerName: 'Alex Johnson', providerId: 'p2', serviceTitle: 'Inverter Installation', bookingDate: '2026-08-31', status: 'inProgress', totalAmount: 799.0 },
  { id: 'b_105', customerId: 'u2', customerName: 'Maria Garcia', providerId: 'p1', serviceTitle: 'AC Wiring Check', bookingDate: '2026-09-02', status: 'pending', totalAmount: 299.0 }
];

const defaultProviders = [
  {
    id: 'p1',
    userId: 'up2',
    businessName: 'Rajesh Electrical Solutions',
    profession: 'Certified Industrial & Home Electrician',
    rating: 4.8,
    reviewCount: 142,
    distance: 1.2,
    startingPrice: 199.0,
    verified: true,
    bio: 'Providing safe, certified electrical installations, rewiring, and appliance repair services in Kochi for over 8 years.',
    portfolioImages: ['https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600'],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kochi city limits, Kakkanad, Edappally',
    responseTime: 'Within 30 mins',
    category: 'Electrical',
    phone: '+91 9895100002',
    location: 'Kochi',
    verificationStatus: 'verified'
  }
];

const defaultBanners = [
  {
    id: 'b1',
    promoSubtitle: "Save 30% Today!",
    promoTitle: "Exclusive discounts on home services",
    promoDiscount: "30%",
    bannerImageUrl: ""
  }
];

// --- INITIALIZE FILE DATABASES ---
if (!fs.existsSync(SETTINGS_FILE)) fs.writeFileSync(SETTINGS_FILE, JSON.stringify(defaultSettings, null, 2));
if (!fs.existsSync(CATEGORIES_FILE)) fs.writeFileSync(CATEGORIES_FILE, JSON.stringify(defaultCategories, null, 2));
if (!fs.existsSync(PROVIDERS_FILE)) fs.writeFileSync(PROVIDERS_FILE, JSON.stringify(defaultProviders, null, 2));
if (!fs.existsSync(BANNERS_FILE)) fs.writeFileSync(BANNERS_FILE, JSON.stringify(defaultBanners, null, 2));
if (!fs.existsSync(BOOKINGS_FILE)) fs.writeFileSync(BOOKINGS_FILE, JSON.stringify(defaultBookings, null, 2));
if (!fs.existsSync(USERS_FILE)) fs.writeFileSync(USERS_FILE, JSON.stringify(defaultUsers, null, 2));

// Helpers
function readJsonFile(filePath, fallback) {
  try {
    const data = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    console.error(`Error reading file ${filePath}:`, err);
    return fallback;
  }
}

function writeJsonFile(filePath, data) {
  try {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
  } catch (err) {
    console.error(`Error writing file ${filePath}:`, err);
  }
}

// Firebase RTDB Sync Helper
async function syncToFirebase(pathOrUrl, data) {
  let pathKey = pathOrUrl;
  if (pathOrUrl.startsWith('http')) {
    const match = pathOrUrl.match(/\/([^\/]+)\.json/);
    if (match) {
      pathKey = match[1];
    }
  }

  if (db) {
    try {
      await db.ref(pathKey).set(data);
      console.log(`Firebase Admin SDK: Successfully synced "${pathKey}" to database.`);
      return true;
    } catch (err) {
      console.error(`Firebase Admin SDK error syncing "${pathKey}":`, err.message);
    }
  }

  try {
    const url = `https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/${pathKey}.json`;
    const response = await fetch(url, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    if (response.ok) {
      console.log(`REST Fallback: Successfully synced "${pathKey}" to database.`);
    }
    return response.ok;
  } catch (err) {
    console.error(`REST Fallback error syncing "${pathKey}":`, err.message);
    return false;
  }
}

// --- CREATE HTTP SERVER & WEBSOCKET ENGINE ---
const server = http.createServer(app);
const wss = new WebSocket.Server({ noServer: true });

// --- IN-MEMORY ACTIVE SESSION MANAGER & HEARTBEAT PROTOCOL ---
class ActiveSessionManager {
  constructor() {
    this.sessions = new Map(); // ws -> Session metadata
    this.heartbeatIntervalMs = 15000;
    this.maxMissedPings = 2; // Evict if client misses 2 consecutive pings (30s)

    // Audit heartbeats periodically
    setInterval(() => this._auditHeartbeats(), this.heartbeatIntervalMs);
  }

  register(ws, tokenPayload, req) {
    const clientIp = (req && req.socket && req.socket.remoteAddress) ? req.socket.remoteAddress : '127.0.0.1';
    const isAdminConsole = (tokenPayload.userId === 'admin_web_console') || 
                           (tokenPayload.deviceId && tokenPayload.deviceId.includes('admin_console'));

    const session = {
      ws,
      sessionKey: tokenPayload.sessionKey,
      userId: tokenPayload.userId || 'verified_user',
      deviceId: tokenPayload.deviceId || 'dev_authenticated',
      deviceName: 'Flutter Application',
      platform: 'Mobile / Desktop',
      ip: clientIp,
      connectedAt: new Date().toISOString(),
      lastPingAt: Date.now(),
      isAdminConsole: isAdminConsole,
    };

    this.sessions.set(ws, session);
    if (!isAdminConsole) {
      console.log(`[ActiveSessionManager] Verified Flutter App Connected (${session.deviceId} / User: ${session.userId}). Total Active Apps: ${this.totalConnectedDevices}`);
    } else {
      console.log(`[ActiveSessionManager] Admin Web Console Telemetry Stream Attached.`);
    }
    return session;
  }

  identify(ws, payload) {
    const session = this.sessions.get(ws);
    if (!session) return;
    session.deviceId = payload.deviceId || session.deviceId;
    session.userId = payload.userId || session.userId;
    session.deviceName = payload.deviceName || session.deviceName;
    session.platform = payload.platform || session.platform;
    session.connectedAt = payload.connectedAt || session.connectedAt;
    session.lastPingAt = Date.now();
    if (!session.isAdminConsole) {
      console.log(`[ActiveSessionManager] Identified Verified Device (${session.deviceId} - ${session.deviceName})`);
    }
  }

  recordPing(ws) {
    const session = this.sessions.get(ws);
    if (session) {
      session.lastPingAt = Date.now();
    }
  }

  unregister(ws) {
    const session = this.sessions.get(ws);
    if (session) {
      this.sessions.delete(ws);
      if (!session.isAdminConsole) {
        console.log(`[ActiveSessionManager] Verified App Session Evicted (${session.deviceId}). Total Active Apps: ${this.totalConnectedDevices}`);
      }
    }
  }

  getConnectedDevicesList() {
    const list = [];
    this.sessions.forEach((s) => {
      if (!s.isAdminConsole) {
        list.push({
          deviceId: s.deviceId,
          userId: s.userId,
          deviceName: s.deviceName,
          platform: s.platform,
          ip: s.ip,
          connectedAt: s.connectedAt,
          lastPingAt: s.lastPingAt,
        });
      }
    });
    return list;
  }

  get totalConnectedDevices() {
    let count = 0;
    this.sessions.forEach((s) => {
      if (!s.isAdminConsole) {
        count++;
      }
    });
    return count;
  }

  _auditHeartbeats() {
    const now = Date.now();
    let evictedCount = 0;
    this.sessions.forEach((session, ws) => {
      if (now - session.lastPingAt > this.heartbeatIntervalMs * this.maxMissedPings) {
        console.warn(`[ActiveSessionManager] Evicting stagnant device session ${session.deviceId} due to 2 missed heartbeats.`);
        try {
          ws.terminate();
        } catch (_) {}
        this.sessions.delete(ws);
        evictedCount++;
      }
    });

    if (evictedCount > 0) {
      broadcastAnalytics();
    }
  }
}

const sessionManager = new ActiveSessionManager();

// --- WEBSOCKET AUTHENTICATION GUARD ON HTTP UPGRADE ---
server.on('upgrade', (request, socket, head) => {
  try {
    const requestUrl = new URL(request.url, `http://${request.headers.host}`);
    const token = requestUrl.searchParams.get('token');

    // Admin Console Browser WebSockets or handshake authenticated tokens
    const isWebAdminConsole = request.headers['user-agent'] && request.headers['user-agent'].includes('Mozilla');

    if (!token && !isWebAdminConsole) {
      console.warn(`[WebSocket Auth Guard] Rejected unauthenticated connection attempt (Missing token parameter)`);
      socket.write('HTTP/1.1 401 Unauthorized\r\n\r\n');
      socket.destroy();
      return;
    }

    let tokenPayload = null;
    if (token) {
      tokenPayload = validHandshakeTokens.get(token);
      if (!tokenPayload) {
        console.warn(`[WebSocket Auth Guard] Rejected invalid/expired token connection attempt: "${token}"`);
        socket.write('HTTP/1.1 403 Forbidden\r\n\r\n');
        socket.destroy();
        return;
      }
    } else {
      tokenPayload = {
        sessionKey: 'admin_console_' + Date.now(),
        userId: 'admin_web_console',
        deviceId: 'dev_admin_console',
      };
    }

    wss.handleUpgrade(request, socket, head, (ws) => {
      wss.emit('connection', ws, request, tokenPayload);
    });
  } catch (err) {
    socket.write('HTTP/1.1 400 Bad Request\r\n\r\n');
    socket.destroy();
  }
});

function computeAnalytics() {
  const users = readJsonFile(USERS_FILE, defaultUsers);
  const bookings = readJsonFile(BOOKINGS_FILE, defaultBookings);
  const providers = readJsonFile(PROVIDERS_FILE, defaultProviders);

  const totalUsers = users.length;
  const customerCount = users.filter(u => u.role === 'customer').length;
  const providerCount = providers.length;
  
  const totalBookings = bookings.length;
  const pendingBookings = bookings.filter(b => b.status === 'pending').length;
  const confirmedBookings = bookings.filter(b => b.status === 'confirmed').length;
  const inProgressBookings = bookings.filter(b => b.status === 'inProgress').length;
  const completedBookings = bookings.filter(b => b.status === 'completed').length;
  const cancelledBookings = bookings.filter(b => b.status === 'cancelled').length;

  const totalRevenue = bookings
    .filter(b => b.status === 'completed' || b.status === 'confirmed' || b.status === 'inProgress')
    .reduce((sum, b) => sum + (Number(b.totalAmount) || 0), 0);

  const avgTicketSize = totalBookings > 0 ? Math.round(totalRevenue / totalBookings) : 0;
  const connectedDevices = sessionManager.getConnectedDevicesList();

  return {
    activeConnections: sessionManager.totalConnectedDevices,
    totalConnectedDevices: sessionManager.totalConnectedDevices,
    connectedDevices: connectedDevices,
    totalUsers,
    customerCount,
    providerCount,
    totalBookings,
    bookingMetrics: {
      pending: pendingBookings,
      confirmed: confirmedBookings,
      inProgress: inProgressBookings,
      completed: completedBookings,
      cancelled: cancelledBookings,
    },
    revenueMetrics: {
      totalRevenue,
      avgTicketSize,
      currency: "INR"
    },
    timestamp: new Date().toISOString()
  };
}

function broadcastAnalytics() {
  const payload = JSON.stringify({
    type: 'ADMIN_TELEMETRY',
    data: computeAnalytics()
  });

  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(payload);
    }
  });
}

wss.on('connection', (ws, req, tokenPayload) => {
  sessionManager.register(ws, tokenPayload, req);

  // Send initial state immediately upon authenticated connection
  ws.send(JSON.stringify({
    type: 'ADMIN_TELEMETRY',
    data: computeAnalytics()
  }));

  broadcastAnalytics();

  ws.on('message', async (message) => {
    try {
      const data = JSON.parse(message.toString());
      sessionManager.recordPing(ws);

      if (data.type === 'CLIENT_IDENTIFY') {
        sessionManager.identify(ws, data);
        broadcastAnalytics();
      } else if (data.type === 'PING') {
        ws.send(JSON.stringify({ type: 'PONG', timestamp: new Date().toISOString() }));
      } else if (data.type === 'SYNC_QUEUE') {
        const queue = data.queue || [];
        console.log(`[WebSocket] Flushing ${queue.length} offline queued actions to server...`);
        for (const item of queue) {
          if (item.action === 'addCategory' && item.payload && item.payload.category) {
            const categories = readJsonFile(CATEGORIES_FILE, defaultCategories);
            if (!categories.includes(item.payload.category)) {
              categories.push(item.payload.category);
              writeJsonFile(CATEGORIES_FILE, categories);
              await syncToFirebase(FIREBASE_CATEGORIES_URL, categories);
            }
          } else if (item.action === 'createBooking' && item.payload) {
            const bookings = readJsonFile(BOOKINGS_FILE, defaultBookings);
            bookings.push(item.payload);
            writeJsonFile(BOOKINGS_FILE, bookings);
            await syncToFirebase(FIREBASE_BOOKINGS_URL, bookings);
          }
        }
        ws.send(JSON.stringify({ type: 'SYNC_RESPONSE', success: true, count: queue.length }));
        broadcastAnalytics();
      } else if (data.type === 'CREATE_BOOKING' && data.booking) {
        const bookings = readJsonFile(BOOKINGS_FILE, defaultBookings);
        bookings.push(data.booking);
        writeJsonFile(BOOKINGS_FILE, bookings);
        await syncToFirebase(FIREBASE_BOOKINGS_URL, bookings);
        broadcastAnalytics();
        ws.send(JSON.stringify({ type: 'BOOKING_CREATED', booking: data.booking }));
      } else if (data.type === 'UPDATE_BOOKING_STATUS' && data.bookingId) {
        const bookings = readJsonFile(BOOKINGS_FILE, defaultBookings);
        const idx = bookings.findIndex(b => b.id === data.bookingId);
        if (idx !== -1) {
          bookings[idx].status = data.status;
          writeJsonFile(BOOKINGS_FILE, bookings);
          await syncToFirebase(FIREBASE_BOOKINGS_URL, bookings);
          broadcastAnalytics();
          ws.send(JSON.stringify({ type: 'BOOKING_UPDATED', booking: bookings[idx] }));
        }
      }
    } catch (err) {
      console.error('[WebSocket] Error processing message:', err.message);
    }
  });

  ws.on('close', () => {
    sessionManager.unregister(ws);
    broadcastAnalytics();
  });
});

// --- REST API ENDPOINTS ---
app.get('/api/analytics/events', async (req, res) => {
  try {
    const url = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/analytics_events.json';
    const response = await fetch(url);
    if (response.ok) {
      const data = await response.json();
      if (data) {
        const eventsList = Object.entries(data).map(([id, evt]) => ({
          id,
          ...evt
        })).sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        return res.json(eventsList);
      }
    }
    res.json([]);
  } catch (err) {
    console.error('Error fetching analytics events from Firebase RTDB:', err.message);
    res.json([]);
  }
});

app.get('/api/analytics/realtime', (req, res) => {
  res.json(computeAnalytics());
});

app.get('/api/analytics/overview', async (req, res) => {
  const startDate = req.query.startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
  const endDate = req.query.endDate || new Date().toISOString().split('T')[0];
  try {
    const data = await bigQueryService.getOverviewMetrics(startDate, endDate);
    data.activeConnections = sessionManager.totalConnectedDevices;
    data.totalConnectedDevices = sessionManager.totalConnectedDevices;
    data.connectedDevices = sessionManager.getConnectedDevicesList();
    res.json(data);
  } catch (err) {
    res.json(computeAnalytics());
  }
});

app.get('/api/analytics/categories', async (req, res) => {
  try {
    const data = await bigQueryService.getCategoryClicksDistribution();
    res.json(data);
  } catch (err) {
    res.json([]);
  }
});

app.post('/api/analytics/event', (req, res) => {
  const { eventName, payload } = req.body;
  if (!eventName) return res.status(400).json({ error: 'eventName is required' });
  bigQueryService.recordSimulatedEvent(eventName, payload || {});
  res.json({ success: true });
});

app.get('/api/settings', (req, res) => {
  res.json(readJsonFile(SETTINGS_FILE, defaultSettings));
});

app.post('/api/settings', async (req, res) => {
  const current = readJsonFile(SETTINGS_FILE, defaultSettings);
  const updated = { ...current, ...req.body, updatedAt: new Date().toISOString() };
  writeJsonFile(SETTINGS_FILE, updated);
  const synced = await syncToFirebase(FIREBASE_SETTINGS_URL, updated);
  res.json({ message: "Settings saved", settings: updated, firebaseSynced: synced });
});

app.get('/api/categories', (req, res) => {
  res.json(readJsonFile(CATEGORIES_FILE, defaultCategories));
});

app.post('/api/categories', async (req, res) => {
  const categories = readJsonFile(CATEGORIES_FILE, defaultCategories);
  const newCat = req.body.category || req.body.name;
  if (!newCat) return res.status(400).json({ error: "Category name is required" });
  const trimmed = newCat.trim();
  if (trimmed && !categories.some(c => c.toLowerCase() === trimmed.toLowerCase())) {
    categories.push(trimmed);
    writeJsonFile(CATEGORIES_FILE, categories);
    await syncToFirebase(FIREBASE_CATEGORIES_URL, categories);
    broadcastAnalytics();
  }
  res.json({ message: "Category added", categories });
});

app.delete('/api/categories/:name', async (req, res) => {
  const categories = readJsonFile(CATEGORIES_FILE, defaultCategories);
  const toDelete = req.params.name;
  const filtered = categories.filter(c => c.toLowerCase() !== toDelete.toLowerCase());
  writeJsonFile(CATEGORIES_FILE, filtered);
  await syncToFirebase(FIREBASE_CATEGORIES_URL, filtered);
  broadcastAnalytics();
  res.json({ message: "Category deleted", categories: filtered });
});

app.get('/api/banners', (req, res) => {
  res.json(readJsonFile(BANNERS_FILE, defaultBanners));
});

app.post('/api/banners', async (req, res) => {
  const banners = readJsonFile(BANNERS_FILE, defaultBanners);
  const banner = req.body;
  if (!banner.promoTitle) return res.status(400).json({ error: "Banner title is required" });
  if (!banner.id) {
    banner.id = 'b_' + Math.random().toString(36).substr(2, 9);
    banners.push(banner);
  } else {
    const idx = banners.findIndex(b => b.id === banner.id);
    if (idx !== -1) {
      banners[idx] = banner;
    } else {
      banners.push(banner);
    }
  }
  writeJsonFile(BANNERS_FILE, banners);
  await syncToFirebase(FIREBASE_BANNERS_URL, banners);
  broadcastAnalytics();
  res.json({ message: "Banner saved", banners });
});

app.delete('/api/banners/:id', async (req, res) => {
  const banners = readJsonFile(BANNERS_FILE, defaultBanners);
  const idToDelete = req.params.id;
  const filtered = banners.filter(b => b.id !== idToDelete);
  writeJsonFile(BANNERS_FILE, filtered);
  await syncToFirebase(FIREBASE_BANNERS_URL, filtered);
  broadcastAnalytics();
  res.json({ message: "Banner deleted", banners: filtered });
});

// START SERVER & PUBLISH DISCOVERY ADDRESS TO FIREBASE RTDB
server.listen(PORT, async () => {
  console.log(`Meetly Server & WebSocket running on http://localhost:${PORT} (ws://localhost:${PORT})`);
  
  // Publish Dynamic Server IP to Firebase RTDB Discovery Layer
  const localIp = 'localhost'; 
  const serverHttpUrl = `http://${localIp}:${PORT}`;
  const serverWsUrl = `ws://${localIp}:${PORT}`;

  console.log("Publishing dynamic server IP and WebSocket URL to Firebase Realtime Database...");
  await syncToFirebase(FIREBASE_SERVER_URL, serverHttpUrl);
  await syncToFirebase(FIREBASE_WS_URL, serverWsUrl);

  console.log("Syncing baseline databases to Firebase RTDB nodes...");
  await syncToFirebase(FIREBASE_SETTINGS_URL, readJsonFile(SETTINGS_FILE, defaultSettings));
  await syncToFirebase(FIREBASE_CATEGORIES_URL, readJsonFile(CATEGORIES_FILE, defaultCategories));
  await syncToFirebase(FIREBASE_PROVIDERS_URL, readJsonFile(PROVIDERS_FILE, defaultProviders));
  await syncToFirebase(FIREBASE_BANNERS_URL, readJsonFile(BANNERS_FILE, defaultBanners));
  await syncToFirebase(FIREBASE_BOOKINGS_URL, readJsonFile(BOOKINGS_FILE, defaultBookings));
  await syncToFirebase(FIREBASE_USERS_URL, readJsonFile(USERS_FILE, defaultUsers));
});
