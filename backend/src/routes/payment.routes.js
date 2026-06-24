const router = require('express').Router();
const {
  initiateMpesaPayment,
  mpesaCallback,
  checkPaymentStatus,
} = require('../controllers/payment.controller');
const { protect } = require('../middleware/auth.middleware');

router.post('/mpesa/stk-push', protect, initiateMpesaPayment);
router.post('/mpesa/callback', mpesaCallback);
router.get('/status/:orderId', protect, checkPaymentStatus);

module.exports = router;