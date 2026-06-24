const { stkPush, stkQuery } = require('../services/mpesa.service');
const Order = require('../models/Order');

exports.initiateMpesaPayment = async (req, res) => {
  try {
    const { phone, orderId } = req.body;

    if (!phone || !orderId) {
      return res.status(400).json({
        message: 'Phone number and order ID are required',
      });
    }

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    console.log(`💳 M-Pesa STK Push: ${phone} - KSh ${order.total}`);

    const result = await stkPush({
      phone,
      amount: order.total,
      orderId,
    });

    console.log('✅ STK Push response:', result);

    // Save checkout request id for later querying/matching
    order.mpesaCheckoutRequestId = result.CheckoutRequestID;
    await order.save();

    res.json({
      message: 'STK Push sent successfully',
      checkoutRequestId: result.CheckoutRequestID,
      merchantRequestId: result.MerchantRequestID,
    });
  } catch (error) {
    console.error('❌ M-Pesa error:', error.message);
    res.status(500).json({
      message: 'Payment initiation failed',
      error: error.message,
    });
  }
};

exports.mpesaCallback = async (req, res) => {
  try {
    const { Body } = req.body;
    const { stkCallback } = Body;

    console.log('📱 M-Pesa callback:', JSON.stringify(stkCallback));

    const checkoutRequestId = stkCallback.CheckoutRequestID;

    if (stkCallback.ResultCode === 0) {
      const items = stkCallback.CallbackMetadata.Item;
      const amount = items.find((i) => i.Name === 'Amount')?.Value;
      const mpesaCode = items.find(
        (i) => i.Name === 'MpesaReceiptNumber'
      )?.Value;
      const phone = items.find(
        (i) => i.Name === 'PhoneNumber'
      )?.Value;

      console.log(
        `✅ Payment received: KSh ${amount} from ${phone} - ${mpesaCode}`
      );

      // Match order by the checkout request ID saved at initiation
      const order = await Order.findOneAndUpdate(
        { mpesaCheckoutRequestId: checkoutRequestId },
        {
          paymentStatus: 'paid',
          mpesaTransactionId: mpesaCode,
          status: 'confirmed',
          $push: {
            statusHistory: {
              status: 'confirmed',
              note: `M-Pesa payment received: ${mpesaCode}`,
            },
          },
        },
        { new: true }
      );

      if (order) {
        console.log('✅ Order updated:', order._id);

        // Notify via socket
        const io = req.app.get('io');
        if (io) {
          io.to(`order:${order._id}`).emit('status:update', {
            orderId: order._id,
            status: 'confirmed',
          });
        }
      } else {
        console.log(
          '⚠️ No order found with checkoutRequestId:',
          checkoutRequestId
        );
      }
    } else {
      console.log('❌ Payment failed:', stkCallback.ResultDesc);

      // Mark payment as failed
      await Order.findOneAndUpdate(
        { mpesaCheckoutRequestId: checkoutRequestId },
        { paymentStatus: 'failed' }
      );
    }

    res.json({ ResultCode: 0, ResultDesc: 'Success' });
  } catch (error) {
    console.error('Callback error:', error.message);
    res.json({ ResultCode: 0, ResultDesc: 'Success' });
  }
};

exports.checkPaymentStatus = async (req, res) => {
  try {
    const order = await Order.findById(req.params.orderId);
    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // If already paid, return immediately
    if (order.paymentStatus === 'paid') {
      return res.json({
        paymentStatus: order.paymentStatus,
        status: order.status,
      });
    }

    // Actively query Safaricom as a fallback if callback hasn't arrived
    if (order.mpesaCheckoutRequestId) {
      try {
        const result = await stkQuery(order.mpesaCheckoutRequestId);
        console.log('🔍 STK Query result:', result);

        if (result.ResultCode === '0') {
          order.paymentStatus = 'paid';
          order.status = 'confirmed';
          order.statusHistory.push({
            status: 'confirmed',
            note: 'M-Pesa payment confirmed via query',
          });
          await order.save();
        }
      } catch (queryError) {
        console.log('Query not ready yet:', queryError.message);
      }
    }

    res.json({
      paymentStatus: order.paymentStatus,
      status: order.status,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};