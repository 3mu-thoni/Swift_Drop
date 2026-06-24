const fetch = require('node-fetch');

const sendNotification = async ({ token, title, body, data = {} }) => {
  if (!token) return;

  try {
    const response = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `key=${process.env.FCM_SERVER_KEY}`,
      },
      body: JSON.stringify({
        to: token,
        notification: { title, body },
        data,
      }),
    });

    const result = await response.json();
    console.log('📱 Notification sent:', result);
  } catch (error) {
    console.error('📱 Notification error:', error.message);
  }
};

module.exports = { sendNotification };