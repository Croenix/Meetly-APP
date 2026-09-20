/**
 * Standardized API Response and Error Handling Utilities
 */

/**
 * Sends a structured success JSON response.
 */
const successResponse = (res, statusCode = 200, message = 'Success', data = null, meta = null) => {
  const response = {
    status: 'success',
    statusCode,
    message,
    data,
  };
  if (meta) {
    response.meta = meta;
  }
  return res.status(statusCode).json(response);
};

/**
 * Sends a structured error JSON response.
 */
const errorResponse = (res, statusCode = 500, message = 'Internal Server Error', error = null) => {
  const response = {
    status: 'error',
    statusCode,
    message,
  };
  if (error && process.env.NODE_ENV !== 'production') {
    response.error = error;
  }
  return res.status(statusCode).json(response);
};

/**
 * Async handler wrapper to catch unhandled errors in route controllers.
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = {
  successResponse,
  errorResponse,
  asyncHandler,
};
