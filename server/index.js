const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5000;
const SETTINGS_FILE = path.join(__dirname, 'settings.json');
const FIREBASE_DB_URL = 'https://meetly-fea92-default-rtdb.asia-southeast1.firebasedatabase.app/settings.json';

app.use(cors());
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

// Default settings
const defaultSettings = {
  promoSubtitle: "Save 30% Today!",
  promoTitle: "Exclusive discounts on home services",
  promoDiscount: "30%",
  bannerImageUrl: "",
  updatedAt: new Date().toISOString()
};

// Initialize settings file if not exists
if (!fs.existsSync(SETTINGS_FILE)) {
  fs.writeFileSync(SETTINGS_FILE, JSON.stringify(defaultSettings, null, 2));
}

// Helper to read local settings
function readLocalSettings() {
  try {
    const data = fs.readFileSync(SETTINGS_FILE, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    console.error("Error reading settings file:", err);
    return defaultSettings;
  }
}

// Helper to write settings to Firebase RTDB
async function syncToFirebase(settings) {
  try {
    const response = await fetch(FIREBASE_DB_URL, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(settings)
    });
    
    if (response.ok) {
      console.log("Successfully synced settings to Firebase Realtime Database!");
      return { success: true };
    } else {
      const errorText = await response.text();
      console.error(`Firebase sync failed with status ${response.status}: ${errorText}`);
      return { success: false, error: errorText };
    }
  } catch (err) {
    console.error("Failed to connect to Firebase Realtime Database REST API:", err);
    return { success: false, error: err.message };
  }
}

// REST API: Get current settings
app.get('/api/settings', (req, res) => {
  const settings = readLocalSettings();
  res.json(settings);
});

// REST API: Update settings
app.post('/api/settings', async (req, res) => {
  const newSettings = {
    promoSubtitle: req.body.promoSubtitle || defaultSettings.promoSubtitle,
    promoTitle: req.body.promoTitle || defaultSettings.promoTitle,
    promoDiscount: req.body.promoDiscount || defaultSettings.promoDiscount,
    bannerImageUrl: req.body.bannerImageUrl || "",
    updatedAt: new Date().toISOString()
  };

  // Write to local json file
  fs.writeFileSync(SETTINGS_FILE, JSON.stringify(newSettings, null, 2));
  console.log("Local settings.json updated.");

  // Sync to Firebase in real-time
  const firebaseSync = await syncToFirebase(newSettings);

  res.json({
    message: "Settings saved successfully!",
    settings: newSettings,
    firebaseSync: firebaseSync
  });
});

// On startup, attempt to sync local settings to Firebase database
const currentSettings = readLocalSettings();
console.log("Attempting initial sync with Firebase on startup...");
syncToFirebase(currentSettings);

app.listen(PORT, () => {
  console.log(`Meetly Admin Server running on http://localhost:${PORT}`);
});
