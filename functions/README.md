# Firebase Functions for Digi Drobe

This folder contains a Cloud Function to receive PayHere notifications (IPN) and persist them to Firestore.

Setup & Deploy

1. Install Firebase CLI and login:

```bash
npm install -g firebase-tools
firebase login
```

2. Initialize (if not already):

```bash
cd functions
npm install
# If you haven't initialized functions in the project yet:
# firebase init functions
```

3. Provide PayHere secret (optional, for verification):

```bash
# Using Firebase config
firebase functions:config:set payhere.secret="YOUR_PAYHERE_SECRET"
```

4. Deploy functions:

```bash
firebase deploy --only functions:payhereNotify
```

Notes

- The function writes notifications to Firestore `payhere_notifications` collection.
- Adjust signature verification logic in `index.js` if PayHere documentation specifies a different formula.

Testing

You can test the endpoint locally with `firebase emulators:start` or send a POST to the deployed URL (found in the deploy output).

Example curl:

```bash
curl -X POST https://us-central1-YOUR_PROJECT.cloudfunctions.net/payhereNotify/payhere/notify \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "merchant_id=123&order_id=ORDER-1&status_code=2&md5sig=..."
```
