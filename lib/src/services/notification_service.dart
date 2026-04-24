import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initializeFCM() async {
    try {
      // Request permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
        
        // Get token
        String? token = await _fcm.getToken(
          vapidKey: dotenv.env['FCM_VAPID_PUBLIC_KEY'],
        );
        
        if (token != null) {
          debugPrint('FCM Token: $token');
          await _saveTokenToFirestore(token);
        }

        // Listen for foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');

          if (message.notification != null) {
            debugPrint('Message also contained a notification: ${message.notification}');
          }
        });
      }
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Stream<List<NotificationItem>> getNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        // .where('userId', isEqualTo: user.uid)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationItem.fromFirestore(doc))
            .toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> clearAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final querySnapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Send a notification to the admin
  static Future<void> notifyAdmin({
    required String title,
    required String message,
    String type = 'order',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('NotificationService: Sending admin notification: $title');
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': 'admin', // Static ID for admin notifications
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': metadata,
      });
      debugPrint('NotificationService: Admin notification sent successfully');
    } catch (e) {
      debugPrint('NotificationService: Error sending admin notification: $e');
    }
  }

  /// Helper to send notification to a specific user (used by admin)
  static Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'general',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('NotificationService: Sending user notification to $userId: $title');
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': metadata,
      });
      debugPrint('NotificationService: User notification sent successfully');
    } catch (e) {
      debugPrint('NotificationService: Error sending user notification: $e');
    }
  }
}
