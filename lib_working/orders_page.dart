// lib/orders_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'order_manager.dart';
import 'chat_screen.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view orders')),
      );
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.blue[900],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: OrderManager.userOrdersStream(userId),
        builder: (context, snapshot) {
          // ───── Debug prints ─────
          if (snapshot.hasError) {
            print("Orders page error: ${snapshot.error}");
          }
          print("Orders snapshot - hasData: ${snapshot.hasData}, "
              "docs count: ${snapshot.data?.docs.length ?? 0}, "
              "connection: ${snapshot.connectionState}");

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading orders:\n${snapshot.error.toString().split('\n')[0]}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Book a service to see it here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>?;

              if (data == null) {
                return const ListTile(title: Text('Invalid order data'));
              }

              final status = (data['status'] ?? 'pending').toString().toLowerCase();
              final service = data['service'] ?? 'Service';
              final color = status == 'accepted'
                  ? Colors.green
                  : status == 'rejected'
                  ? Colors.red
                  : Colors.orange;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    service,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('${data['date'] ?? '—'} • ${data['time'] ?? '—'}'),
                      Text(data['address'] ?? '—'),
                      Text('₹${data['price'] ?? '—'} | ${data['phone'] ?? '—'}'),
                      const SizedBox(height: 4),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == 'accepted')
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.blue),
                          tooltip: 'Chat with Vendor',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  orderId: doc.id,
                                  otherPartyName: "Vendor",
                                  serviceName: service,
                                ),
                              ),
                            );
                          },
                        ),
                      Chip(
                        label: Text(status.toUpperCase()),
                        backgroundColor: color.withOpacity(0.15),
                        labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}