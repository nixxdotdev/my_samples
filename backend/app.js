const express = require('express');
const swaggerUi = require('swagger-ui-express');
const swaggerJSDoc = require('swagger-jsdoc');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Configure swagger-jsdoc to scan all YAML files in the swagger folder
const options = {
  swaggerDefinition: require('yamljs').load(path.join(__dirname, 'openapi/swagger.yaml')),
  // Glob patterns pointing to separated path YAML files
  apis: ['./openapi/paths/*.yaml'],
};

const swaggerSpec = swaggerJSDoc(options);

// Serve Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
  console.log(`Swagger UI available at http://localhost:${PORT}/api-docs`);
});