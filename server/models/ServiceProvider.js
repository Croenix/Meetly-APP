const mongoose = require('mongoose');

const serviceProviderSchema = new mongoose.Schema(
  {
    customId: {
      type: String,
      unique: true,
      index: true,
      default: () => `pro_${Math.floor(100000 + Math.random() * 900000)}`,
    },
    userId: {
      type: String,
      required: [true, 'User ID is required'],
      index: true,
    },
    businessName: {
      type: String,
      required: [true, 'Business name is required'],
      trim: true,
    },
    profession: {
      type: String,
      required: [true, 'Profession is required'],
      trim: true,
    },
    rating: {
      type: Number,
      default: 0.0,
      min: 0,
      max: 5,
    },
    reviewCount: {
      type: Number,
      default: 0,
    },
    distance: {
      type: Number,
      default: 0.0,
    },
    startingPrice: {
      type: Number,
      required: [true, 'Starting price is required'],
      min: 0,
    },
    verified: {
      type: Boolean,
      default: false,
    },
    bio: {
      type: String,
      default: '',
    },
    portfolioImages: {
      type: [String],
      default: [],
    },
    workingHours: {
      type: Map,
      of: new mongoose.Schema(
        {
          available: { type: Boolean, default: true },
          start: { type: String, default: '09:00' },
          end: { type: String, default: '18:00' },
        },
        { _id: false }
      ),
      default: {},
    },
    serviceArea: {
      type: String,
      default: 'Citywide',
    },
    responseTime: {
      type: String,
      default: 'Within 1 hour',
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      index: true,
    },
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
    },
    location: {
      type: String,
      required: [true, 'Location is required'],
    },
    verificationStatus: {
      type: String,
      enum: ['not_submitted', 'under_review', 'verified', 'rejected'],
      default: 'not_submitted',
      index: true,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Virtual mapper for frontend 'id' compatibility
serviceProviderSchema.virtual('id').get(function () {
  return this.customId || this._id.toHexString();
});

module.exports = mongoose.model('ServiceProvider', serviceProviderSchema);
