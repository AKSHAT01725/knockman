// lib/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'profile_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> services = const [
    {'title': 'Cleaning',   'icon': Icons.cleaning_services, 'color': Colors.blue},
    {'title': 'Plumber',    'icon': Icons.plumbing,          'color': Colors.green},
    {'title': 'Furniture',  'icon': Icons.event_seat,        'color': Colors.orange},
    {'title': 'AC Repair',  'icon': Icons.ac_unit,           'color': Colors.cyan},
    {'title': 'Pesticides', 'icon': Icons.bug_report,        'color': Colors.red},
    {'title': 'Wall Paint', 'icon': Icons.format_paint,      'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _checkBannedStatus();
  }

  Future<void> _checkBannedStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists && userDoc['isBanned'] == true) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Your account is banned.')),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  // ── refresh ProfileManager then rebuild drawer ────────────
  Future<void> _refreshProfile() async {
    await ProfileManager.loadProfile();
    if (mounted) setState(() {});
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[900],
        title: const Text(
          'Knock Man',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),

      endDrawer: _buildDrawer(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HERO HEADER ───────────────────────────────
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0A1F44),
                      Color(0xFF1565C0),
                      Color(0xFF1E88E5)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade900.withOpacity(0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30, top: -30,
                      child: Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20, bottom: -20,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CustomPaint(painter: _DotGridPainter()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.verified_rounded,
                                    color: Colors.amber, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Trusted Home Services',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Outfit',
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Welcome to\nKnockMan',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFamily: 'Outfit',
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Book skilled professionals for any\nhome job — in just a tap.',
                            style: TextStyle(
                              fontSize: 14.5,
                              color: Colors.white.withOpacity(0.78),
                              fontFamily: 'Outfit',
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/services'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 13),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_rounded,
                                      color: Colors.blue.shade800,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Explore Services',
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            FadeInLeft(
              duration: const Duration(milliseconds: 600),
              child: const Text(
                'Our Services',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Outfit',
                ),
              ),
            ),

            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return FadeInUp(
                  duration:
                  Duration(milliseconds: 600 + (index * 100)),
                  child: _buildServiceCard(
                    context,
                    title: service['title'],
                    icon: service['icon'],
                    color: service['color'],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SERVICE CARD
  // ─────────────────────────────────────────────────────────
  Widget _buildServiceCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/service_detail',
          arguments: {'serviceName': title, 'icon': icon},
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  DRAWER
  // ─────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _drawerItem(
                  icon: Icons.person_rounded,
                  label: 'My Profile',
                  subtitle: 'View & edit your info',
                  route: '/profile',
                  iconColor: Colors.blue.shade700,
                  // ── await return then refresh drawer ──
                  onTapOverride: () async {
                    Navigator.pop(context);
                    await Navigator.pushNamed(context, '/profile');
                    await _refreshProfile();
                  },
                ),
                _drawerItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'My Orders',
                  subtitle: 'Track your bookings',
                  route: '/orders',
                  iconColor: Colors.green.shade600,
                ),
                _drawerItem(
                  icon: Icons.home_repair_service_rounded,
                  label: 'Services',
                  subtitle: 'Browse all services',
                  route: '/services',
                  iconColor: Colors.orange.shade600,
                ),
                _drawerItem(
                  icon: Icons.info_rounded,
                  label: 'About Us',
                  subtitle: 'Our story & team',
                  route: '/about',
                  iconColor: Colors.purple.shade600,
                ),
                _drawerItem(
                  icon: Icons.contact_support_rounded,
                  label: 'Contact Us',
                  subtitle: 'Get in touch',
                  route: '/contact',
                  iconColor: Colors.teal.shade600,
                ),

                // vendor-only section
                if (ProfileManager.role == 'vendor') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                            child: Divider(color: Colors.grey.shade200)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10),
                          child: Text(
                            'VENDOR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade400,
                              letterSpacing: 1.4,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(color: Colors.grey.shade200)),
                      ],
                    ),
                  ),
                  _drawerItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Vendor Dashboard',
                    subtitle: 'Manage your orders',
                    route: '/vendor',
                    iconColor: Colors.blue.shade900,
                  ),
                ],
              ],
            ),
          ),

          // ── logout ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── drawer header ─────────────────────────────────────────
  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          22, MediaQuery.of(context).padding.top + 24, 22, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white38, width: 2),
            ),
            child: ProfileManager.profilePhoto != null
                ? ClipOval(
                child: Image.file(ProfileManager.profilePhoto!,
                    fit: BoxFit.cover))
                : const Icon(Icons.person_rounded,
                color: Colors.white, size: 34),
          ),
          const SizedBox(height: 14),

          // ── name — updates after _refreshProfile() ───────
          Text(
            ProfileManager.userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 3),

          // ── email ─────────────────────────────────────────
          Text(
            ProfileManager.email.isNotEmpty
                ? ProfileManager.email
                : 'knockman user',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontFamily: 'Outfit',
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // role badge
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Text(
              ProfileManager.role.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'Outfit',
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── single drawer row ─────────────────────────────────────
  Widget _drawerItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required String route,
    required Color iconColor,
    VoidCallback? onTapOverride, // optional override for async actions
  }) {
    return InkWell(
      onTap: onTapOverride ??
              () {
            Navigator.pop(context);
            Navigator.pushNamed(context, route);
          },
      borderRadius: BorderRadius.circular(14),
      splashColor: iconColor.withOpacity(0.08),
      highlightColor: iconColor.withOpacity(0.05),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D2137),
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── DOT GRID PAINTER ──────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const radius = 1.5;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}