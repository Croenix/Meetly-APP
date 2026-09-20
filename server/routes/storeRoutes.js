const express = require('express');
const router = express.Router();
const {
  getAllStores,
  getStoreById,
  createStore,
  updateStore,
  deleteStore,
} = require('../controllers/storeController');

// Store routes
router.route('/')
  .get(getAllStores)
  .post(createStore);

router.route('/:id')
  .get(getStoreById)
  .put(updateStore)
  .delete(deleteStore);

module.exports = router;
