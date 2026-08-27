const express = require('express');
const cors = require('cors');
const healthRoutes = require('./routes/health.routes');
const hospitalRoutes = require('./routes/hospital.routes');
const adminRoutes = require('./routes/admin.routes');
const notFoundHandler = require('./middleware/notFound.middleware');
const errorHandler = require('./middleware/error.middleware');

const app = express();

// 1. Enable express.json() & urlencoded body parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 2. Enable Cross-Origin Resource Sharing (CORS)
app.use(
  cors({
    origin: true, // Allow all localhost origins dynamically from Flutter Web
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-admin-id', 'Accept'],
  })
);
app.options('*', cors());

// 3. Application Routes
app.use('/health', healthRoutes);
app.use('/api/hospitals', hospitalRoutes);
app.use('/api/admin', adminRoutes);

// Temporary test route to verify centralized error-handling middleware
app.get('/test-error', (req, res, next) => {
  const testError = new Error('Test error: Centralized error handling is working properly');
  testError.statusCode = 500;
  next(testError);
});

// 4. 404 Not Found Middleware (catches any unmatched routes)
app.use(notFoundHandler);

// 5. Centralized Error-Handling Middleware (catches all forwarded errors)
app.use(errorHandler);

module.exports = app;
