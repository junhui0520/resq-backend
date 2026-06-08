const express = require('express');
const cors = require('cors');
require('dotenv').config();

// ✅ 추가
const { startDisasterScheduler } = require('./controllers/disasterController');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'resQ API 서버 정상 작동 중 🚀' });
});

// 라우터
app.use('/api/alerts', require('./routes/alerts'));
app.use('/api/users', require('./routes/users'));
app.use('/api/qr', require('./routes/qr'));
app.use('/api/embassies', require('./routes/embassy'));
app.use('/api/emergency-numbers', require('./routes/emergencyNumbers'));
app.use('/api/safety-manuals', require('./routes/safetyManuals'));
app.use('/api/regions', require('./routes/regions'));
app.use('/api/disaster', require('./routes/disaster')); // ✅ 추가

app.listen(PORT, () => {
  console.log(`✅ 서버 실행 중: http://localhost:${PORT}`);
  startDisasterScheduler(); // ✅ 추가
});

app.use((req, res, next) => {
  console.log(`[${new Date().toLocaleTimeString()}] ${req.method} ${req.url}`);
  next();
});