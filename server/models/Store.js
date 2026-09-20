const mongoose = require('mongoose');

const storeSchema = new mongoose.Schema(
  {
    customId: {
      type: String,
      unique: true,
      index: true,
      default: () => `biz_${Math.floor(100000 + Math.random() * 900000)}`,
    },
    name: {
      type: String,
      required: [true, 'Store name is required'],
      trim: true,
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      index: true,
    },
    pincode: {
      type: String,
      required: [true, 'Pincode is required'],
      trim: true,
    },
    address: {
      type: String,
      required: [true, 'Address is required'],
    },
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
    },
    rating: {
      type: Number,
      default: 4.5,
      min: 0,
      max: 5,
    },
    imageUrl: {
      type: String,
      default: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
    },
    latitude: {
      type: Number,
      default: 9.9312,
    },
    longitude: {
      type: Number,
      default: 76.2673,
    },
    city: {
      type: String,
      required: [true, 'City is required'],
      index: true,
    },
    isOpen: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Virtual mapper for frontend 'id' compatibility
storeSchema.virtual('id').get(function () {
  return this.customId || this._id.toHexString();
});

module.exports = mongoose.model('Store', storeSchema);
