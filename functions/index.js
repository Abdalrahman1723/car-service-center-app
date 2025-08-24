/**
 * Import and initialize the Firebase Admin SDK.
 * The Admin SDK is required to interact with other Firebase services
 * and send push notifications.
 */
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

// Import Cloud Functions v2 and logger.
// This resolves the 'no-unused-vars' error you were seeing.
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");

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
    logger.info(`New invoice created with ID: ${invoiceId}`, { newInvoice });

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

      const tokens = userTokensSnapshot.docs.map((doc) => doc.data().token);
      logger.info(`Found ${tokens.length} tokens for user ${userIdToNotify}.`);

      // Create the notification message payload.
      const message = {
        notification: {
          title: "New Invoice Created",
          body: `A new invoice (${invoiceId}) has been added to the database.`,
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
  }
);

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Cloud Function to send FCM notifications
exports.sendTimelineNotification = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const notificationData = snap.data();

    try {
      // Get all manager users
      const managersSnapshot = await admin
        .firestore()
        .collection("users")
        .where("role", "==", "manager")
        .get();

      if (managersSnapshot.empty) {
        console.log("No managers found");
        return null;
      }

      const tokens = [];
      managersSnapshot.forEach((doc) => {
        const fcmToken = doc.data().fcmToken;
        if (fcmToken) {
          tokens.push(fcmToken);
        }
      });

      if (tokens.length === 0) {
        console.log("No FCM tokens found for managers");
        return null;
      }

      // Prepare notification message
      const message = {
        notification: {
          title: notificationData.title,
          body: notificationData.body,
        },
        data: {
          eventType: notificationData.eventType,
          eventId: notificationData.eventId,
          payload: `${notificationData.eventType}:${notificationData.eventId}`,
        },
        tokens: tokens,
        android: {
          notification: {
            channelId: "car_service_notifications",
            priority: "high",
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      // Send notification
      const response = await admin.messaging().sendMulticast(message);

      console.log("Successfully sent messages:", response.successCount);
      console.log("Failed to send messages:", response.failureCount);

      return response;
    } catch (error) {
      console.error("Error sending notification:", error);
      throw error;
    }
  });

// Cloud Function to handle timeline events
exports.handleTimelineEvent = functions.firestore
  .document("timeline_events/{eventId}")
  .onCreate(async (snap, context) => {
    const eventData = snap.data();

    try {
      // Create notification document
      await admin
        .firestore()
        .collection("notifications")
        .add({
          title: eventData.title,
          body: eventData.description,
          eventType: eventData.type,
          eventId: eventData.id,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          metadata: eventData.metadata || {},
          read: false,
        });

      return null;
    } catch (error) {
      console.error("Error handling timeline event:", error);
      throw error;
    }
  });

// HTTP function to send test notifications
exports.sendTestNotification = functions.https.onRequest(async (req, res) => {
  try {
    const { title, body, eventType, eventId } = req.body;

    if (!title || !body || !eventType || !eventId) {
      res.status(400).json({ error: "Missing required fields" });
      return;
    }

    // Get all manager users
    const managersSnapshot = await admin
      .firestore()
      .collection("users")
      .where("role", "==", "manager")
      .get();

    if (managersSnapshot.empty) {
      res.status(404).json({ error: "No managers found" });
      return;
    }

    const tokens = [];
    managersSnapshot.forEach((doc) => {
      const fcmToken = doc.data().fcmToken;
      if (fcmToken) {
        tokens.push(fcmToken);
      }
    });

    if (tokens.length === 0) {
      res.status(404).json({ error: "No FCM tokens found" });
      return;
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        eventType: eventType,
        eventId: eventId,
        payload: `${eventType}:${eventId}`,
      },
      tokens: tokens,
    };

    const response = await admin.messaging().sendMulticast(message);

    res.json({
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    });
  } catch (error) {
    console.error("Error sending test notification:", error);
    res.status(500).json({ error: error.message });
  }
});
