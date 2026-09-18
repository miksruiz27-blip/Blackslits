const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const fs = require('fs');
const path = require('path');

dotenv.config();

const authRouter = require('./routes/auth');
const screenRouter = require('./routes/screen');
const searchesRouter = require('./routes/searches');
const sourcesRouter = require('./routes/sources');
const syncRouter = require('./routes/sync');
const { requireAuth } = require('./middleware/auth');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRouter);

app.use('/api/screen', requireAuth, screenRouter);
app.use('/api/searches', requireAuth, searchesRouter);
app.use('/api/sources', sourcesRouter);
app.use('/api/sync', syncRouter);

app.get('/api/health', (req, res) => res.json({ status: 'UP' }));

// Serves the Flutter web build (npm run build:web) so the app and API share
// one Railway domain — no CORS setup needed between separate services.
// Skipped in dev when nobody has run the build yet.
const WEB_BUILD_DIR = path.join(__dirname, '..', 'build', 'web');
if (fs.existsSync(path.join(WEB_BUILD_DIR, 'index.html'))) {
  app.use(express.static(WEB_BUILD_DIR));
  app.get(/^\/(?!api\/).*/, (req, res) => res.sendFile(path.join(WEB_BUILD_DIR, 'index.html')));
}

app.use((req, res) => res.status(404).json({ error: 'Ruta no encontrada.' }));

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error('[App] Unhandled error:', err);
  res.status(500).json({ error: 'Error interno del servidor.' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`[App] AML/KYC screening API running on http://localhost:${PORT}`);
  });
}

module.exports = app;
