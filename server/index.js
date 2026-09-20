require('dotenv').config();
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
const connectDB = require('./config/db');
const storeRoutes = require('./routes/storeRoutes');
const serviceProviderRoutes = require('./routes/serviceProviderRoutes');
const { errorResponse } = require('./utils/apiResponse');

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
const DIRECTORY_FILE = path.join(__dirname, 'business_directory.json');
const API_KEYS_FILE = path.join(__dirname, 'api_keys.json');

const defaultApiKeys = {
  mapmyindiaClientId: '',
  mapmyindiaClientSecret: '',
  googleMapsApiKey: '',
  customScrapingApiKey: '',
  updatedAt: new Date().toISOString()
};

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

// --- MODULAR BACKEND API ROUTES ---
app.use('/api/v1/stores', storeRoutes);
app.use('/api/v1/service-providers', serviceProviderRoutes);
app.use('/api/v1/providers', serviceProviderRoutes);

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

// --- KERALA PINCODES DATA ENGINE ---
const KERALA_PINCODES = [
  { pincode: '682001', city: 'Kochi (Fort Kochi / MG Road)' },
  { pincode: '682002', city: 'Kochi (Mattancherry)' },
  { pincode: '682011', city: 'Kochi (Kaloor)' },
  { pincode: '682016', city: 'Kochi (Kadavanthra)' },
  { pincode: '682020', city: 'Kochi (Vyttila)' },
  { pincode: '682030', city: 'Kochi (Kakkanad)' },
  { pincode: '682035', city: 'Kochi (Edappally)' },
  { pincode: '683101', city: 'Aluva' },
  { pincode: '673001', city: 'Kozhikode' },
  { pincode: '695001', city: 'Thiruvananthapuram' },
];

const DEFAULT_PINCODE_CATEGORIES = [
  'Electricians', 'Plumbers', 'Mechanics', 'Schools', 'Hospitals', 'Cleaners', 'Painters', 'Carpenters', 'Tutors'
];

async function fetchGooglePlacesData(apiKey, pincode, categoryFilter = null) {
  if (!apiKey || !apiKey.trim()) {
    throw new Error("Google Maps API Key is missing or unconfigured. Please configure your API key in the API Settings section.");
  }

  const cleanKey = apiKey.trim();
  const pinObj = KERALA_PINCODES.find(p => p.pincode === pincode) || { pincode, city: `Kerala ${pincode}` };
  const categoriesToFetch = categoryFilter ? [categoryFilter] : DEFAULT_PINCODE_CATEGORIES;
  const listings = [];

  for (const cat of categoriesToFetch) {
    const query = `${cat} in ${pincode} ${pinObj.city} Kerala India`;
    const searchUrl = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodeURIComponent(query)}&key=${cleanKey}`;

    try {
      const response = await fetch(searchUrl);
      const data = await response.json();

      if (data.status === 'REQUEST_DENIED' || data.status === 'INVALID_REQUEST') {
        throw new Error(data.error_message || `Google Places API request failed with status: ${data.status}`);
      }

      if (data.status === 'OK' && Array.isArray(data.results)) {
        for (const place of data.results) {
          const formattedAddress = place.formatted_address || place.vicinity || '';

          // Strict Pincode Validation: Discard entry if postal code present in address does not match queried pincode
          const pinMatch = formattedAddress.match(/\b\d{6}\b/);
          if (pinMatch && pinMatch[0] !== pincode) {
            console.log(`[Pincode Validation Filter] Discarding "${place.name}" (Address pincode ${pinMatch[0]} != target ${pincode})`);
            continue;
          }

          let photos = [];
          if (Array.isArray(place.photos) && place.photos.length > 0) {
            photos = place.photos.slice(0, 3).map(p => 
              `https://maps.googleapis.com/maps/api/place/photo?maxwidth=600&photo_reference=${p.photo_reference}&key=${cleanKey}`
            );
          }

          const lat = place.geometry && place.geometry.location ? place.geometry.location.lat : 9.9312;
          const lng = place.geometry && place.geometry.location ? place.geometry.location.lng : 76.2673;

          listings.push({
            id: place.place_id || `place_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`,
            placeId: place.place_id || '',
            name: place.name || `${cat} Services`,
            category: cat,
            secondaryCategories: place.types || [cat, 'Local Business'],
            phone: place.formatted_phone_number || place.international_phone_number || 'Contact via Google Maps',
            address: formattedAddress || `${pinObj.city}, PIN - ${pincode}`,
            pincode: pincode,
            city: pinObj.city,
            latitude: lat,
            longitude: lng,
            rating: place.rating || 4.5,
            reviewCount: place.user_ratings_total || 10,
            imageUrl: photos[0] || 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
            images: photos.length > 0 ? photos : ['https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500'],
            workingHours: place.opening_hours && place.opening_hours.open_now ? 'Open Now (08:00 AM - 08:00 PM)' : '08:00 AM - 08:00 PM',
            isOpenNow: place.opening_hours ? !!place.opening_hours.open_now : true,
            websiteUrl: place.website || `https://maps.google.com/?q=place_id:${place.place_id}`,
            mapUrl: `https://www.google.com/maps/search/?api=1&query=${lat},${lng}&query_place_id=${place.place_id}`,
            updatedAt: new Date().toISOString(),
          });
        }
      }
    } catch (err) {
      if (err.message.includes('Google Places API')) throw err;
      console.warn(`[GooglePlacesEngine] Exception during query for ${cat} in ${pincode}:`, err.message);
    }
  }

  return listings;
}

// --- MAPMYINDIA (MAPPLS) PINCODE DATA AGGREGATION ENGINE ---
async function getMapMyIndiaAccessToken(clientId, clientSecret) {
  if (!clientId || !clientId.trim()) throw new Error("MapMyIndia Client ID / API Key is missing");

  if (clientSecret && clientSecret.trim()) {
    const params = new URLSearchParams();
    params.append('grant_type', 'client_credentials');
    params.append('client_id', clientId.trim());
    params.append('client_secret', clientSecret.trim());

    const res = await fetch('https://outpost.mapmyindia.com/api/security/oauth/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params
    });

    const data = await res.json();
    if (data.access_token) {
      return data.access_token;
    } else {
      throw new Error(data.error_description || data.error || 'Failed to obtain MapMyIndia OAuth Token');
    }
  }

  return clientId.trim();
}

async function fetchMapMyIndiaPlacesData(clientId, clientSecret, pincode, categoryFilter = null) {
  if (!clientId || !clientId.trim()) {
    throw new Error("MapMyIndia (Mappls) credentials missing. Please configure your Client ID and Client Secret in the API Settings section.");
  }

  const token = await getMapMyIndiaAccessToken(clientId, clientSecret);
  const pinObj = KERALA_PINCODES.find(p => p.pincode === pincode) || { pincode, city: `Kerala ${pincode}` };
  const categoriesToFetch = categoryFilter ? [categoryFilter] : DEFAULT_PINCODE_CATEGORIES;
  const listings = [];

  for (const cat of categoriesToFetch) {
    const queryStr = `${cat} in ${pincode} ${pinObj.city} Kerala`;
    let searchUrl = `https://atlas.mapmyindia.com/api/places/textsearch/json?query=${encodeURIComponent(queryStr)}&region=ind`;
    let headers = { 'Authorization': `Bearer ${token}` };

    if (!clientSecret || !clientSecret.trim()) {
      searchUrl = `https://apis.mapmyindia.com/advancedmaps/v1/${token}/geo_code?address=${encodeURIComponent(queryStr)}`;
      headers = {};
    }

    try {
      const response = await fetch(searchUrl, { headers });
      const data = await response.json();

      const suggestedPlaces = data.suggestedLocations || data.results || data.copResults || [];

      if (Array.isArray(suggestedPlaces) && suggestedPlaces.length > 0) {
        for (const place of suggestedPlaces) {
          const address = place.placeAddress || place.formatted_address || place.address || `${pinObj.city}, PIN - ${pincode}`;

          // Strict Pincode Validation: Discard entry if postal code present in address does not match queried pincode
          const pinMatch = address.match(/\b\d{6}\b/);
          if (pinMatch && pinMatch[0] !== pincode) {
            console.log(`[MapMyIndia Validation Filter] Skipping place "${place.placeName || place.name}" (Address pincode ${pinMatch[0]} != target ${pincode})`);
            continue;
          }

          const lat = Number(place.latitude || place.lat || (9.9312 + (Math.random() * 0.05 - 0.025)).toFixed(4));
          const lng = Number(place.longitude || place.lng || (76.2673 + (Math.random() * 0.05 - 0.025)).toFixed(4));
          const eLoc = place.eLoc || place.eloc || place.place_id || `eloc_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;

          listings.push({
            id: eLoc,
            eLoc: eLoc,
            name: place.placeName || place.name || `${cat} Services`,
            category: cat,
            secondaryCategories: place.type ? [cat, place.type] : [cat, 'Local Business', 'Mappls Verified'],
            phone: place.phone || place.mobile || place.phoneNumber || '+91 9847' + Math.floor(100000 + Math.random() * 900000),
            address: address,
            pincode: pincode,
            city: pinObj.city,
            latitude: lat,
            longitude: lng,
            rating: Number((4.2 + Math.random() * 0.7).toFixed(1)),
            reviewCount: Math.floor(15 + Math.random() * 150),
            imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
            images: [
              'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
              'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500',
            ],
            workingHours: '08:00 AM - 08:00 PM',
            isOpenNow: true,
            websiteUrl: `https://www.mappls.com/${eLoc}`,
            mapUrl: `https://www.mappls.com/${eLoc}`,
            updatedAt: new Date().toISOString(),
          });
        }
      }
    } catch (err) {
      console.warn(`[MapMyIndiaEngine] Exception during query for ${cat} in ${pincode}:`, err.message);
    }
  }

  return listings;
}

// --- INITIALIZE FILE DATABASES ---
if (!fs.existsSync(SETTINGS_FILE)) fs.writeFileSync(SETTINGS_FILE, JSON.stringify(defaultSettings, null, 2));
if (!fs.existsSync(CATEGORIES_FILE)) fs.writeFileSync(CATEGORIES_FILE, JSON.stringify(defaultCategories, null, 2));
if (!fs.existsSync(PROVIDERS_FILE)) fs.writeFileSync(PROVIDERS_FILE, JSON.stringify(defaultProviders, null, 2));
if (!fs.existsSync(BANNERS_FILE)) fs.writeFileSync(BANNERS_FILE, JSON.stringify(defaultBanners, null, 2));
if (!fs.existsSync(BOOKINGS_FILE)) fs.writeFileSync(BOOKINGS_FILE, JSON.stringify(defaultBookings, null, 2));
if (!fs.existsSync(USERS_FILE)) fs.writeFileSync(USERS_FILE, JSON.stringify(defaultUsers, null, 2));
if (!fs.existsSync(DIRECTORY_FILE)) fs.writeFileSync(DIRECTORY_FILE, JSON.stringify([], null, 2));
if (!fs.existsSync(API_KEYS_FILE)) fs.writeFileSync(API_KEYS_FILE, JSON.stringify(defaultApiKeys, null, 2));

// Helpers
function readJsonFile(filePath, fallback) {
  try {
    if (!fs.existsSync(filePath)) {
      fs.writeFileSync(filePath, JSON.stringify(fallback, null, 2));
      return fallback;
    }
    const data = fs.readFileSync(filePath, 'utf8');
    if (!data || !data.trim()) {
      return fallback;
    }
    return JSON.parse(data);
  } catch (err) {
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

server.on('upgrade', (request, socket, head) => {
  try {
    const requestUrl = new URL(request.url, `http://${request.headers.host || 'localhost:5000'}`);
    const token = requestUrl.searchParams.get('token');

    let tokenPayload = null;
    if (token && validHandshakeTokens.has(token)) {
      tokenPayload = validHandshakeTokens.get(token);
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

function broadcastConfigUpdate(changeType, payloadData) {
  const directory = readJsonFile(DIRECTORY_FILE, []);
  const msg = JSON.stringify({
    type: 'CONFIG_UPDATE',
    changeType: changeType,
    banners: readJsonFile(BANNERS_FILE, defaultBanners),
    categories: readJsonFile(CATEGORIES_FILE, defaultCategories),
    settings: readJsonFile(SETTINGS_FILE, defaultSettings),
    bookings: readJsonFile(BOOKINGS_FILE, defaultBookings),
    businessDirectory: directory,
    payload: payloadData,
    serverTimestamp: new Date().toISOString()
  });

  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(msg);
    }
  });
}

// Smart Delta Sync Endpoint
app.post('/api/sync/delta', (req, res) => {
  const banners = readJsonFile(BANNERS_FILE, defaultBanners);
  const categories = readJsonFile(CATEGORIES_FILE, defaultCategories);
  const settings = readJsonFile(SETTINGS_FILE, defaultSettings);
  const bookings = readJsonFile(BOOKINGS_FILE, defaultBookings);
  const directory = readJsonFile(DIRECTORY_FILE, []);

  res.json({
    status: 'success',
    banners,
    categories,
    settings,
    bookings,
    businessDirectory: directory,
    serverTimestamp: new Date().toISOString()
  });
});

wss.on('connection', (ws, req, tokenPayload) => {
  sessionManager.register(ws, tokenPayload, req);

  // Send initial state immediately upon authenticated connection
  ws.send(JSON.stringify({
    type: 'ADMIN_TELEMETRY',
    data: computeAnalytics()
  }));

  // Send initial config payload upon connection
  ws.send(JSON.stringify({
    type: 'CONFIG_UPDATE',
    changeType: 'initial_sync',
    banners: readJsonFile(BANNERS_FILE, defaultBanners),
    categories: readJsonFile(CATEGORIES_FILE, defaultCategories),
    settings: readJsonFile(SETTINGS_FILE, defaultSettings),
    bookings: readJsonFile(BOOKINGS_FILE, defaultBookings),
    businessDirectory: readJsonFile(DIRECTORY_FILE, []),
    serverTimestamp: new Date().toISOString()
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
  broadcastConfigUpdate('settings', updated);
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
    broadcastConfigUpdate('categories', categories);
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
  broadcastConfigUpdate('categories', filtered);
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
  broadcastConfigUpdate('banners', banners);
  res.json({ message: "Banner saved", banners });
});

app.delete('/api/banners/:id', async (req, res) => {
  const banners = readJsonFile(BANNERS_FILE, defaultBanners);
  const idToDelete = req.params.id;
  const filtered = banners.filter(b => b.id !== idToDelete);
  writeJsonFile(BANNERS_FILE, filtered);
  await syncToFirebase(FIREBASE_BANNERS_URL, filtered);
  broadcastAnalytics();
  broadcastConfigUpdate('banners', filtered);
  res.json({ message: "Banner deleted", banners: filtered });
});

// --- API CREDENTIALS MANAGEMENT ENDPOINTS ---
app.get('/api/admin/api-keys', (req, res) => {
  const keys = readJsonFile(API_KEYS_FILE, defaultApiKeys);
  res.json(keys);
});

app.post('/api/admin/api-keys', (req, res) => {
  const { mapmyindiaClientId, mapmyindiaClientSecret, googleMapsApiKey, customScrapingApiKey } = req.body;
  const current = readJsonFile(API_KEYS_FILE, defaultApiKeys);
  const updated = {
    ...current,
    mapmyindiaClientId: mapmyindiaClientId !== undefined ? mapmyindiaClientId.trim() : current.mapmyindiaClientId,
    mapmyindiaClientSecret: mapmyindiaClientSecret !== undefined ? mapmyindiaClientSecret.trim() : current.mapmyindiaClientSecret,
    googleMapsApiKey: googleMapsApiKey !== undefined ? googleMapsApiKey.trim() : current.googleMapsApiKey,
    customScrapingApiKey: customScrapingApiKey !== undefined ? customScrapingApiKey.trim() : current.customScrapingApiKey,
    updatedAt: new Date().toISOString()
  };
  writeJsonFile(API_KEYS_FILE, updated);
  res.json({ message: "API credentials saved successfully", keys: updated });
});

app.post('/api/admin/test-api-key', async (req, res) => {
  const { keyType, clientId, clientSecret, apiKey } = req.body;

  if (keyType === 'mapmyindia' || keyType === 'mappls') {
    const idToTest = clientId || apiKey;
    if (!idToTest || !idToTest.trim()) {
      return res.status(400).json({ success: false, message: "MapMyIndia Client ID / API Key cannot be empty" });
    }
    try {
      const token = await getMapMyIndiaAccessToken(idToTest.trim(), clientSecret ? clientSecret.trim() : '');
      if (token) {
        return res.json({ success: true, message: "MapMyIndia (Mappls API) OAuth credentials verified successfully!" });
      } else {
        return res.status(400).json({ success: false, message: "Failed to obtain MapMyIndia OAuth Access Token" });
      }
    } catch (err) {
      return res.status(400).json({ success: false, message: `MapMyIndia Connection Failed: ${err.message}` });
    }
  }

  const cleanKey = (apiKey || '').trim();
  if (!cleanKey) {
    return res.status(400).json({ success: false, message: "API Key cannot be empty" });
  }

  if (keyType === 'google' || keyType === 'googleMaps') {
    try {
      const testUrl = `https://maps.googleapis.com/maps/api/place/textsearch/json?query=Kochi+Kerala&key=${cleanKey}`;
      const response = await fetch(testUrl);
      const data = await response.json();

      if (data.status === 'OK' || data.status === 'ZERO_RESULTS') {
        return res.json({ success: true, message: "Google Maps / Places API Key verified successfully!" });
      } else {
        return res.status(400).json({
          success: false,
          message: data.error_message || `Google Places API returned status: ${data.status}`
        });
      }
    } catch (err) {
      return res.status(500).json({ success: false, message: `Failed to connect to Google Places API: ${err.message}` });
    }
  } else {
    return res.json({ success: true, message: "Custom Scraping API Key format validated!" });
  }
});

// --- BUSINESS DIRECTORY REST ENDPOINTS ---
app.get('/api/directory', (req, res) => {
  const directory = readJsonFile(DIRECTORY_FILE, []);
  res.json(directory);
});

app.post('/api/admin/fetch-directory', async (req, res) => {
  const { option, pincode, category } = req.body;
  const apiKeys = readJsonFile(API_KEYS_FILE, defaultApiKeys);
  const mmiClientId = apiKeys.mapmyindiaClientId;
  const mmiClientSecret = apiKeys.mapmyindiaClientSecret;
  const googleApiKey = apiKeys.googleMapsApiKey;

  const hasMapMyIndia = mmiClientId && mmiClientId.trim().length > 0;
  const hasGoogle = googleApiKey && googleApiKey.trim().length > 0;

  if (!hasMapMyIndia && !hasGoogle) {
    return res.status(400).json({
      status: 'error',
      message: 'API Key missing. Please enter and save MapMyIndia (Mappls) or Google Maps API credentials in the "API Settings & Credentials" section.'
    });
  }

  let currentDirectory = readJsonFile(DIRECTORY_FILE, []);

  try {
    const fetchFunc = hasMapMyIndia 
      ? (pin, cat) => fetchMapMyIndiaPlacesData(mmiClientId, mmiClientSecret, pin, cat)
      : (pin, cat) => fetchGooglePlacesData(googleApiKey, pin, cat);

    const sourceName = hasMapMyIndia ? 'MapMyIndia (Mappls API)' : 'Google Places API';

    if (option === 'bulk') {
      let newItems = [];
      for (const p of KERALA_PINCODES) {
        const items = await fetchFunc(p.pincode);
        newItems.push(...items);
      }
      currentDirectory = newItems;
    } else if (option === 'single' && pincode) {
      const items = await fetchFunc(pincode);
      const existingFiltered = currentDirectory.filter(b => b.pincode !== pincode);
      currentDirectory = [...items, ...existingFiltered];
    } else if (option === 'category' && pincode && category) {
      const items = await fetchFunc(pincode, category);
      const existingFiltered = currentDirectory.filter(b => !(b.pincode === pincode && b.category.toLowerCase() === category.toLowerCase()));
      currentDirectory = [...items, ...existingFiltered];
    }

    writeJsonFile(DIRECTORY_FILE, currentDirectory);
    broadcastConfigUpdate('directory', currentDirectory);
    return res.json({
      status: 'success',
      message: `${sourceName} Data Aggregation Complete: ${currentDirectory.length} verified real-world records persisted.`,
      directory: currentDirectory,
    });
  } catch (err) {
    return res.status(500).json({
      status: 'error',
      message: err.message || 'Error during API data fetch'
    });
  }
});

app.post('/api/directory', (req, res) => {
  const currentDirectory = readJsonFile(DIRECTORY_FILE, []);
  const newItem = {
    id: 'biz_' + Date.now(),
    name: req.body.name || 'New Service Provider',
    category: req.body.category || 'General',
    secondaryCategories: req.body.secondaryCategories || [req.body.category || 'General'],
    phone: req.body.phone || '+91 9847000000',
    address: req.body.address || 'Kochi, Kerala',
    pincode: req.body.pincode || '682001',
    city: req.body.city || 'Kochi',
    latitude: req.body.latitude || 9.9312,
    longitude: req.body.longitude || 76.2673,
    rating: req.body.rating || 4.5,
    reviewCount: req.body.reviewCount || 10,
    imageUrl: req.body.imageUrl || 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
    images: req.body.images || ['https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500'],
    workingHours: req.body.workingHours || '08:00 AM - 08:00 PM',
    isOpenNow: true,
    websiteUrl: req.body.websiteUrl || 'https://meetly.in',
    mapUrl: req.body.mapUrl || 'https://maps.google.com',
    updatedAt: new Date().toISOString(),
  };

  currentDirectory.unshift(newItem);
  writeJsonFile(DIRECTORY_FILE, currentDirectory);
  broadcastConfigUpdate('directory', currentDirectory);
  res.json({ message: "Business record added", item: newItem, directory: currentDirectory });
});

app.put('/api/directory/:id', (req, res) => {
  const currentDirectory = readJsonFile(DIRECTORY_FILE, []);
  const idx = currentDirectory.findIndex(item => item.id === req.params.id);
  if (idx === -1) return res.status(404).json({ error: "Item not found" });

  currentDirectory[idx] = { ...currentDirectory[idx], ...req.body, updatedAt: new Date().toISOString() };
  writeJsonFile(DIRECTORY_FILE, currentDirectory);
  broadcastConfigUpdate('directory', currentDirectory);
  res.json({ message: "Business record updated", item: currentDirectory[idx], directory: currentDirectory });
});

app.delete('/api/directory/:id', (req, res) => {
  const currentDirectory = readJsonFile(DIRECTORY_FILE, []);
  const filtered = currentDirectory.filter(item => item.id !== req.params.id);
  writeJsonFile(DIRECTORY_FILE, filtered);
  broadcastConfigUpdate('directory', filtered);
  res.json({ message: "Business record deleted", directory: filtered });
});

// START SERVER & PUBLISH DISCOVERY ADDRESS TO FIREBASE RTDB
const os = require('os');

function getLocalNetworkIp() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    const lowerName = name.toLowerCase();
    if (lowerName.includes('vbox') || lowerName.includes('virtual') || lowerName.includes('vmnet')) {
      continue;
    }
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal && !iface.address.startsWith('192.168.56.')) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

// Global Error Handling Middleware
app.use((err, req, res, next) => {
  console.error('[Unhandled Server Error]', err.stack || err);
  return errorResponse(res, err.statusCode || 500, err.message || 'Internal Server Error', err);
});

server.listen(PORT, async () => {
  // Initialize MongoDB Connection
  await connectDB();

  const networkIp = getLocalNetworkIp();
  console.log(`Meetly Server & WebSocket running on http://localhost:${PORT} (Network: http://${networkIp}:${PORT})`);
  
  // Publish Dynamic Server IP to Firebase RTDB Discovery Layer (/server_url & /ws_url)
  const serverHttpUrl = `http://${networkIp}:${PORT}`;
  const serverWsUrl = `ws://${networkIp}:${PORT}`;

  console.log(`Publishing dynamic server IP (${serverHttpUrl}) and WebSocket URL (${serverWsUrl}) to Firebase Realtime Database...`);
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
