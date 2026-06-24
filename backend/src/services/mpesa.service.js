const axios = require('axios');

const getBaseUrl = () => {
  return process.env.MPESA_ENV === 'production'
    ? 'https://api.safaricom.co.ke'
    : 'https://sandbox.safaricom.co.ke';
};

const getAccessToken = async () => {
  const auth = Buffer.from(
    `${process.env.MPESA_CONSUMER_KEY}:${process.env.MPESA_CONSUMER_SECRET}`
  ).toString('base64');

  const response = await axios.get(
    `${getBaseUrl()}/oauth/v1/generate?grant_type=client_credentials`,
    { headers: { Authorization: `Basic ${auth}` } }
  );

  return response.data.access_token;
};

const getTimestamp = () => {
  const now = new Date();
  return (
    now.getFullYear().toString() +
    String(now.getMonth() + 1).padStart(2, '0') +
    String(now.getDate()).padStart(2, '0') +
    String(now.getHours()).padStart(2, '0') +
    String(now.getMinutes()).padStart(2, '0') +
    String(now.getSeconds()).padStart(2, '0')
  );
};

const stkPush = async ({ phone, amount, orderId }) => {
  const token = await getAccessToken();
  const timestamp = getTimestamp();
  const shortcode = process.env.MPESA_SHORTCODE;
  const passkey = process.env.MPESA_PASSKEY;

  const password = Buffer.from(
    `${shortcode}${passkey}${timestamp}`
  ).toString('base64');

  // Format phone — ensure it starts with 254
  let formattedPhone = phone.toString().replace(/\D/g, '');
  if (formattedPhone.startsWith('0')) {
    formattedPhone = '254' + formattedPhone.substring(1);
  }
  if (formattedPhone.startsWith('+')) {
    formattedPhone = formattedPhone.substring(1);
  }

  const response = await axios.post(
    `${getBaseUrl()}/mpesa/stkpush/v1/processrequest`,
    {
      BusinessShortCode: shortcode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Math.ceil(amount),
      PartyA: formattedPhone,
      PartyB: shortcode,
      PhoneNumber: formattedPhone,
      CallBackURL: process.env.MPESA_CALLBACK_URL,
      AccountReference: `SwiftDrop-${orderId}`,
      TransactionDesc: 'SwiftDrop Order Payment',
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    }
  );

  return response.data;
};

const stkQuery = async (checkoutRequestId) => {
  const token = await getAccessToken();
  const timestamp = getTimestamp();
  const shortcode = process.env.MPESA_SHORTCODE;
  const passkey = process.env.MPESA_PASSKEY;

  const password = Buffer.from(
    `${shortcode}${passkey}${timestamp}`
  ).toString('base64');

  const response = await axios.post(
    `${getBaseUrl()}/mpesa/stkpushquery/v1/query`,
    {
      BusinessShortCode: shortcode,
      Password: password,
      Timestamp: timestamp,
      CheckoutRequestID: checkoutRequestId,
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    }
  );

  return response.data;
};

module.exports = { stkPush, getAccessToken, stkQuery };