// lib/vendor_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'order_manager.dart';
import 'main.dart'; // For navigatorKey

class VendorPage extends StatelessWidget {
  const VendorPage({Key? key}) : super(key: key);

  // LOGOUT FUNCTION
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
      navigatorKey.currentContext!,
      '/login',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard', style: TextStyle(fontFamily: 'Outfit')),
        backgroundColor: Colors.blue[900],
        actions: [
          // LOGOUT BUTTON
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: OrderManager.vendorOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No orders yet', style: TextStyle(fontFamily: 'Outfit')),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, i) {
              final doc = snapshot.data!.docs[i];
              final data = doc.data()! as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              final color = status == 'accepted'
                  ? Colors.green
                  : status == 'rejected'
                  ? Colors.red
                  : Colors.orange;

              return FadeInUp(
                child: Card(
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
                    trailing: status == 'pending'
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => OrderManager.updateStatus(doc.id, 'accepted'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => OrderManager.updateStatus(doc.id, 'rejected'),
                        ),
                      ],
                    )
                        : Chip(
                      label: Text(status.toUpperCase()),
                      backgroundColor: color.withOpacity(0.2),
                    ),
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