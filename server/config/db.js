const mongoose = require('mongoose');

/**
 * Establishes a secure connection to MongoDB using Mongoose.
 */
const connectDB = async () => {
  try {
    const connUri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/meetly';
    
    // Configure connection options for security and stability
    const options = {
      autoIndex: process.env.NODE_ENV !== 'production',
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    };

    const conn = await mongoose.connect(connUri, options);

    console.log(`[Database] MongoDB Connected: ${conn.connection.host}/${conn.connection.name}`);

    mongoose.connection.on('error', (err) => {
      console.error(`[Database Error] MongoDB connection error: ${err.message}`);
    });

    mongoose.connection.on('disconnected', () => {
      console.warn('[Database Warning] MongoDB disconnected. Attempting reconnect...');
    });

    return conn;
  } catch (error) {
    console.error(`[Database Critical] Could not connect to MongoDB: ${error.message}`);
    // Non-fatal fallback so server doesn't crash completely if DB is offline locally
    return null;
  }
};

module.exports = connectDB;
