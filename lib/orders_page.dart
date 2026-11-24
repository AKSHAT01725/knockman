// lib/orders_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'order_manager.dart';
import 'chat_screen.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {

  // ── palette ──────────────────────────────────────────────
  static const Color _navy    = Color(0xFF0D2137);
  static const Color _blue    = Color(0xFF1565C0);
  static const Color _surface = Color(0xFFF4F7FB);

  // active filter tab
  String _filter = 'All'; // All | pending | accepted | rejected

  final List<String> _filters = ['All', 'Pending', 'Accepted', 'Rejected'];

  // ── status helpers ────────────────────────────────────────
  Color _statusColor(String s) {
    switch (s) {
      case 'accepted': return Colors.green.shade600;
      case 'rejected': return Colors.red.shade600;
      default:         return Colors.orange.shade600;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'accepted': return Colors.green.shade50;
      case 'rejected': return Colors.red.shade50;
      default:         return Colors.orange.shade50;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'accepted': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      default:         return Icons.schedule_rounded;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'accepted': return 'Accepted';
      case 'rejected': return 'Rejected';
      default:         return 'Pending';
    }
  }

  // service → emoji
  String _serviceEmoji(String service) {
    final s = service.toLowerCase();
    if (s.contains('clean'))    return '🧹';
    if (s.contains('plumb') || s.contains('leak') || s.contains('pipe') ||
        s.contains('sink') || s.contains('heater') || s.contains('fixture')) return '🔧';
    if (s.contains('ac') || s.contains('gas'))  return '❄️';
    if (s.contains('paint') || s.contains('wallpaper') || s.contains('texture')) return '🖌️';
    if (s.contains('furni') || s.contains('sofa') || s.contains('upholster') ||
        s.contains('polish') || s.contains('assem')) return '🪑';
    if (s.contains('pest') || s.contains('termite') || s.contains('cockroach') ||
        s.contains('bed bug') || s.contains('rodent') || s.contains('mosquito')) return '🦟';
    return '🏠';
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: _surface,
        body: const Center(child: Text('Please login to view orders')),
      );
    }

    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterTabs(),
          Expanded(child: _buildOrdersList(user.uid)),
        ],
      ),
    );
  }

  // ── header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // decorative circle
            Positioned(top: -20, right: -30,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                )),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('My Orders',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                            letterSpacing: -0.3,
                          )),
                      Text('Track your bookings',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 13,
                            fontFamily: 'Outfit',
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── filter tabs ───────────────────────────────────────────
  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: _filters.map((f) {
          final active = _filter == f ||
              (_filter == 'All' && f == 'All');
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? _blue : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  f,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : Colors.grey.shade500,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── orders list ───────────────────────────────────────────
  Widget _buildOrdersList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: OrderManager.userOrdersStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _blue, strokeWidth: 2.5));
        }

        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState();
        }

        // filter docs
        var docs = snapshot.data!.docs;
        if (_filter != 'All') {
          docs = docs
              .where((d) =>
          ((d.data() as Map)['status'] ?? 'pending').toString().toLowerCase() ==
              _filter.toLowerCase())
              .toList();
        }

        if (docs.isEmpty) return _emptyState(filtered: true);

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc  = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final status  = (data['status'] ?? 'pending').toString().toLowerCase();
            final service = data['service'] ?? 'Service';

            return FadeInUp(
              duration: Duration(milliseconds: 300 + index * 60),
              child: _buildOrderCard(
                doc: doc,
                data: data,
                status: status,
                service: service,
                index: index,
              ),
            );
          },
        );
      },
    );
  }

  // ── single order card ─────────────────────────────────────
  Widget _buildOrderCard({
    required QueryDocumentSnapshot doc,
    required Map<String, dynamic> data,
    required String status,
    required String service,
    required int index,
  }) {
    final statusColor = _statusColor(status);
    final statusBg    = _statusBg(status);
    final emoji       = _serviceEmoji(service);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── top row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // emoji icon
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: _blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),

                // service + date/time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _navy,
                            fontFamily: 'Outfit',
                          )),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '${data['date'] ?? '—'}  •  ${data['time'] ?? '—'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),

                // status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(status),
                          color: statusColor, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel(status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── divider ──────────────────────────────────────
          Divider(height: 1, color: Colors.grey.shade100),

          // ── details row ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _detailChip(
                  Icons.payments_outlined,
                  data['price'] ?? '—',
                  Colors.blue.shade700,
                  Colors.blue.shade50,
                ),
                const SizedBox(width: 8),
                _detailChip(
                  Icons.phone_outlined,
                  data['phone'] ?? '—',
                  Colors.green.shade700,
                  Colors.green.shade50,
                ),
              ],
            ),
          ),

          // address
          if ((data['address'] ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      data['address'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontFamily: 'Outfit',
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // ── chat button (accepted orders only) ───────────
          if (status == 'accepted') ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        orderId: doc.id,
                        otherPartyName: 'Vendor',
                        serviceName: service,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_navy, _blue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text('Chat with Vendor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Outfit',
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailChip(
      IconData icon, String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: 'Outfit',
              )),
        ],
      ),
    );
  }

  // ── empty state ───────────────────────────────────────────
  Widget _emptyState({bool filtered = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.receipt_long_rounded,
                  size: 44, color: _blue.withOpacity(0.4)),
            ),
            const SizedBox(height: 20),
            Text(
              filtered ? 'No $_filter orders' : 'No orders yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _navy,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filtered
                  ? 'Try switching to a different filter'
                  : 'Your bookings will appear here\nafter you book a service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontFamily: 'Outfit',
                height: 1.5,
              ),
            ),
            if (!filtered) ...[
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/services'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_navy, _blue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Book a Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── error state ───────────────────────────────────────────
  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 52, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                    fontFamily: 'Outfit')),
            const SizedBox(height: 8),
            Text(error.split('\n').first,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontFamily: 'Outfit')),
          ],
        ),
      ),
    );
  }
}