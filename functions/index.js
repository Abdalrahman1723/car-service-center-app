/**
 * Import and initialize the Firebase Admin SDK.
 * The Admin SDK is required to interact with other Firebase services
 * and send push notifications.
 */
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

// Import Cloud Functions v2 and logger.
// This resolves the 'no-unused-vars' error you were seeing.
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {logger} = require("firebase-functions");

// Initialize the Firebase Admin app.
initializeApp();

// Get a reference to the Firestore and Messaging services.
const firestore = getFirestore();
const messaging = getMessaging();

/**
 * Cloud Function that listens for a new document creation
 * in the 'invoices' collection.
 * You can change this to any collection you want to monitor,
 * like 'clients', 'employees', etc.
 * The wildcard {invoiceId} listens for any new document created.
 */
exports.onNewInvoiceCreated = onDocumentCreated(
    "invoices/{invoiceId}",
    async (event) => {
      // Get the new invoice data from the event snapshot.
      const newInvoice = event.data.data();
      const invoiceId = event.params.invoiceId;

      // Log the new invoice ID for debugging purposes.
      logger.info(`New invoice created with ID: ${invoiceId}`, {newInvoice});

      // You need a way to get the user's device token to send the notification.
      // We'll assume you have a 'users' collection where each user has a
      // subcollection of their device tokens. A good practice is to store
      // tokens in a path like: users/{userId}/tokens/{tokenId}.
      // In a real-world app, you would have a more robust way to determine
      // which user should receive
      //  the notification based on the transaction data.

      // For this example, let's assume you're sending a notification
      // to a specific user. You would get their ID from the newInvoice
      // object, for example: `newInvoice.userId`
      const userIdToNotify = "specificUserIdHere";
      // Replace with logic to get the user's ID.

      // Get the device token(s) for the user to be notified.
      try {
        const userTokensSnapshot = await firestore
            .collection(`users/${userIdToNotify}/tokens`)
            .get();

        // Check if the user has any tokens.
        if (userTokensSnapshot.empty) {
          logger.info(`User ${userIdToNotify} has no device tokens. 
        No notification sent.`);
          return;
        }

        const tokens =
        userTokensSnapshot.docs.map((doc) => doc.data().token);
        logger.
            info(`Found ${tokens.length} tokens for user ${userIdToNotify}.`);

        // Create the notification message payload.
        const message = {
          notification: {
            title: "New Invoice Created",
            body:
            `A new invoice (${invoiceId}) has been added to the database.`,
          },
          tokens: tokens, // Send to all tokens found for the user.
        };

        // Send the notification.
        const response = await messaging.sendEachForMulticast(message);
        logger.info(`Successfully sent ${response.successCount} messages. 
      Failed to send ${response.failureCount} messages.`);

        // Log the response for further debugging.
        if (response.failureCount > 0) {
          response.responses.forEach((resp, idx) => {
            if (!resp.success) {
              logger.error(`Failed to send to token ${tokens[idx]}: 
            ${resp.error}`);
            }
          });
        }
      } catch (error) {
        logger.error("Error fetching tokens or sending message:", error);
      }
    });
