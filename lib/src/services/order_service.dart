import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> createOrder({
    required String orderId,
    required String userId,
    required String userName,
    required double totalAmount,
    required String paymentMode,
    required String status,
    required String address,
    required String addressType,
    required List<Map<String, dynamic>> items,
    String? transactionId,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'userId': userId,
        'userName': userName,
        'totalAmount': totalAmount,
        'paymentMode': paymentMode,
        'status': status,
        'address': address,
        'addressType': addressType,
        'items': items,
        'transactionId': transactionId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Order $orderId saved to Firebase successfully.');
    } catch (e) {
      debugPrint('Error saving order to Firebase: $e');
      rethrow;
    }
  }
}
