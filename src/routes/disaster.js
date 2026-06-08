const express = require('express');
const router = express.Router();
const { fetchAndSaveDisasterAlerts } = require('../controllers/disasterController');

// 수동으로 즉시 재난문자 데이터 가져오기 (테스트용)
router.post('/fetch', async (req, res) => {
  try {
    await fetchAndSaveDisasterAlerts();
    res.json({ success: true, message: '재난문자 데이터 가져오기 완료' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;