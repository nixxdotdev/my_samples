const express = require('express');
const router = express.Router();
const sampleController = require('../controllers/sampleController');

router.get('/', (req, res, next) => sampleController.getSamples(req, res, next));
router.get('/:id', (req, res, next) => sampleController.getSampleById(req, res, next));
router.post('/', (req, res, next) => sampleController.createSample(req, res, next));
router.patch('/:id/status', (req, res, next) => sampleController.updateSampleStatus(req, res, next));
router.delete('/:id', (req, res, next) => sampleController.deleteSample(req, res, next));

module.exports = router;
