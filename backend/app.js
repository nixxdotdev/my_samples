const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const swaggerUi = require('swagger-ui-express');
const swaggerJSDoc = require('swagger-jsdoc');
const yaml = require('yamljs');

const requestLogger = require('./api/middlewares/requestLogger');
const errorHandler = require('./api/middlewares/errorHandler');
const apiRoutes = require('./api/routes');

const app = express();
const PORT = process.env.PORT || 3000;

// Enable Cross-Origin Resource Sharing (CORS) for all origins
app.use(cors());

// Parse incoming JSON payloads
app.use(express.json());

// Request logging middleware
app.use(requestLogger);

// Configure OpenAPI & Swagger UI
let swaggerSpec = null;
try {
  const swaggerDefinition = yaml.load(path.join(__dirname, 'openapi/swagger.yaml'));
  swaggerDefinition.paths = swaggerDefinition.paths || {};

  // 1. Direct merge from openapi/paths YAML files (immune to Windows backslash glob issues)
  const pathsDir = path.join(__dirname, 'openapi/paths');
  if (fs.existsSync(pathsDir)) {
    fs.readdirSync(pathsDir).forEach((file) => {
      if (file.endsWith('.yaml') || file.endsWith('.yml')) {
        const filePath = path.join(pathsDir, file);
        try {
          const content = yaml.load(filePath);
          if (content && typeof content === 'object') {
            Object.assign(swaggerDefinition.paths, content);
          }
        } catch (err) {
          console.warn(`[Swagger] Failed to parse ${file}:`, err.message);
        }
      }
    });
  }

  // 2. Also pass through swagger-jsdoc with normalized forward slashes for any future JSDoc comments
  const globPattern = path.join(__dirname, 'openapi/paths/*.yaml').replace(/\\/g, '/');
  swaggerSpec = swaggerJSDoc({
    swaggerDefinition,
    apis: [globPattern],
  });

  // Serve Swagger UI
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

  // Serve raw JSON specification
  app.get('/api-docs.json', (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(swaggerSpec);
  });
} catch (e) {
  console.warn('[Swagger] Failed to initialize Swagger documentation:', e.message);
}

// Root route
app.get('/', (req, res) => {
  res.json({
    name: 'SampleFlow Creator API',
    status: 'online',
    docs: '/api-docs',
    endpoints: {
      samples: '/api/samples',
      notifications: '/api/notifications',
      analytics: '/api/analytics/summary',
      health: '/api/health',
    },
  });
});

// Mount core API router
app.use('/api', apiRoutes);

// Centralized error handler
app.use(errorHandler);

// Start server if executed directly
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
    console.log(`Swagger UI documentation at http://localhost:${PORT}/api-docs`);
  });
}

module.exports = app;
