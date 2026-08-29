const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

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
    console.warn("Firebase Admin SDK: service-account.json and GOOGLE_APPLICATION_CREDENTIALS not found.");
    console.warn("Initializing Admin SDK without explicit auth (relying on open database rules)...");
    admin.initializeApp({
      databaseURL: 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app'
    });
    db = admin.database();
    console.log("Firebase Admin SDK: Initialized without explicit credential (open rules)");
  }
} catch (err) {
  console.warn("Firebase Admin SDK Warning: Failed to initialize Admin SDK:", err.message);
  console.warn("Continuing... Server will fallback to REST fetch for Firebase RTDB sync operations.");
}

const app = express();
const PORT = process.env.PORT || 5000;

// File databases
const SETTINGS_FILE = path.join(__dirname, 'settings.json');
const CATEGORIES_FILE = path.join(__dirname, 'categories.json');
const PROVIDERS_FILE = path.join(__dirname, 'providers.json');
const BANNERS_FILE = path.join(__dirname, 'banners.json');

// Firebase RTDB URL regional endpoints
const FIREBASE_SETTINGS_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/settings.json';
const FIREBASE_SERVER_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/server_url.json';
const FIREBASE_BANNERS_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/banners.json';
const FIREBASE_CATEGORIES_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/categories.json';

app.use(cors());
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

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
    bio: 'Providing safe, certified electrical installations, rewiring, and appliance repair services in Kochi for over 8 years. Specialized in short-circuits and home automation systems.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600',
      'https://images.unsplash.com/photo-1558224492-db71317d63a4?w=600'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kochi city limits, Kakkanad, Edappally, and Tripunithura',
    responseTime: 'Within 30 mins',
    category: 'Electrical',
    phone: '+91 9895100002',
    location: 'Kochi',
    verificationStatus: 'verified'
  },
  {
    id: 'p2',
    userId: 'up6',
    businessName: 'Anil Electrical Works',
    profession: 'Residential Wiring & Repair Contractor',
    rating: 4.6,
    reviewCount: 78,
    distance: 2.8,
    startingPrice: 249.0,
    verified: true,
    bio: 'Affordable and reliable home electrical services including fans, lights, switchboards, inverter backup installation, and fault finding. Trustworthy and punctual service.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=600',
      'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=600'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Tue': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Wed': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Thu': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Fri': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Sat': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kottayam, Kumarakom, and Ettumanoor area',
    responseTime: 'Within 1 hour',
    category: 'Electrical',
    phone: '+91 9895100006',
    location: 'Kottayam',
    verificationStatus: 'verified'
  },
  {
    id: 'p4',
    userId: 'up3',
    businessName: 'Kochi Cleaning Crew',
    profession: 'Professional Deep Cleaners',
    rating: 4.9,
    reviewCount: 215,
    distance: 0.8,
    startingPrice: 499.0,
    verified: true,
    bio: 'Home deep cleaning, sofa cleaning, kitchen sanitation, and bathroom cleaning services. Eco-friendly cleaning materials and modern equipment used.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:00', 'end': '20:00'},
      'Tue': {'available': true, 'start': '08:00', 'end': '20:00'},
      'Wed': {'available': true, 'start': '08:00', 'end': '20:00'},
      'Thu': {'available': true, 'start': '08:00', 'end': '20:00'},
      'Fri': {'available': true, 'start': '08:00', 'end': '20:00'},
      'Sat': {'available': true, 'start': '08:00', 'end': '20:00'},
      'Sun': {'available': true, 'start': '09:00', 'end': '17:00'}
    },
    serviceArea: 'Kochi & Kakkanad area',
    responseTime: 'Within 15 mins',
    category: 'Cleaning',
    phone: '+91 9895100003',
    location: 'Kochi',
    verificationStatus: 'verified'
  },
  {
    id: 'p7',
    userId: 'up7',
    businessName: 'Express Plumbers Kochi',
    profession: 'Licensed Leak Repair Specialists',
    rating: 4.7,
    reviewCount: 94,
    distance: 1.5,
    startingPrice: 299.0,
    verified: true,
    bio: 'Emergency leak resolution, pipe replacements, tap installations, blockages, and water tank washing. Fast and reliable support.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=600'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '00:00', 'end': '23:59'},
      'Tue': {'available': true, 'start': '00:00', 'end': '23:59'},
      'Wed': {'available': true, 'start': '00:00', 'end': '23:59'},
      'Thu': {'available': true, 'start': '00:00', 'end': '23:59'},
      'Fri': {'available': true, 'start': '00:00', 'end': '23:59'},
      'Sat': {'available': true, 'start': '00:00', 'end': '23:59'},
      'Sun': {'available': true, 'start': '00:00', 'end': '23:59'}
    },
    serviceArea: 'Kochi and nearby sub-regions',
    responseTime: 'Immediate 24/7 Support',
    category: 'Plumbing',
    phone: '+91 9895100007',
    location: 'Kochi',
    verificationStatus: 'verified'
  }
];

// --- INITIALIZE FILE DATABASES ---
if (!fs.existsSync(SETTINGS_FILE)) {
  fs.writeFileSync(SETTINGS_FILE, JSON.stringify(defaultSettings, null, 2));
}
if (!fs.existsSync(CATEGORIES_FILE)) {
  fs.writeFileSync(CATEGORIES_FILE, JSON.stringify(defaultCategories, null, 2));
}
if (!fs.existsSync(PROVIDERS_FILE)) {
  fs.writeFileSync(PROVIDERS_FILE, JSON.stringify(defaultProviders, null, 2));
}

const defaultBanners = [
  {
    id: 'b1',
    promoSubtitle: "Save 30% Today!",
    promoTitle: "Exclusive discounts on home services",
    promoDiscount: "30%",
    bannerImageUrl: ""
  },
  {
    id: 'b2',
    promoSubtitle: "SPECIAL OFFER",
    promoTitle: "Top Rated Professional Plumbing Help",
    promoDiscount: "20%",
    bannerImageUrl: "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600"
  }
];

if (!fs.existsSync(BANNERS_FILE)) {
  fs.writeFileSync(BANNERS_FILE, JSON.stringify(defaultBanners, null, 2));
}

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

// Firebase RTDB Sync Helper using Firebase Admin SDK with REST API Fallback
async function syncToFirebase(pathOrUrl, data) {
  let pathKey = pathOrUrl;
  if (pathOrUrl.startsWith('http')) {
    const match = pathOrUrl.match(/\/([^\/]+)\.json/);
    if (match) {
      pathKey = match[1];
    }
  }

  // Use Firebase Admin SDK if active
  if (db) {
    try {
      await db.ref(pathKey).set(data);
      console.log(`Firebase Admin SDK: Successfully synced "${pathKey}" to database.`);
      return true;
    } catch (err) {
      console.error(`Firebase Admin SDK error syncing "${pathKey}":`, err.message);
    }
  }

  // REST API Fallback (useful if credentials are not configured yet)
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

// --- REST API ENDPOINTS ---

// APP SETTINGS
app.get('/api/settings', (req, res) => {
  res.json(readJsonFile(SETTINGS_FILE, defaultSettings));
});

app.post('/api/settings', async (req, res) => {
  const current = readJsonFile(SETTINGS_FILE, defaultSettings);
  const updated = {
    ...current,
    ...req.body,
    updatedAt: new Date().toISOString()
  };
  writeJsonFile(SETTINGS_FILE, updated);
  const synced = await syncToFirebase(FIREBASE_SETTINGS_URL, updated);
  res.json({ message: "Settings saved", settings: updated, firebaseSynced: synced });
});

// CATEGORIES
app.get('/api/categories', (req, res) => {
  res.json(readJsonFile(CATEGORIES_FILE, defaultCategories));
});

app.post('/api/categories', async (req, res) => {
  const categories = readJsonFile(CATEGORIES_FILE, defaultCategories);
  const newCat = req.body.category || req.body.name;
  if (!newCat) {
    return res.status(400).json({ error: "Category name is required" });
  }
  const trimmed = newCat.trim();
  if (trimmed && !categories.some(c => c.toLowerCase() === trimmed.toLowerCase())) {
    categories.push(trimmed);
    writeJsonFile(CATEGORIES_FILE, categories);
    
    // Sync to Firebase in real-time
    await syncToFirebase(FIREBASE_CATEGORIES_URL, categories);
  }
  res.json({ message: "Category added", categories });
});

app.delete('/api/categories/:name', async (req, res) => {
  const categories = readJsonFile(CATEGORIES_FILE, defaultCategories);
  const toDelete = req.params.name;
  const filtered = categories.filter(c => c.toLowerCase() !== toDelete.toLowerCase());
  writeJsonFile(CATEGORIES_FILE, filtered);
  
  // Sync to Firebase in real-time
  await syncToFirebase(FIREBASE_CATEGORIES_URL, filtered);
  
  res.json({ message: "Category deleted", categories: filtered });
});

// BANNERS (CRUD Endpoints)
app.get('/api/banners', (req, res) => {
  res.json(readJsonFile(BANNERS_FILE, defaultBanners));
});

app.post('/api/banners', async (req, res) => {
  const banners = readJsonFile(BANNERS_FILE, defaultBanners);
  const banner = req.body;
  
  if (!banner.promoTitle) {
    return res.status(400).json({ error: "Banner title is required" });
  }

  // Create or Update
  if (!banner.id) {
    banner.id = 'b_' + Math.random().toString(36).substr(2, 9);
    banners.push(banner);
  } else {
    const index = banners.findIndex(b => b.id === banner.id);
    if (index !== -1) {
      banners[index] = { ...banners[index], ...banner };
    } else {
      banners.push(banner);
    }
  }

  writeJsonFile(BANNERS_FILE, banners);
  
  // Sync list to Firebase Realtime Database
  const synced = await syncToFirebase(FIREBASE_BANNERS_URL, banners);
  
  res.json({ message: "Banner saved successfully", banner, firebaseSynced: synced, banners });
});

app.delete('/api/banners/:id', async (req, res) => {
  const banners = readJsonFile(BANNERS_FILE, defaultBanners);
  const toDelete = req.params.id;
  const filtered = banners.filter(b => b.id !== toDelete);
  
  writeJsonFile(BANNERS_FILE, filtered);
  
  // Sync list to Firebase Realtime Database
  const synced = await syncToFirebase(FIREBASE_BANNERS_URL, filtered);
  
  res.json({ message: "Banner deleted successfully", firebaseSynced: synced, banners: filtered });
});

// PROVIDERS
app.get('/api/providers', (req, res) => {
  res.json(readJsonFile(PROVIDERS_FILE, defaultProviders));
});

app.get('/api/providers/:id', (req, res) => {
  const providers = readJsonFile(PROVIDERS_FILE, defaultProviders);
  const provider = providers.find(p => p.id === req.params.id);
  if (provider) {
    res.json(provider);
  } else {
    res.status(404).json({ error: "Provider not found" });
  }
});

app.post('/api/providers', async (req, res) => {
  const providers = readJsonFile(PROVIDERS_FILE, defaultProviders);
  const updatedProvider = req.body;
  if (!updatedProvider || !updatedProvider.id) {
    return res.status(400).json({ error: "Provider details with ID are required" });
  }
  
  const index = providers.findIndex(p => p.id === updatedProvider.id);
  if (index !== -1) {
    providers[index] = { ...providers[index], ...updatedProvider };
  } else {
    providers.push(updatedProvider);
  }
  writeJsonFile(PROVIDERS_FILE, providers);

  // Sync providers database to Firebase RTDB in real-time
  const synced = await syncToFirebase('providers', providers);
  
  res.json({ message: "Provider profile updated", provider: updatedProvider, firebaseSynced: synced });
});

// --- PUBLISH SERVER API URL TO FIREBASE ON STARTUP ---
app.listen(PORT, async () => {
  const hostUrl = `http://localhost:${PORT}`;
  console.log(`Meetly Admin Server running on ${hostUrl}`);
  
  console.log("Publishing server URL to Firebase Realtime Database...");
  const published = await syncToFirebase('server_url', hostUrl);
  if (published) {
    console.log(`Successfully published server URL to Firebase RTDB.`);
  } else {
    console.warn("Failed to publish server URL to Firebase RTDB on startup.");
  }

  // Pre-seed all nodes to Firebase RTDB on startup in real-time
  console.log("Syncing database files to Firebase RTDB nodes...");
  await syncToFirebase('settings', readJsonFile(SETTINGS_FILE, defaultSettings));
  await syncToFirebase('categories', readJsonFile(CATEGORIES_FILE, defaultCategories));
  await syncToFirebase('providers', readJsonFile(PROVIDERS_FILE, defaultProviders));
  await syncToFirebase('banners', readJsonFile(BANNERS_FILE, defaultBanners));
});
