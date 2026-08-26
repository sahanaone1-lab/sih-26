const env = require('../config/env');

/**
 * Centralized Error-Handling Middleware
 * Intercepts all synchronous and asynchronous errors forwarded via next(err) or thrown
 */
const errorHandler = (err, req, res, next) => {
  const statusCode = err.statusCode || err.status || 500;

  const errorResponse = {
    success: false,
    message: err.message || 'Internal Server Error',
  };

  // Attach stack trace only in development mode to aid debugging without leaking details in production
  if (!env.isProduction && env.nodeEnv === 'development') {
    errorResponse.stack = err.stack;
  }

  res.status(statusCode).json(errorResponse);
};

module.exports = errorHandler;
