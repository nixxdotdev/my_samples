const express = require('express');
const router = express.Router();
const analyticsController = require('../controllers/analyticsController');

router.get('/summary', (req, res, next) => analyticsController.getSummary(req, res, next));

module.exports = router;
