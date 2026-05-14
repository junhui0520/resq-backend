const express = require('express');
const router = express.Router();
const { createUser, getSettings, updateSettings } = require('../controllers/usersController');
const {
  upsertQrProfile,
  getMyProfile,
  addEmergencyContact,
  updateEmergencyContact,
  deleteEmergencyContact,
  addMedicalInfo,
  deleteMedicalInfo
} = require('../controllers/qrController');

router.post('/', createUser);
router.get('/:userId/settings', getSettings);
router.put('/:userId/settings', updateSettings);
router.post('/:userId/qr-profile', upsertQrProfile);
router.get('/:userId/qr-profile', getMyProfile);
router.post('/:userId/emergency-contacts', addEmergencyContact);
router.put('/:userId/emergency-contacts/:id', updateEmergencyContact);
router.delete('/:userId/emergency-contacts/:id', deleteEmergencyContact);
router.post('/:userId/medical-infos', addMedicalInfo);
router.delete('/:userId/medical-infos/:id', deleteMedicalInfo);

module.exports = router;