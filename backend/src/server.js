const app = require('./app');
const env = require('./config/env');

const PORT = env.port;

const server = app.listen(PORT, () => {
  console.log(`=============================================`);
  console.log(` MediKiosk Backend Service Started`);
  console.log(` Environment : ${env.nodeEnv}`);
  console.log(` Server URL  : http://localhost:${PORT}`);
  console.log(` Health Check: http://localhost:${PORT}/health`);
  console.log(`=============================================`);
});

module.exports = server;
