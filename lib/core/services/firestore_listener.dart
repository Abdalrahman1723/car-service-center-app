import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirestoreListener {
  static final FirestoreListener _instance = FirestoreListener._internal();
  factory FirestoreListener() => _instance;
  FirestoreListener._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static const String _channelId = 'car_service_notifications';
  static const String _channelName = 'Car Service Updates';
  static const String _channelDescription =
      'Notifications for car service events';

  void startListening() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final collections = [
      'attendance',
      'clients',
      'employees',
      'inventories',
      'invoices',
      'shipments',
      'suppliers',
      'users',
      'vault',
    ];

    for (var collection in collections) {
      FirebaseFirestore.instance
          .collection(collection)
          .where('userId', isEqualTo: userId) // Filter by userId or createdBy
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data() as Map<String, dynamic>;
                _showNotification(collection, change.doc.id, data);
              }
            }
          });
    }
  }

  void _showNotification(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) {
    _localNotifications.show(
      docId.hashCode,
      'إشعار جديد',
      'تم إضافة سجل جديد في $collection: ${data['description'] ?? data['name'] ?? 'تفاصيل جديدة'}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: '$collection:$docId',
    );
  }
}
