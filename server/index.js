const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5000;

// File databases
const SETTINGS_FILE = path.join(__dirname, 'settings.json');
const CATEGORIES_FILE = path.join(__dirname, 'categories.json');
const PROVIDERS_FILE = path.join(__dirname, 'providers.json');

// Firebase RTDB URL regional endpoints
const FIREBASE_SETTINGS_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/settings.json';
const FIREBASE_SERVER_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/server_url.json';

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
async function syncToFirebase(url, data) {
  try {
    const response = await fetch(url, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return response.ok;
  } catch (err) {
    console.error(`Firebase Sync error for ${url}:`, err);
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

app.post('/api/categories', (req, res) => {
  const categories = readJsonFile(CATEGORIES_FILE, defaultCategories);
  const newCat = req.body.category || req.body.name;
  if (!newCat) {
    return res.status(400).json({ error: "Category name is required" });
  }
  const trimmed = newCat.trim();
  if (trimmed && !categories.some(c => c.toLowerCase() === trimmed.toLowerCase())) {
    categories.push(trimmed);
    writeJsonFile(CATEGORIES_FILE, categories);
  }
  res.json({ message: "Category added", categories });
});

app.delete('/api/categories/:name', (req, res) => {
  const categories = readJsonFile(CATEGORIES_FILE, defaultCategories);
  const toDelete = req.params.name;
  const filtered = categories.filter(c => c.toLowerCase() !== toDelete.toLowerCase());
  writeJsonFile(CATEGORIES_FILE, filtered);
  res.json({ message: "Category deleted", categories: filtered });
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

app.post('/api/providers', (req, res) => {
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
  res.json({ message: "Provider profile updated", provider: updatedProvider });
});

// --- PUBLISH SERVER API URL TO FIREBASE ON STARTUP ---
app.listen(PORT, async () => {
  const hostUrl = `http://localhost:${PORT}`;
  console.log(`Meetly Admin Server running on ${hostUrl}`);
  
  console.log("Publishing server URL to Firebase Realtime Database...");
  const published = await syncToFirebase(FIREBASE_SERVER_URL, hostUrl);
  if (published) {
    console.log(`Successfully published server URL to Firebase RTDB.`);
  } else {
    console.warn("Failed to publish server URL to Firebase RTDB on startup.");
  }
});
