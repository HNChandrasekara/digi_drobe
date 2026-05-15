const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const nodemailer = require('nodemailer');

admin.initializeApp();

const app = express();
app.use(cors({ origin: true }));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

/**
 * Simple PayHere IPN/notify handler
 * - Stores raw payload to Firestore collection `payhere_notifications`
 * - Attempts a basic MD5 signature verification if `PAYHERE_MERCHANT_SECRET` is configured
 *
 * Notes:
 * - PayHere sends form-encoded POSTs. We accept both JSON and urlencoded bodies.
 * - Signature calculation varies by integration; adjust verification logic if PayHere specifies a different formula.
 */
app.post('/payhere/notify', async (req, res) => {
  try {
    const payload = Object.keys(req.body).length ? req.body : {};

    const merchantSecret = process.env.PAYHERE_MERCHANT_SECRET || (functions.config() && functions.config().payhere && functions.config().payhere.secret) || '';

    // Try to extract common fields in PayHere IPN
    const merchantId = payload.merchant_id || payload.merchant || '';
    const orderId = payload.order_id || payload.orderid || payload.order || '';
    const status = payload.status_code || payload.status || payload.payment_status || '';
    const md5sig = payload.md5sig || payload.md5 || '';

    let verified = false;
    if (merchantSecret && md5sig) {
      // Basic verification: md5(merchant_id + order_id + status + merchant_secret)
      const expected = crypto.createHash('md5').update(String(merchantId) + String(orderId) + String(status) + String(merchantSecret)).digest('hex');
      if (expected === String(md5sig)) {
        verified = true;
      }
    }

    const record = {
      payload,
      verified,
      receivedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await admin.firestore().collection('payhere_notifications').add(record);

    // If we have an email and the payment looks successful, send a confirmation email.
    try {
      // Try to find a likely customer email in common fields
      const customerEmail = payload.customer_email || payload.email || payload.buyer_email || payload.payer_email || payload.customer || '';

      // Normalize status values that commonly indicate a completed payment
      const statusNormalized = String(status).toLowerCase();
      const paidStates = ['2', 'paid', 'completed', 'complete', 'success'];
      const isPaid = paidStates.includes(statusNormalized);

      const mailHost = process.env.MAIL_HOST || (functions.config() && functions.config().mail && functions.config().mail.host) || '';
      const mailPort = process.env.MAIL_PORT || (functions.config() && functions.config().mail && functions.config().mail.port) || '';
      const mailUser = process.env.MAIL_USER || (functions.config() && functions.config().mail && functions.config().mail.user) || '';
      const mailPass = process.env.MAIL_PASS || (functions.config() && functions.config().mail && functions.config().mail.pass) || '';

      if (customerEmail && isPaid && mailHost && mailPort && mailUser && mailPass) {
        const transporter = nodemailer.createTransport({
          host: mailHost,
          port: Number(mailPort),
          auth: {
            user: mailUser,
            pass: mailPass,
          },
        });

        const amount = payload.amount || payload.total || payload.total_amount || payload.order_amount || '';
        const orderIdForEmail = orderId || payload.order_id || payload.order || '';

        const mailOptions = {
          from: `"Digi Drobe" <${mailUser}>`,
          to: customerEmail,
          subject: `Payment received for order ${orderIdForEmail}`,
          text: `We have received a payment for order ${orderIdForEmail}.\nAmount: ${amount}\nStatus: ${status}\n\nThank you for shopping with Digi Drobe.`,
        };

        await transporter.sendMail(mailOptions);
        console.log('[PayHereNotify] Sent confirmation email to', customerEmail);
      }
    } catch (mailErr) {
      console.error('[PayHereNotify] Failed to send confirmation email:', mailErr);
    }

    // You may want to update an orders collection to mark payment successful
    // Example (optional):
    // if (verified && status === '2') { // status 2 might mean paid depending on PayHere docs
    //   await admin.firestore().collection('orders').doc(orderId).set({ paid: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    // }

    // Respond with 200 OK as PayHere expects
    return res.status(200).send('OK');
  } catch (err) {
    console.error('[PayHereNotify] Error handling notify:', err);
    return res.status(500).send('ERROR');
  }
});

exports.payhereNotify = functions.region('us-central1').https.onRequest(app);
