// lib/admin_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'profile_manager.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {

  // ── palette ──────────────────────────────────────────────
  static const Color _navy    = Color(0xFF0D2137);
  static const Color _blue    = Color(0xFF1565C0);
  static const Color _surface = Color(0xFFF4F7FB);

  late TabController _tabController;
  final List<String> _tabs = ['Overview', 'Users', 'Orders'];

  // user search
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _roleFilter  = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _searchController.addListener(
            () => setState(() => _searchQuery = _searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(msg,
                style:
                const TextStyle(fontFamily: 'Outfit', fontSize: 13))),
      ]),
      backgroundColor: error ? Colors.red.shade700 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (_, __) {
          final show = _tabController.index == 1 ||
              (_tabController.animation?.value != null &&
                  (_tabController.animation!.value - 1).abs() < 0.5);
          return AnimatedScale(
            scale: show ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton.extended(
              onPressed: _showCreateUserDialog,
              backgroundColor: _blue,
              elevation: 4,
              icon: const Icon(Icons.person_add_rounded,
                  color: Colors.white, size: 20),
              label: const Text('Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  )),
            ),
          );
        },
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildUsersTab(),
                _buildOrdersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  CREATE USER DIALOG
  // ─────────────────────────────────────────────────────────
  void _showCreateUserDialog() {
    final nameCtrl     = TextEditingController();
    final emailCtrl    = TextEditingController();
    final passCtrl     = TextEditingController();
    final mobileCtrl   = TextEditingController();
    String selectedRole = 'user';
    bool obscurePass    = true;
    bool isLoading      = false;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: _blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person_add_rounded,
                              color: _blue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _navy,
                              fontFamily: 'Outfit',
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Account Role',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                            fontFamily: 'Outfit')),
                    const SizedBox(height: 8),
                    Row(
                      children: ['user', 'vendor', 'admin'].map((r) {
                        final active = selectedRole == r;
                        Color rc;
                        switch (r) {
                          case 'admin':  rc = Colors.purple.shade600; break;
                          case 'vendor': rc = Colors.green.shade600;  break;
                          default:       rc = _blue;
                        }
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setModalState(() => selectedRole = r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: EdgeInsets.only(right: r != 'admin' ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: active ? rc : rc.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: active ? rc : rc.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    r == 'admin'
                                        ? Icons.admin_panel_settings_rounded
                                        : r == 'vendor'
                                        ? Icons.store_rounded
                                        : Icons.person_rounded,
                                    color: active ? Colors.white : rc,
                                    size: 18,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    r[0].toUpperCase() + r.substring(1),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: active ? Colors.white : rc,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _dialogField(
                      controller: nameCtrl,
                      label: 'Full Name',
                      hint: 'e.g. Rahul Sharma',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _dialogField(
                      controller: emailCtrl,
                      label: 'Email Address',
                      hint: 'user@example.com',
                      icon: Icons.alternate_email_rounded,
                      keyboard: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _dialogField(
                      controller: mobileCtrl,
                      label: 'Mobile Number',
                      hint: '9876543210',
                      icon: Icons.phone_outlined,
                      keyboard: TextInputType.phone,
                      prefixText: '+91  ',
                    ),
                    const SizedBox(height: 12),
                    _dialogField(
                      controller: passCtrl,
                      label: 'Password',
                      hint: 'Min. 6 characters',
                      icon: Icons.lock_outline_rounded,
                      obscure: obscurePass,
                      suffixIcon: GestureDetector(
                        onTap: () => setModalState(() => obscurePass = !obscurePass),
                        child: Icon(
                          obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade400,
                          size: 18,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: isLoading
                          ? Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_navy, _blue]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          ),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          setModalState(() => isLoading = true);
                          try {
                            final cred = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: emailCtrl.text.trim(),
                              password: passCtrl.text.trim(),
                            );
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(cred.user!.uid)
                                .set({
                              'name':     nameCtrl.text.trim(),
                              'email':    emailCtrl.text.trim(),
                              'mobile':   mobileCtrl.text.trim(),
                              'address':  '',
                              'role':     selectedRole,
                              'isBanned': false,
                              'createdAt': FieldValue.serverTimestamp(),
                            });
                            if (mounted) {
                              Navigator.pop(ctx);
                              _snack(
                                  '${selectedRole[0].toUpperCase()}${selectedRole.substring(1)} account created!');
                            }
                          } on FirebaseAuthException catch (e) {
                            setModalState(() => isLoading = false);
                            _snack(_friendlyError(e.code), error: true);
                          } catch (e) {
                            setModalState(() => isLoading = false);
                            _snack('Error: $e', error: true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_navy, _blue],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Create Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Outfit',
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? prefixText,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
                fontFamily: 'Outfit')),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: obscure,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: _navy, fontFamily: 'Outfit'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.grey.shade400, fontFamily: 'Outfit', fontSize: 13),
            prefixText: prefixText,
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 18),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _blue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  // ─────────────────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────────────────
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
            Positioned(top: -30, right: -40, child: _circle(160, 0.05)),
            Positioned(bottom: -10, left: 60, child: _circle(80, 0.04)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${ProfileManager.userName.split(' ').first} 👋',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: 'Outfit'),
                        ),
                        const Text('Admin Dashboard',
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
      width: size, height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity)));

  // ─────────────────────────────────────────────────────────
  //  TAB BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: _blue,
        unselectedLabelColor: Colors.grey.shade400,
        labelStyle: const TextStyle(
            fontWeight: FontWeight.w700, fontFamily: 'Outfit', fontSize: 13),
        unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500, fontFamily: 'Outfit', fontSize: 13),
        indicatorColor: _blue,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  //  TAB 1 — OVERVIEW
  // ═════════════════════════════════════════════════════════
  Widget _buildOverviewTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (ctx, userSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (ctx, orderSnap) {
            final users  = userSnap.data?.docs ?? [];
            final orders = orderSnap.data?.docs ?? [];

            final totalUsers     = users.length;
            final bannedUsers    = users.where((d) => (d.data() as Map)['isBanned'] == true).length;
            final vendors        = users.where((d) => (d.data() as Map)['role'] == 'vendor').length;
            final totalOrders    = orders.length;
            final pendingOrders  = orders.where((d) => ((d.data() as Map)['status'] ?? '') == 'pending').length;
            final acceptedOrders = orders.where((d) => ((d.data() as Map)['status'] ?? '') == 'accepted').length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // ── stat cards grid ─────────────────────
                  FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    child: _sectionLabel('Platform Stats'),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      // wider = shorter card height; tweak if needed
                      childAspectRatio: 1.85,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _statCard('Total Users',  '$totalUsers',
                            Icons.people_rounded,       Colors.blue.shade700,   const Color(0xFFE3F0FF)),
                        _statCard('Vendors',      '$vendors',
                            Icons.store_rounded,        Colors.green.shade700,  const Color(0xFFE6F9EE)),
                        _statCard('Total Orders', '$totalOrders',
                            Icons.receipt_long_rounded, Colors.purple.shade700, const Color(0xFFF3EEFF)),
                        _statCard('Pending',      '$pendingOrders',
                            Icons.schedule_rounded,     Colors.orange.shade700, const Color(0xFFFFF3E0)),
                        // "Accepted" spans full width when odd count — wrap in a Row
                        _statCard('Accepted',     '$acceptedOrders',
                            Icons.check_circle_rounded, Colors.teal.shade700,   const Color(0xFFE0F7F4)),
                        _statCard('Rejected',     '${totalOrders - pendingOrders - acceptedOrders}',
                            Icons.cancel_rounded,       Colors.red.shade600,    const Color(0xFFFFEBEE)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── order status breakdown ──────────────
                  FadeInUp(
                    duration: const Duration(milliseconds: 450),
                    child: _sectionLabel('Order Breakdown'),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: _buildBreakdownCard(
                      total: totalOrders,
                      pending: pendingOrders,
                      accepted: acceptedOrders,
                      rejected: totalOrders - pendingOrders - acceptedOrders,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── quick actions ───────────────────────
                  FadeInUp(
                    duration: const Duration(milliseconds: 550),
                    child: _sectionLabel('Quick Actions'),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Row(
                      children: [
                        Expanded(
                          child: _quickAction(
                            icon: Icons.people_alt_rounded,
                            label: 'Manage Users',
                            color: _blue,
                            onTap: () => _tabController.animateTo(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _quickAction(
                            icon: Icons.receipt_long_rounded,
                            label: 'All Orders',
                            color: Colors.purple.shade600,
                            onTap: () => _tabController.animateTo(2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── banned alert ─────────────────────────
                  if (bannedUsers > 0) ...[
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 650),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$bannedUsers banned account${bannedUsers > 1 ? 's' : ''} — review in Users tab',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── updated _statCard: row layout, no fixed width/height ──
  Widget _statCard(String label, String value, IconData icon,
      Color color, Color bg) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 4)),
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontFamily: 'Outfit',
                      height: 1.1,
                    )),
                const SizedBox(height: 2),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      fontFamily: 'Outfit',
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard({
    required int total,
    required int pending,
    required int accepted,
    required int rejected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _breakdownRow('Pending',  pending,  Colors.orange.shade600, total),
            const SizedBox(height: 10),
            _breakdownRow('Accepted', accepted, Colors.green.shade600,  total),
            const SizedBox(height: 10),
            _breakdownRow('Rejected', rejected, Colors.red.shade500,    total),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, int count, Color color, int total) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _navy,
                    fontFamily: 'Outfit')),
            Text('$count',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Outfit')),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Outfit',
                )),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════
  //  TAB 2 — USERS
  // ═════════════════════════════════════════════════════════
  Widget _buildUsersTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email…',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontFamily: 'Outfit',
                        fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.grey.shade400, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: Icon(Icons.close_rounded,
                            color: Colors.grey.shade400, size: 18))
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: ['All', 'user', 'vendor', 'admin'].map((r) {
                  final active = _roleFilter == r;
                  return GestureDetector(
                    onTap: () => setState(() => _roleFilter = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? _blue : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r == 'All' ? 'All' : r[0].toUpperCase() + r.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : Colors.grey.shade500,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: _blue, strokeWidth: 2.5));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return _emptyState('No users found');
              }

              var docs = snap.data!.docs;

              if (_roleFilter != 'All') {
                docs = docs
                    .where((d) =>
                ((d.data() as Map)['role'] ?? 'user') == _roleFilter)
                    .toList();
              }

              if (_searchQuery.isNotEmpty) {
                docs = docs.where((d) {
                  final data = d.data() as Map;
                  final name  = (data['name']  ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                }).toList();
              }

              if (docs.isEmpty) return _emptyState('No matching users');

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final doc  = docs[i];
                  final data = doc.data() as Map<String, dynamic>;
                  return FadeInUp(
                    duration: Duration(milliseconds: 280 + i * 40),
                    child: _buildUserCard(doc, data),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(
      QueryDocumentSnapshot doc, Map<String, dynamic> data) {
    final name     = data['name']     ?? 'Unknown';
    final email    = data['email']    ?? '';
    final role     = data['role']     ?? 'user';
    final isBanned = data['isBanned'] == true;

    final initials = name.trim().split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2)
        .join();

    Color roleColor;
    Color roleBg;
    switch (role) {
      case 'admin':  roleColor = Colors.purple.shade700; roleBg = Colors.purple.shade50; break;
      case 'vendor': roleColor = Colors.green.shade700;  roleBg = Colors.green.shade50;  break;
      default:       roleColor = _blue;                  roleBg = Colors.blue.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isBanned ? Border.all(color: Colors.red.shade200) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isBanned ? Colors.red.shade50 : _blue.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  isBanned ? '🚫' : initials,
                  style: TextStyle(
                    fontSize: isBanned ? 20 : 16,
                    fontWeight: FontWeight.w700,
                    color: _blue,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                        fontFamily: 'Outfit',
                      )),
                  Text(email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontFamily: 'Outfit',
                      )),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role[0].toUpperCase() + role.substring(1),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: roleColor,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      if (isBanned) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Banned',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade700,
                                fontFamily: 'Outfit',
                              )),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded,
                  color: Colors.grey.shade400, size: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onSelected: (val) =>
                  _handleUserAction(val, doc.id, isBanned, role),
              itemBuilder: (_) => [
                _menuItem('ban',
                    isBanned ? 'Unban User' : 'Ban User',
                    isBanned ? Icons.lock_open_rounded : Icons.block_rounded,
                    isBanned ? Colors.green.shade600 : Colors.red.shade600),
                if (role != 'admin') ...[
                  _menuItem(
                      'make_vendor',
                      role == 'vendor' ? 'Demote to User' : 'Make Vendor',
                      role == 'vendor' ? Icons.person_rounded : Icons.store_rounded,
                      Colors.blue.shade700),
                  _menuItem('make_admin', 'Make Admin',
                      Icons.admin_panel_settings_rounded,
                      Colors.purple.shade700),
                ],
                const PopupMenuDivider(),
                _menuItem('delete', 'Delete Account',
                    Icons.delete_forever_rounded, Colors.red.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      String value, String label, IconData icon, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Future<void> _handleUserAction(
      String action, String uid, bool isBanned, String role) async {
    try {
      HapticFeedback.lightImpact();
      final ref = FirebaseFirestore.instance.collection('users').doc(uid);
      switch (action) {
        case 'ban':
          await ref.update({'isBanned': !isBanned});
          _snack(isBanned ? 'User unbanned' : 'User banned');
          break;
        case 'make_vendor':
          await ref.update({'role': role == 'vendor' ? 'user' : 'vendor'});
          _snack(role == 'vendor' ? 'Demoted to User' : 'Promoted to Vendor');
          break;
        case 'make_admin':
          await ref.update({'role': 'admin'});
          _snack('User promoted to Admin');
          break;
        case 'delete':
          final confirmed = await _confirmDelete(context, uid);
          if (!confirmed) return;
          await ref.delete();
          _snack('Account deleted');
          break;
      }
    } catch (e) {
      _snack('Error: $e', error: true);
    }
  }

  Future<bool> _confirmDelete(BuildContext context, String uid) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_forever_rounded,
                    color: Colors.red.shade600, size: 30),
              ),
              const SizedBox(height: 16),
              const Text('Delete Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                    fontFamily: 'Outfit',
                  )),
              const SizedBox(height: 8),
              Text(
                'This will permanently remove the user\'s Firestore data. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontFamily: 'Outfit',
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('Cancel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _navy,
                                fontFamily: 'Outfit',
                              )),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('Delete',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Outfit',
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;
  }

  // ═════════════════════════════════════════════════════════
  //  TAB 3 — ORDERS
  // ═════════════════════════════════════════════════════════
  Widget _buildOrdersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: _blue, strokeWidth: 2.5));
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return _emptyState('No orders yet');
        }

        final docs = snap.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc  = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final status  =
            (data['status'] ?? 'pending').toString().toLowerCase();
            final service = data['service'] ?? 'Unknown Service';
            return FadeInUp(
              duration: Duration(milliseconds: 280 + i * 40),
              child: _buildAdminOrderCard(doc.id, data, status, service),
            );
          },
        );
      },
    );
  }

  Widget _buildAdminOrderCard(
      String docId, Map<String, dynamic> data,
      String status, String service) {
    Color sColor;
    Color sBg;
    IconData sIcon;
    switch (status) {
      case 'accepted':
        sColor = Colors.green.shade600; sBg = Colors.green.shade50;
        sIcon  = Icons.check_circle_rounded; break;
      case 'rejected':
        sColor = Colors.red.shade600;   sBg = Colors.red.shade50;
        sIcon  = Icons.cancel_rounded;  break;
      default:
        sColor = Colors.orange.shade600; sBg = Colors.orange.shade50;
        sIcon  = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(_serviceEmoji(service),
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                        fontFamily: 'Outfit',
                      )),
                  const SizedBox(height: 3),
                  Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '${data['date'] ?? '—'}  •  ${data['time'] ?? '—'}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontFamily: 'Outfit'),
                    ),
                  ]),
                  const SizedBox(height: 5),
                  Row(children: [
                    Icon(Icons.currency_rupee_rounded,
                        size: 11, color: Colors.blue.shade700),
                    Text(data['price'] ?? '—',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Outfit')),
                    const SizedBox(width: 10),
                    Icon(Icons.phone_rounded,
                        size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Text(data['phone'] ?? '—',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontFamily: 'Outfit')),
                  ]),
                ],
              ),
            ),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: sBg, shape: BoxShape.circle),
              child: Icon(sIcon, color: sColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  String _serviceEmoji(String service) {
    final s = service.toLowerCase();
    if (s.contains('clean'))  return '🧹';
    if (s.contains('plumb') || s.contains('leak') || s.contains('pipe')) return '🔧';
    if (s.contains('ac') || s.contains('gas'))   return '❄️';
    if (s.contains('paint') || s.contains('wallpaper')) return '🖌️';
    if (s.contains('furni') || s.contains('upholster')) return '🪑';
    if (s.contains('pest') || s.contains('termite')) return '🦟';
    return '🏠';
  }

  // ─────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: _navy,
      fontFamily: 'Outfit',
      letterSpacing: -0.2,
    ),
  );

  Widget _emptyState(String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: _blue.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.inbox_rounded,
              size: 34, color: _blue.withOpacity(0.4)),
        ),
        const SizedBox(height: 16),
        Text(msg,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _navy,
              fontFamily: 'Outfit',
            )),
      ],
    ),
  );
}