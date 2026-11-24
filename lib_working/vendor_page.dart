// lib/vendor_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'order_manager.dart';
import 'main.dart';
import 'chat_screen.dart'; // ← must exist

class VendorPage extends StatefulWidget {
  const VendorPage({Key? key}) : super(key: key);

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> categories = [
    'All',
    'Cleaning',
    'Plumber',
    'AC Repair',
    'Wall Paint',
    'Furniture',
    'Pesticides',
  ];

  static const Map<String, String> serviceToCategory = {
    'Home Cleaning': 'Cleaning',
    'Bathroom Cleaning': 'Cleaning',
    'Kitchen Cleaning': 'Cleaning',
    'Sofa Cleaning': 'Cleaning',
    'Carpet Cleaning': 'Cleaning',
    'Leak Repair': 'Plumber',
    'Pipe Installation': 'Plumber',
    'Bathroom Fixtures': 'Plumber',
    'Kitchen Sink Repair': 'Plumber',
    'Water Heater Installation': 'Plumber',
    'AC Servicing': 'AC Repair',
    'AC Installation': 'AC Repair',
    'AC Gas Filling': 'AC Repair',
    'AC Uninstallation': 'AC Repair',
    'AC Repair': 'AC Repair',
    'Interior Painting': 'Wall Paint',
    'Exterior Painting': 'Wall Paint',
    'Texture Painting': 'Wall Paint',
    'Wallpaper Installation': 'Wall Paint',
    'Paint Removal': 'Wall Paint',
    'Furniture Assembly': 'Furniture',
    'Furniture Repair': 'Furniture',
    'Custom Furniture Design': 'Furniture',
    'Furniture Polishing': 'Furniture',
    'Upholstery Cleaning': 'Furniture',
    'Termite Control': 'Pesticides',
    'Cockroach Control': 'Pesticides',
    'Bed Bug Control': 'Pesticides',
    'Rodent Control': 'Pesticides',
    'Mosquito Control': 'Pesticides',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        title: const Text(
          'Vendor Dashboard',
          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: categories.map((cat) => Tab(text: cat)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: categories.map((category) => _buildOrdersList(category)).toList(),
      ),
    );
  }

  Widget _buildOrdersList(String selectedCategory) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        if (snapshot.hasError) {
          print("Firestore error in vendor orders: ${snapshot.error}");
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
          print("No orders found at all for vendor");
          return _emptyState(selectedCategory);
        }

        var docs = snapshot.data!.docs;

        print("Vendor sees ${docs.length} total orders before filtering (tab: $selectedCategory)");

        // ────────────────────────────────────────────────
        // FILTERING – made more forgiving
        // ────────────────────────────────────────────────
        if (selectedCategory != 'All') {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) return false;

            final serviceRaw = (data['service'] as String?)?.trim() ?? '';
            final serviceLower = serviceRaw.toLowerCase();

            print("Checking service: '$serviceRaw' for category '$selectedCategory'");

            // 1. Exact match
            if (serviceRaw == selectedCategory) return true;

            // 2. Mapping match
            if (serviceToCategory.containsKey(serviceRaw)) {
              return serviceToCategory[serviceRaw] == selectedCategory;
            }

            // 3. Partial match (development fallback – remove later)
            return serviceLower.contains(selectedCategory.toLowerCase());
          }).toList();

          print("After filtering for $selectedCategory → ${docs.length} orders remain");
        }

        if (docs.isEmpty) {
          return _emptyState(selectedCategory);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final orderId = doc.id;

            final service = data['service'] ?? 'Unknown Service';
            final status = (data['status'] ?? 'pending').toString().toLowerCase();
            final date = data['date'] ?? '—';
            final time = data['time'] ?? '—';
            final address = data['address'] ?? '—';
            final phone = data['phone'] ?? '—';
            final price = data['price'] ?? '—';
            final description = data['description'] ?? '';

            final Color statusColor = status == 'accepted'
                ? Colors.green
                : status == 'rejected'
                ? Colors.red
                : Colors.orange;

            return FadeInUp(
              duration: Duration(milliseconds: 300 + index * 80),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Icon(
                      status == 'accepted' ? Icons.check_circle :
                      status == 'rejected' ? Icons.cancel : Icons.pending_actions,
                      color: statusColor,
                    ),
                  ),
                  title: Text(service, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('$date • $time'),
                  trailing: status == 'pending'
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                        onPressed: () => _acceptOrder(orderId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                        onPressed: () => OrderManager.updateStatus(orderId, 'rejected'),
                      ),
                    ],
                  )
                      : Chip(
                    label: Text(status.toUpperCase()),
                    backgroundColor: statusColor.withOpacity(0.15),
                    labelStyle: TextStyle(color: statusColor),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(Icons.location_on_outlined, 'Address', address),
                          _infoRow(Icons.phone_outlined, 'Phone', phone.isNotEmpty ? '+91 $phone' : '—'),
                          _infoRow(Icons.currency_rupee, 'Price', price),
                          if (description.isNotEmpty)
                            _infoRow(Icons.notes_outlined, 'Note', description),

                          const SizedBox(height: 16),

                          if (status == 'accepted')
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.chat_rounded, size: 20),
                                label: const Text('Chat with Customer'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue[800],
                                  side: BorderSide(color: Colors.blue[300]!),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        orderId: orderId,
                                        otherPartyName: "Customer",
                                        serviceName: service,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _acceptOrder(String orderId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': 'accepted',
        'vendorId': uid,
        'vendorAcceptedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order accepted'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _emptyState(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            category == 'All' ? 'No orders found in database' : 'No $category orders found',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}