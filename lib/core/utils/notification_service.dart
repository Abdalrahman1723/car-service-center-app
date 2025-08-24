import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static const String _channelId = 'car_service_notifications';
  static const String _channelName = 'Car Service Updates';
  static const String _channelDescription =
      'Notifications for car service events';

  Future<void> init() async {
    await _fcm.requestPermission();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    String? token = await _fcm.getToken();
    if (token != null && FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'fcmToken': token}, SetOptions(merge: true));
    }
    _fcm.onTokenRefresh.listen((token) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({'fcmToken': token}, SetOptions(merge: true));
    });
  }

  // Send notification for timeline events
  Future<void> sendTimelineEventNotification({
    required String title,
    required String body,
    required String eventType,
    required String eventId,
    required Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get all manager users
      final managersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'manager')
          .get();

      if (managersSnapshot.docs.isEmpty) return;

      // Prepare notification data
      final notificationData = {
        'title': title,
        'body': body,
        'eventType': eventType,
        'eventId': eventId,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': metadata ?? {},
      };

      // Send to each manager
      for (final managerDoc in managersSnapshot.docs) {
        final fcmToken = managerDoc.data()['fcmToken'] as String?;
        if (fcmToken != null) {
          await _sendFCMNotification(
            token: fcmToken,
            title: title,
            body: body,
            data: {
              'eventType': eventType,
              'eventId': eventId,
              'payload': '$eventType:$eventId',
            },
          );
        }
      }

      // Store notification in Firestore for history
      await FirebaseFirestore.instance
          .collection('notifications')
          .add(notificationData);
    } catch (e) {
      log('Error sending timeline event notification: $e');
    }
  }

  // Send FCM notification
  Future<void> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // This would typically be done through a Cloud Function
      // For now, we'll use a simple HTTP request to FCM
      // In production, you should implement this in Firebase Cloud Functions

      // For local testing, we'll show a local notification
      _showLocalTimelineNotification(title, body, data);
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  // Show local notification for timeline events
  void _showLocalTimelineNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) {
    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          when: DateTime.now().millisecondsSinceEpoch,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data['payload'],
    );
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['payload'],
      );
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final payload = response.payload!;
      final parts = payload.split(':');
      if (parts.length >= 2) {
        final eventType = parts[0];

        // Navigate based on event type
        switch (eventType) {
          case 'invoice':
            navigatorKey.currentState?.pushNamed('/invoice_list');
            break;
          case 'vault':
            navigatorKey.currentState?.pushNamed('/vault');
            break;
          case 'client':
            navigatorKey.currentState?.pushNamed('/client_list');
            break;
          case 'shipment':
            navigatorKey.currentState?.pushNamed('/shipments');
            break;
          case 'inventory':
            navigatorKey.currentState?.pushNamed('/inventory_panel');
            break;
          default:
            navigatorKey.currentState?.pushNamed('/dashboard');
        }
      }
    }
  }

  // Get notification history
  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      print('Error getting notification history: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Helper method to create timeline event notifications
  Future<void> notifyTimelineEvent({
    required String eventId,
    required String title,
    required String description,
    required String eventType,
    required Map<String, dynamic>? metadata,
  }) async {
    await sendTimelineEventNotification(
      title: title,
      body: description,
      eventType: eventType,
      eventId: eventId,
      metadata: metadata,
    );
  }

  // Specific notification methods for different event types
  Future<void> notifyNewInvoice({
    required String invoiceId,
    required double amount,
    String? clientName,
  }) async {
    final clientNameText = clientName ?? 'عميل غير معروف';
    await notifyTimelineEvent(
      eventId: invoiceId,
      title: 'فاتورة جديدة',
      description:
          'تم إنشاء فاتورة بقيمة ${amount.toStringAsFixed(2)} لـ $clientNameText',
      eventType: 'invoice',
      metadata: {'amount': amount, 'clientName': clientNameText},
    );
  }

  Future<void> notifyVaultTransaction({
    required String transactionId,
    required String type,
    required double amount,
    required String category,
  }) async {
    final typeText = type == 'income' ? 'إيراد' : 'مصروف';
    await notifyTimelineEvent(
      eventId: transactionId,
      title: 'معاملة مالية',
      description: '$typeText: ${amount.toStringAsFixed(2)} - $category',
      eventType: 'vault',
      metadata: {'amount': amount, 'type': type, 'category': category},
    );
  }

  Future<void> notifyNewClient({
    required String clientId,
    required String clientName,
  }) async {
    await notifyTimelineEvent(
      eventId: clientId,
      title: 'عميل جديد',
      description: 'تم إضافة عميل جديد: $clientName',
      eventType: 'client',
      metadata: {'clientName': clientName},
    );
  }

  Future<void> notifyNewShipment({
    required String shipmentId,
    required String supplierName,
  }) async {
    await notifyTimelineEvent(
      eventId: shipmentId,
      title: 'شحنة جديدة',
      description: 'تم إنشاء شحنة جديدة من $supplierName',
      eventType: 'shipment',
      metadata: {'supplierName': supplierName},
    );
  }

  Future<void> notifyInventoryUpdate({
    required String itemId,
    required String itemName,
    required int quantity,
  }) async {
    await notifyTimelineEvent(
      eventId: itemId,
      title: 'تحديث المخزون',
      description: 'تم تحديث كمية $itemName إلى $quantity',
      eventType: 'inventory',
      metadata: {'itemName': itemName, 'quantity': quantity},
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final localNotifications = FlutterLocalNotificationsPlugin();
  final notification = message.notification;
  if (notification != null) {
    localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'car_service_notifications',
          'Car Service Updates',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['payload'],
    );
  }
}
