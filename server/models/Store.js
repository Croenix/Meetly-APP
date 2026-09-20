const mongoose = require('mongoose');

const reviewSubSchema = new mongoose.Schema(
  {
    author: { type: String, default: 'Google User' },
    rating: { type: Number, default: 5 },
    text: { type: String, default: '' },
    time: { type: String, default: '' },
  },
  { _id: false }
);

const storeSchema = new mongoose.Schema(
  {
    customId: {
      type: String,
      unique: true,
      index: true,
      default: () => `biz_${Math.floor(100000 + Math.random() * 900000)}`,
    },
    placeId: {
      type: String,
      index: true,
      default: '',
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
    secondaryCategories: {
      type: [String],
      default: [],
    },
    pincode: {
      type: String,
      required: [true, 'Pincode is required'],
      trim: true,
      index: true,
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
    reviewCount: {
      type: Number,
      default: 0,
    },
    reviews: {
      type: [reviewSubSchema],
      default: [],
    },
    imageUrl: {
      type: String,
      default: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
    },
    images: {
      type: [String],
      default: [],
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
    workingHours: {
      type: String,
      default: '08:00 AM - 08:00 PM',
    },
    isOpen: {
      type: Boolean,
      default: true,
    },
    isOpenNow: {
      type: Boolean,
      default: true,
    },
    websiteUrl: {
      type: String,
      default: '',
    },
    mapUrl: {
      type: String,
      default: '',
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Compound index to support case-insensitive deduplication by name + pincode
storeSchema.index({ name: 1, pincode: 1 });

// Virtual mapper for frontend 'id' compatibility
storeSchema.virtual('id').get(function () {
  return this.customId || this._id.toHexString();
});

module.exports = mongoose.model('Store', storeSchema);
