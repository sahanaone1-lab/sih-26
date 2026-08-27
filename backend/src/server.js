const app = require('./app');
const env = require('./config/env');
const http = require('http');
const { Server } = require('socket.io');

const PORT = env.port;

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: true,
    credentials: true,
  },
});

app.set('io', io); // Make io available in routes via req.app.get('io')

io.on('connection', (socket) => {
  console.log(`[Socket.IO] Client connected: ${socket.id}`);
  
  // Room joining logic for consultations
  socket.on('join_session', (sessionId) => {
    socket.join(`session_${sessionId}`);
    console.log(`[Socket.IO] Client ${socket.id} joined session_${sessionId}`);
  });
  
  socket.on('disconnect', () => {
    console.log(`[Socket.IO] Client disconnected: ${socket.id}`);
  });
});

server.listen(PORT, () => {
  console.log(`=============================================`);
  console.log(` MediKiosk Backend Service Started`);
  console.log(` Environment : ${env.nodeEnv}`);
  console.log(` Server URL  : http://localhost:${PORT}`);
  console.log(` Health Check: http://localhost:${PORT}/health`);
  console.log(` Socket.IO   : Active`);
  console.log(`=============================================`);
});

module.exports = server;
