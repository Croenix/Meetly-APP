const ServiceProvider = require('../models/ServiceProvider');
const { successResponse, errorResponse, asyncHandler } = require('../utils/apiResponse');
const fs = require('fs');
const path = require('path');

const PROVIDERS_FILE = path.join(__dirname, '..', 'providers.json');

/**
 * Get all service providers with optional filtering.
 * GET /api/v1/service-providers
 */
exports.getAllProviders = asyncHandler(async (req, res) => {
  const { category, profession, verificationStatus, search, verified } = req.query;

  const filter = {};
  if (category) filter.category = new RegExp(category, 'i');
  if (profession) filter.profession = new RegExp(profession, 'i');
  if (verificationStatus) filter.verificationStatus = verificationStatus;
  if (verified !== undefined) filter.verified = verified === 'true';

  if (search) {
    filter.$or = [
      { businessName: new RegExp(search, 'i') },
      { profession: new RegExp(search, 'i') },
      { bio: new RegExp(search, 'i') },
      { location: new RegExp(search, 'i') },
    ];
  }

  try {
    const providers = await ServiceProvider.find(filter).sort({ rating: -1, createdAt: -1 });

    if (providers && providers.length > 0) {
      return successResponse(res, 200, 'Service providers retrieved successfully', providers, { count: providers.length });
    }

    // Fallback to providers.json if database has no entries
    if (fs.existsSync(PROVIDERS_FILE)) {
      const fileData = fs.readFileSync(PROVIDERS_FILE, 'utf8');
      const fallbackProviders = fileData ? JSON.parse(fileData) : [];
      return successResponse(res, 200, 'Service providers retrieved from local dataset', fallbackProviders, { count: fallbackProviders.length });
    }

    return successResponse(res, 200, 'No service providers found', []);
  } catch (err) {
    if (fs.existsSync(PROVIDERS_FILE)) {
      const fileData = fs.readFileSync(PROVIDERS_FILE, 'utf8');
      const fallbackProviders = fileData ? JSON.parse(fileData) : [];
      return successResponse(res, 200, 'Service providers retrieved from fallback dataset', fallbackProviders);
    }
    return errorResponse(res, 500, 'Failed to fetch service providers', err.message);
  }
});

/**
 * Get single service provider by ID (customId, userId, or _id).
 * GET /api/v1/service-providers/:id
 */
exports.getProviderById = asyncHandler(async (req, res) => {
  const { id } = req.params;

  try {
    const provider = await ServiceProvider.findOne({
      $or: [
        { customId: id },
        { userId: id },
        { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null },
      ],
    });

    if (!provider) {
      return errorResponse(res, 404, `Service provider with ID '${id}' not found`);
    }

    return successResponse(res, 200, 'Service provider details retrieved', provider);
  } catch (err) {
    return errorResponse(res, 500, 'Failed to fetch provider details', err.message);
  }
});

/**
 * Create a new service provider.
 * POST /api/v1/service-providers
 */
exports.createProvider = asyncHandler(async (req, res) => {
  const {
    userId,
    businessName,
    profession,
    startingPrice,
    category,
    phone,
    location,
    bio,
    portfolioImages,
    workingHours,
    serviceArea,
    responseTime,
  } = req.body;

  if (!userId || !businessName || !profession || startingPrice === undefined || !category || !phone || !location) {
    return errorResponse(res, 400, 'Missing required fields (userId, businessName, profession, startingPrice, category, phone, location)');
  }

  const newProvider = await ServiceProvider.create({
    userId,
    businessName,
    profession,
    startingPrice,
    category,
    phone,
    location,
    bio,
    portfolioImages,
    workingHours,
    serviceArea,
    responseTime,
    verificationStatus: 'under_review',
  });

  return successResponse(res, 201, 'Service provider registered successfully', newProvider);
});

/**
 * Update service provider details.
 * PUT /api/v1/service-providers/:id
 */
exports.updateProvider = asyncHandler(async (req, res) => {
  const { id } = req.params;

  let provider = await ServiceProvider.findOne({
    $or: [
      { customId: id },
      { userId: id },
      { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null },
    ],
  });

  if (!provider) {
    return errorResponse(res, 404, `Service provider with ID '${id}' not found`);
  }

  provider = await ServiceProvider.findByIdAndUpdate(provider._id, req.body, {
    new: true,
    runValidators: true,
  });

  return successResponse(res, 200, 'Service provider updated successfully', provider);
});

/**
 * Delete service provider profile.
 * DELETE /api/v1/service-providers/:id
 */
exports.deleteProvider = asyncHandler(async (req, res) => {
  const { id } = req.params;

  const provider = await ServiceProvider.findOne({
    $or: [
      { customId: id },
      { userId: id },
      { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null },
    ],
  });

  if (!provider) {
    return errorResponse(res, 404, `Service provider with ID '${id}' not found`);
  }

  await ServiceProvider.findByIdAndDelete(provider._id);

  return successResponse(res, 200, 'Service provider deleted successfully', { id });
});
