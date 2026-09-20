const express = require('express');
const router = express.Router();
const {
  getAllStores,
  getStoreById,
  createStore,
  bulkCreateStores,
  deduplicateStores,
  updateStore,
  deleteStore,
  getPincodes,
} = require('../controllers/storeController');

// Bulk import & deduplication cleanup routes
router.get('/pincodes', getPincodes);
router.post('/bulk', bulkCreateStores);
router.post('/deduplicate', deduplicateStores);

// Store routes
router.route('/')
  .get(getAllStores)
  .post(createStore);

router.route('/:id')
  .get(getStoreById)
  .put(updateStore)
  .delete(deleteStore);

module.exports = router;
