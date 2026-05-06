const express = require('express');
const router = express.Router();
const { getAlerts, getCategories, getAlertById } = require('../controllers/alertsController');

router.get('/categories', getCategories);
router.get('/:id', getAlertById);
router.get('/', getAlerts);

module.exports = router;