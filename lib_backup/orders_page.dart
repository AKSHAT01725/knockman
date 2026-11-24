// lib/orders_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'order_manager.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Login required')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.blue[900],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: OrderManager.userOrdersStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders yet', style: TextStyle(fontFamily: 'Outfit')));
          }

          final orders = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final data = orders[i].data()! as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              final color = status == 'accepted'
                  ? Colors.green
                  : status == 'rejected'
                  ? Colors.red
                  : Colors.orange;

              return Card(
                child: ListTile(
                  title: Text(
                    data['service'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${data['date']} • ${data['time']}'),
                      Text(data['address']),
                      Text('₹${data['price']} | ${data['phone']}'),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(status.toUpperCase()),
                    backgroundColor: color.withOpacity(0.2),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}