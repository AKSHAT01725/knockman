// lib/order_manager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class OrderManager {
  static final _firestore = FirebaseFirestore.instance;
  static final _ordersRef = _firestore.collection('orders');

  static Future<void> init() async {}

  static Future<String> addOrder({
    required String userId,
    required String service,
    required String price,
    required String date,
    required String time,
    required String address,
    required String description,
    required String phone,
  }) async {
    final orderId = const Uuid().v4();
    await _ordersRef.doc(orderId).set({
      'id': orderId,
      'userId': userId,
      'service': service,
      'price': price,
      'date': date,
      'time': time,
      'address': address,
      'description': description,
      'phone': phone,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return orderId;
  }

  static Future<void> updateStatus(String orderId, String status) async {
    await _ordersRef.doc(orderId).update({'status': status});
  }

  static Stream<QuerySnapshot> vendorOrdersStream() {
    return _ordersRef.snapshots();
  }

  static Stream<QuerySnapshot> userOrdersStream(String userId) {
    return _ordersRef.where('userId', isEqualTo: userId).snapshots();
  }
}