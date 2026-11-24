// lib/vendor_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'order_manager.dart';
import 'main.dart';
import 'chat_screen.dart';
import 'profile_manager.dart';

class VendorPage extends StatefulWidget {
  const VendorPage({Key? key}) : super(key: key);

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage>
    with SingleTickerProviderStateMixin {

  // ── palette ──────────────────────────────────────────────
  static const Color _navy    = Color(0xFF0D2137);
  static const Color _blue    = Color(0xFF1565C0);
  static const Color _surface = Color(0xFFF4F7FB);

  // ── category tabs ─────────────────────────────────────────
  late TabController _tabController;
  final List<String> categories = [
    'All', 'Cleaning', 'Plumber', 'AC Repair',
    'Wall Paint', 'Furniture', 'Pesticides',
  ];

  // ── service → category mapping ────────────────────────────
  static const Map<String, String> serviceToCategory = {
    'Home Cleaning': 'Cleaning', 'Bathroom Cleaning': 'Cleaning',
    'Kitchen Cleaning': 'Cleaning', 'Sofa Cleaning': 'Cleaning',
    'Carpet Cleaning': 'Cleaning',
    'Leak Repair': 'Plumber', 'Pipe Installation': 'Plumber',
    'Bathroom Fixtures': 'Plumber', 'Kitchen Sink Repair': 'Plumber',
    'Water Heater Installation': 'Plumber',
    'AC Servicing': 'AC Repair', 'AC Installation': 'AC Repair',
    'AC Gas Filling': 'AC Repair', 'AC Uninstallation': 'AC Repair',
    'AC Repair': 'AC Repair',
    'Interior Painting': 'Wall Paint', 'Exterior Painting': 'Wall Paint',
    'Texture Painting': 'Wall Paint', 'Wallpaper Installation': 'Wall Paint',
    'Paint Removal': 'Wall Paint',
    'Furniture Assembly': 'Furniture', 'Furniture Repair': 'Furniture',
    'Custom Furniture Design': 'Furniture', 'Furniture Polishing': 'Furniture',
    'Upholstery Cleaning': 'Furniture',
    'Termite Control': 'Pesticides', 'Cockroach Control': 'Pesticides',
    'Bed Bug Control': 'Pesticides', 'Rodent Control': 'Pesticides',
    'Mosquito Control': 'Pesticides',
  };

  // ── emoji helper ──────────────────────────────────────────
  String _emoji(String service) {
    final s = service.toLowerCase();
    if (s.contains('clean') || s.contains('sofa') || s.contains('carpet')) return '🧹';
    if (s.contains('plumb') || s.contains('leak') || s.contains('pipe') ||
        s.contains('sink') || s.contains('heater') || s.contains('fixture')) return '🔧';
    if (s.contains('ac') || s.contains('gas'))   return '❄️';
    if (s.contains('paint') || s.contains('wallpaper') || s.contains('texture')) return '🖌️';
    if (s.contains('furni') || s.contains('upholster') ||
        s.contains('polish') || s.contains('assem')) return '🪑';
    if (s.contains('pest') || s.contains('termite') || s.contains('cockroach') ||
        s.contains('bed bug') || s.contains('rodent') || s.contains('mosquito')) return '🦟';
    return '🏠';
  }

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

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
      navigatorKey.currentContext!,
      '/login',
          (route) => false,
    );
  }

  Future<void> _acceptOrder(String orderId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    HapticFeedback.lightImpact();
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'accepted',
        'vendorId': uid,
        'vendorAcceptedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Order accepted!',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 13)),
            ]),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e',
                style: const TextStyle(fontFamily: 'Outfit')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _openChat(BuildContext context, String orderId, String service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          orderId: orderId,
          otherPartyName: 'Customer',
          serviceName: service,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildHeader(),
          _buildCategoryTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories
                  .map((cat) => _buildOrdersList(cat))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final name = ProfileManager.userName.split(' ').first;
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
            Positioned(top: -30, right: -40,
                child: _circle(160, 0.05)),
            Positioned(bottom: -10, left: 60,
                child: _circle(80, 0.04)),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      border:
                      Border.all(color: Colors.white38, width: 1.5),
                    ),
                    child: const Icon(Icons.store_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome, $name 👋',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: 'Outfit',
                            )),
                        const Text('Vendor Dashboard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Outfit',
                              letterSpacing: -0.3,
                            )),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );

  // ─────────────────────────────────────────────────────────
  //  CATEGORY TABS
  // ─────────────────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: _blue,
        unselectedLabelColor: Colors.grey.shade400,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFamily: 'Outfit',
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Outfit',
          fontSize: 13,
        ),
        indicatorColor: _blue,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: categories.map((cat) => Tab(text: cat)).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  ORDERS LIST
  // ─────────────────────────────────────────────────────────
  Widget _buildOrdersList(String selectedCategory) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: _blue, strokeWidth: 2.5));
        }

        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState(selectedCategory);
        }

        var docs = snapshot.data!.docs;

        // category filter
        if (selectedCategory != 'All') {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data == null) return false;
            final serviceRaw = (data['service'] as String?)?.trim() ?? '';
            if (serviceRaw == selectedCategory) return true;
            if (serviceToCategory.containsKey(serviceRaw)) {
              return serviceToCategory[serviceRaw] == selectedCategory;
            }
            return serviceRaw.toLowerCase()
                .contains(selectedCategory.toLowerCase());
          }).toList();
        }

        if (docs.isEmpty) return _emptyState(selectedCategory);

        final total    = docs.length;
        final pending  = docs.where((d) =>
        ((d.data() as Map)['status'] ?? '') == 'pending').length;
        final accepted = docs.where((d) =>
        ((d.data() as Map)['status'] ?? '') == 'accepted').length;

        return Column(
          children: [
            _buildStatsStrip(total, pending, accepted),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc  = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final status  =
                  (data['status'] ?? 'pending').toString().toLowerCase();
                  final service = data['service'] ?? 'Unknown Service';
                  final isMyAcceptedOrder =
                      status == 'accepted' && data['vendorId'] == currentUid;

                  return FadeInUp(
                    duration:
                    Duration(milliseconds: 280 + index * 55),
                    child: _buildOrderCard(
                      doc: doc,
                      data: data,
                      status: status,
                      service: service,
                      isMyAcceptedOrder: isMyAcceptedOrder,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  //  STATS STRIP
  // ─────────────────────────────────────────────────────────
  Widget _buildStatsStrip(int total, int pending, int accepted) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _statCell('$total',    'Total',    _blue,                    Icons.list_alt_rounded),
          _vDivider(),
          _statCell('$pending',  'Pending',  Colors.orange.shade600,   Icons.schedule_rounded),
          _vDivider(),
          _statCell('$accepted', 'Accepted', Colors.green.shade600,    Icons.check_circle_rounded),
          _vDivider(),
          _statCell('${total - pending - accepted}', 'Rejected',
              Colors.red.shade400, Icons.cancel_rounded),
        ],
      ),
    );
  }

  Widget _statCell(
      String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
                fontFamily: 'Outfit',
              )),
          Text(label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontFamily: 'Outfit',
              )),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
      width: 1, height: 40, color: Colors.grey.shade100);

  // ─────────────────────────────────────────────────────────
  //  SINGLE ORDER CARD
  // ─────────────────────────────────────────────────────────
  Widget _buildOrderCard({
    required QueryDocumentSnapshot doc,
    required Map<String, dynamic> data,
    required String status,
    required String service,
    required bool isMyAcceptedOrder,
  }) {
    final statusColor = _statusColor(status);
    final statusBg    = _statusBg(status);
    final emoji       = _emoji(service);
    final description = data['description'] ?? '';
    final phone       = data['phone'] ?? '';
    final address     = data['address'] ?? '';
    final price       = data['price'] ?? '—';
    final date        = data['date'] ?? '—';
    final time        = data['time'] ?? '—';

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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          childrenPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),

          // ── tile ───────────────────────────────────────
          leading: Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji,
                  style: const TextStyle(fontSize: 24)),
            ),
          ),

          title: Text(service,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _navy,
                fontFamily: 'Outfit',
              )),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 11, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text('$date  •  $time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: 'Outfit',
                    )),
              ],
            ),
          ),

          // ── TRAILING: pending → accept/reject buttons | all others → status icon
          trailing: status == 'pending'
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _actionBtn(
                icon: Icons.check_rounded,
                color: Colors.green.shade600,
                bg: Colors.green.shade50,
                onTap: () => _acceptOrder(doc.id),
              ),
              const SizedBox(width: 8),
              _actionBtn(
                icon: Icons.close_rounded,
                color: Colors.red.shade600,
                bg: Colors.red.shade50,
                onTap: () =>
                    OrderManager.updateStatus(doc.id, 'rejected'),
              ),
            ],
          )
              : Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusBg,
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(status),
                color: statusColor, size: 20),
          ),

          // ── expanded details ────────────────────────────
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Divider(height: 1, color: Colors.grey.shade200),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _detailRow(Icons.location_on_rounded,
                            'Address', address),
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _detailRow(Icons.phone_rounded,
                              'Phone', '+91 $phone'),
                        ],
                        const SizedBox(height: 10),
                        _detailRow(Icons.currency_rupee_rounded,
                            'Price', price),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _detailRow(Icons.notes_rounded,
                              'Note', description),
                        ],

                        // ── full-width chat button in expanded section (only for my accepted orders)
                        if (isMyAcceptedOrder) ...[
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () =>
                                _openChat(context, doc.id, service),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_navy, _blue],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius:
                                BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _blue.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_rounded,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text('Chat with Customer',
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
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: _blue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontFamily: 'Outfit',
                  )),
              const SizedBox(height: 1),
              Text(value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _navy,
                    fontFamily: 'Outfit',
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  EMPTY / ERROR STATES
  // ─────────────────────────────────────────────────────────
  Widget _emptyState(String category) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_rounded,
                  size: 38, color: _blue.withOpacity(0.4)),
            ),
            const SizedBox(height: 18),
            Text(
              category == 'All'
                  ? 'No orders yet'
                  : 'No $category orders',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _navy,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New bookings will appear here\nwhen customers place orders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontFamily: 'Outfit',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade300),
            const SizedBox(height: 14),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                    fontFamily: 'Outfit')),
            const SizedBox(height: 6),
            Text(error.split('\n').first,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontFamily: 'Outfit')),
          ],
        ),
      ),
    );
  }
}