const express = require('express');
const router = express.Router();
const {
  getAllProviders,
  getProviderById,
  createProvider,
  updateProvider,
  deleteProvider,
} = require('../controllers/serviceProviderController');

// Service Provider routes
router.route('/')
  .get(getAllProviders)
  .post(createProvider);

router.route('/:id')
  .get(getProviderById)
  .put(updateProvider)
  .delete(deleteProvider);

module.exports = router;
