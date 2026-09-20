const Store = require('../models/Store');
const { successResponse, errorResponse, asyncHandler } = require('../utils/apiResponse');
const fs = require('fs');
const path = require('path');

const DIRECTORY_FILE = path.join(__dirname, '..', 'business_directory.json');

/**
 * Helper to escape regex special characters
 */
function escapeRegex(text) {
  return text ? text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') : '';
}

/**
 * Get all stores with optional filtering.
 * GET /api/v1/stores
 */
exports.getAllStores = asyncHandler(async (req, res) => {
  const { category, city, pincode, search } = req.query;

  const filter = {};
  if (category) filter.category = new RegExp(category, 'i');
  if (city) filter.city = new RegExp(city, 'i');
  if (pincode) filter.pincode = pincode;
  if (search) {
    filter.$or = [
      { name: new RegExp(search, 'i') },
      { category: new RegExp(search, 'i') },
      { address: new RegExp(search, 'i') },
    ];
  }

  try {
    const stores = await Store.find(filter).sort({ createdAt: -1 });

    if (stores && stores.length > 0) {
      return successResponse(res, 200, 'Stores retrieved successfully', stores, { count: stores.length });
    }

    if (fs.existsSync(DIRECTORY_FILE)) {
      const fileData = fs.readFileSync(DIRECTORY_FILE, 'utf8');
      const fallbackStores = fileData ? JSON.parse(fileData) : [];
      return successResponse(res, 200, 'Stores retrieved from local store directory', fallbackStores, { count: fallbackStores.length });
    }

    return successResponse(res, 200, 'No stores found', []);
  } catch (err) {
    if (fs.existsSync(DIRECTORY_FILE)) {
      const fileData = fs.readFileSync(DIRECTORY_FILE, 'utf8');
      const fallbackStores = fileData ? JSON.parse(fileData) : [];
      return successResponse(res, 200, 'Stores retrieved from fallback storage', fallbackStores);
    }
    return errorResponse(res, 500, 'Failed to fetch stores', err.message);
  }
});

/**
 * Get single store by ID.
 * GET /api/v1/stores/:id
 */
exports.getStoreById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  try {
    let store = await Store.findOne({ $or: [{ customId: id }, { placeId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }] });

    if (!store) {
      return errorResponse(res, 404, `Store with ID '${id}' not found`);
    }

    return successResponse(res, 200, 'Store retrieved successfully', store);
  } catch (err) {
    return errorResponse(res, 500, 'Failed to fetch store details', err.message);
  }
});

/**
 * Create or Upsert a single store (Deduplicated by placeId or name + pincode).
 * POST /api/v1/stores
 */
exports.createStore = asyncHandler(async (req, res) => {
  const {
    name,
    category,
    pincode,
    address,
    phone,
    city,
    rating,
    reviewCount,
    reviews,
    imageUrl,
    images,
    latitude,
    longitude,
    placeId,
    secondaryCategories,
    workingHours,
    isOpenNow,
    websiteUrl,
    mapUrl,
  } = req.body;

  if (!name || !category || !pincode || !address || !phone || !city) {
    return errorResponse(res, 400, 'Missing required store fields (name, category, pincode, address, phone, city)');
  }

  // Deduplication Filter: match by placeId or case-insensitive name + pincode
  const filter = placeId && placeId.trim()
    ? { placeId: placeId.trim() }
    : { name: new RegExp('^' + escapeRegex(name.trim()) + '$', 'i'), pincode: pincode.trim() };

  const updateData = {
    name: name.trim(),
    category,
    pincode: pincode.trim(),
    address,
    phone,
    city,
    rating: rating || 4.5,
    reviewCount: reviewCount || 0,
    reviews: reviews || [],
    imageUrl: imageUrl || (images && images[0]) || 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
    images: images || [imageUrl],
    latitude: latitude || 9.9312,
    longitude: longitude || 76.2673,
    placeId: placeId || '',
    secondaryCategories: secondaryCategories || [category],
    workingHours: workingHours || '08:00 AM - 08:00 PM',
    operatingHours: req.body.operatingHours || {},
    timetable: req.body.timetable || [],
    isOpenNow: isOpenNow !== undefined ? isOpenNow : true,
    websiteUrl: websiteUrl || '',
    mapUrl: mapUrl || '',
  };

  const store = await Store.findOneAndUpdate(
    filter,
    { $set: updateData },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  );

  return successResponse(res, 200, 'Store saved successfully without duplicates', store);
});

/**
 * Bulk create / import multiple stores to MongoDB Atlas with strict payload & DB deduplication.
 * POST /api/v1/stores/bulk
 */
exports.bulkCreateStores = asyncHandler(async (req, res) => {
  const stores = req.body.stores || req.body;

  if (!Array.isArray(stores) || stores.length === 0) {
    return errorResponse(res, 400, 'Request body must contain an array of store objects under "stores" property');
  }

  // Step 1: Payload In-Memory Deduplication
  const uniqueMap = new Map();
  for (const s of stores) {
    if (!s.name || !s.category || !s.pincode) continue;
    
    const key = s.placeId && s.placeId.trim() !== ''
      ? `place_${s.placeId.trim()}`
      : `name_${s.name.toLowerCase().trim()}_pin_${s.pincode.trim()}`;

    if (!uniqueMap.has(key)) {
      uniqueMap.set(key, s);
    }
  }

  const uniquePayloadStores = Array.from(uniqueMap.values());
  const savedStores = [];

  // Step 2: Atomic Upsert to MongoDB Atlas
  for (const s of uniquePayloadStores) {
    const filter = s.placeId && s.placeId.trim() !== ''
      ? { placeId: s.placeId.trim() }
      : { name: new RegExp('^' + escapeRegex(s.name.trim()) + '$', 'i'), pincode: s.pincode.trim() };

    const updateData = {
      name: s.name.trim(),
      category: s.category,
      secondaryCategories: s.secondaryCategories || [s.category],
      pincode: s.pincode.trim(),
      address: s.address || `${s.city || 'Kochi'}, PIN - ${s.pincode}`,
      phone: s.phone || '+91 9847000000',
      city: s.city || 'Kochi',
      rating: s.rating || 4.5,
      reviewCount: s.reviewCount || (s.reviews ? s.reviews.length : 10),
      reviews: s.reviews || [],
      imageUrl: s.imageUrl || (s.images && s.images[0]) || 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
      images: s.images || [s.imageUrl],
      latitude: s.latitude || 9.9312,
      longitude: s.longitude || 76.2673,
      placeId: s.placeId || '',
      workingHours: s.workingHours || '08:00 AM - 08:00 PM',
      operatingHours: s.operatingHours || {},
      timetable: s.timetable || [],
      isOpenNow: s.isOpenNow !== undefined ? s.isOpenNow : true,
      websiteUrl: s.websiteUrl || '',
      mapUrl: s.mapUrl || '',
    };

    const doc = await Store.findOneAndUpdate(
      filter,
      { $set: updateData },
      { new: true, upsert: true, setDefaultsOnInsert: true }
    );

    savedStores.push(doc);
  }

  return successResponse(res, 201, `Deduplicated bulk upload complete: ${savedStores.length} unique stores persisted to MongoDB Atlas`, savedStores, { count: savedStores.length });
});

/**
 * Clean up existing duplicate store documents in MongoDB Atlas.
 * POST /api/v1/stores/deduplicate
 */
exports.deduplicateStores = asyncHandler(async (req, res) => {
  const stores = await Store.find({}).sort({ createdAt: 1 });
  const seenKeys = new Set();
  const duplicateIdsToDelete = [];

  for (const s of stores) {
    const key = s.placeId && s.placeId.trim() !== ''
      ? `place_${s.placeId.trim()}`
      : `name_${s.name.toLowerCase().trim()}_pin_${s.pincode.trim()}`;

    if (seenKeys.has(key)) {
      duplicateIdsToDelete.push(s._id);
    } else {
      seenKeys.add(key);
    }
  }

  if (duplicateIdsToDelete.length > 0) {
    await Store.deleteMany({ _id: { $in: duplicateIdsToDelete } });
  }

  return successResponse(res, 200, `Cleanup complete: Removed ${duplicateIdsToDelete.length} duplicate store entries from MongoDB Atlas`, {
    purgedCount: duplicateIdsToDelete.length,
    remainingCount: seenKeys.size,
  });
});

/**
 * Update store by ID.
 * PUT /api/v1/stores/:id
 */
exports.updateStore = asyncHandler(async (req, res) => {
  const { id } = req.params;

  let store = await Store.findOne({ $or: [{ customId: id }, { placeId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }] });

  if (!store) {
    return errorResponse(res, 404, `Store with ID '${id}' not found`);
  }

  store = await Store.findByIdAndUpdate(store._id, req.body, {
    new: true,
    runValidators: true,
  });

  return successResponse(res, 200, 'Store updated successfully', store);
});

/**
 * Delete store by ID.
 * DELETE /api/v1/stores/:id
 */
exports.deleteStore = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const store = await Store.findOne({ $or: [{ customId: id }, { placeId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }] });

  if (!store) {
    return errorResponse(res, 404, `Store with ID '${id}' not found`);
  }

  await Store.findByIdAndDelete(store._id);

  return successResponse(res, 200, 'Store deleted successfully', { id });
});
