const Store = require('../models/Store');
const { successResponse, errorResponse, asyncHandler } = require('../utils/apiResponse');
const fs = require('fs');
const path = require('path');

// Fallback JSON path for local file sync
const DIRECTORY_FILE = path.join(__dirname, '..', 'business_directory.json');

/**
 * Get all stores with optional filtering (category, city, pincode, search).
 * GET /api/v1/stores
 */
exports.getAllStores = asyncHandler(async (req, res) => {
  const { category, city, pincode, search } = req.query;

  // Build filter object
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

    // If MongoDB holds stores, return them
    if (stores && stores.length > 0) {
      return successResponse(res, 200, 'Stores retrieved successfully', stores, { count: stores.length });
    }

    // Fallback to JSON directory file if DB table is empty
    if (fs.existsSync(DIRECTORY_FILE)) {
      const fileData = fs.readFileSync(DIRECTORY_FILE, 'utf8');
      const fallbackStores = fileData ? JSON.parse(fileData) : [];
      return successResponse(res, 200, 'Stores retrieved from local store directory', fallbackStores, { count: fallbackStores.length });
    }

    return successResponse(res, 200, 'No stores found', []);
  } catch (err) {
    // If DB error occurs, attempt fallback file read
    if (fs.existsSync(DIRECTORY_FILE)) {
      const fileData = fs.readFileSync(DIRECTORY_FILE, 'utf8');
      const fallbackStores = fileData ? JSON.parse(fileData) : [];
      return successResponse(res, 200, 'Stores retrieved from fallback storage', fallbackStores);
    }
    return errorResponse(res, 500, 'Failed to fetch stores', err.message);
  }
});

/**
 * Get single store by ID (customId or _id).
 * GET /api/v1/stores/:id
 */
exports.getStoreById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  try {
    let store = await Store.findOne({ $or: [{ customId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }] });

    if (!store) {
      return errorResponse(res, 404, `Store with ID '${id}' not found`);
    }

    return successResponse(res, 200, 'Store retrieved successfully', store);
  } catch (err) {
    return errorResponse(res, 500, 'Failed to fetch store details', err.message);
  }
});

/**
 * Create a new store.
 * POST /api/v1/stores
 */
exports.createStore = asyncHandler(async (req, res) => {
  const { name, category, pincode, address, phone, city, rating, imageUrl, latitude, longitude } = req.body;

  if (!name || !category || !pincode || !address || !phone || !city) {
    return errorResponse(res, 400, 'Missing required store fields (name, category, pincode, address, phone, city)');
  }

  const newStore = await Store.create({
    name,
    category,
    pincode,
    address,
    phone,
    city,
    rating: rating || 4.5,
    imageUrl,
    latitude,
    longitude,
  });

  return successResponse(res, 201, 'Store created successfully', newStore);
});

/**
 * Update store by ID.
 * PUT /api/v1/stores/:id
 */
exports.updateStore = asyncHandler(async (req, res) => {
  const { id } = req.params;

  let store = await Store.findOne({ $or: [{ customId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }] });

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

  const store = await Store.findOne({ $or: [{ customId: id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }] });

  if (!store) {
    return errorResponse(res, 404, `Store with ID '${id}' not found`);
  }

  await Store.findByIdAndDelete(store._id);

  return successResponse(res, 200, 'Store deleted successfully', { id });
});
