// lib/about_us.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  static const Color _navy    = Color(0xFF0D2137);
  static const Color _blue    = Color(0xFF1565C0);
  static const Color _surface = Color(0xFFF4F7FB);

  static const List<Map<String, dynamic>> _stats = [
    {'value': '10K+', 'label': 'Happy Customers', 'icon': Icons.people_rounded,              'color': Color(0xFF1565C0)},
    {'value': '500+', 'label': 'Experts',          'icon': Icons.verified_rounded,            'color': Color(0xFF00897B)},
    {'value': '4.8★', 'label': 'Avg Rating',       'icon': Icons.star_rounded,                'color': Color(0xFFF57C00)},
    {'value': '6',    'label': 'Services',          'icon': Icons.home_repair_service_rounded, 'color': Color(0xFF7B1FA2)},
  ];

  static const List<Map<String, dynamic>> _values = [
    {
      'icon': Icons.verified_user_rounded,
      'color': Color(0xFF1565C0),
      'bg': Color(0xFFE3F0FF),
      'title': 'Verified Professionals',
      'desc': 'Every expert is background-checked, trained, and certified before joining our network.',
    },
    {
      'icon': Icons.schedule_rounded,
      'color': Color(0xFF00897B),
      'bg': Color(0xFFE0F2F1),
      'title': 'On-Time, Every Time',
      'desc': 'We respect your schedule. Our professionals arrive within the confirmed time window.',
    },
    {
      'icon': Icons.price_check_rounded,
      'color': Color(0xFFF57C00),
      'bg': Color(0xFFFFF3E0),
      'title': 'Transparent Pricing',
      'desc': 'No hidden charges. You see the full price before you confirm your booking.',
    },
    {
      'icon': Icons.refresh_rounded,
      'color': Color(0xFF7B1FA2),
      'bg': Color(0xFFF3E5F5),
      'title': 'Free Re-service',
      'desc': 'Not satisfied? We\'ll send a professional back at no extra cost — guaranteed.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsSection(),
                _buildMissionSection(),
                _buildValuesSection(),
                _buildCtaSection(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── SLIVER APP BAR ────────────────────────────────────────
  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: _navy,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_navy, _blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Opacity(
              opacity: 0.06,
              child: CustomPaint(painter: _DotGridPainter()),
            ),
            Positioned(top: -40, right: -40, child: _circle(180, 0.06)),
            Positioned(bottom: -20, left: -20, child: _circle(130, 0.04)),
            Positioned(top: 60, right: 60,   child: _circle(60,  0.08)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.home_repair_service_rounded,
                                color: Colors.amber, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Home Services, Reimagined',
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
                    ),
                    const SizedBox(height: 12),
                    FadeInDown(
                      duration: const Duration(milliseconds: 700),
                      child: const Text(
                        'About\nKnockMan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Outfit',
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        'Connecting homes with trusted professionals\nsince 2022.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STATS SECTION ─────────────────────────────────────────
  Widget _buildStatsSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Row(
            children: List.generate(_stats.length, (i) {
              final s = _stats[i];
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (s['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(s['icon'] as IconData,
                          color: s['color'] as Color, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s['value'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: s['color'] as Color,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── MISSION SECTION ───────────────────────────────────────
  Widget _buildMissionSection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 450),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [_navy, _blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(top: -20, right: -20, child: _circle(120, 0.07)),
            Positioned(bottom: -10, left: 40, child: _circle(70, 0.05)),
            Opacity(
              opacity: 0.05,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(
                  painter: _DotGridPainter(),
                  child: const SizedBox(width: double.infinity, height: 180),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.flag_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Our Mission',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'At KnockMan, we believe every home deserves the best care. We connect you with verified, skilled professionals who treat your home like their own — with reliability, craftsmanship, and pride in every job.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14.5,
                      fontFamily: 'Outfit',
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      '✦  Founded in Ahmedabad, India · 2022',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                      ),
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

  // ── VALUES SECTION ────────────────────────────────────────
  Widget _buildValuesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(
            duration: const Duration(milliseconds: 400),
            child: _sectionHeader(
              label: 'WHY KNOCKMAN',
              title: 'Our Core Values',
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_values.length, (i) {
            final v = _values[i];
            return FadeInUp(
              duration: Duration(milliseconds: 350 + i * 60),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: v['bg'] as Color,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(v['icon'] as IconData,
                          color: v['color'] as Color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            v['title'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v['desc'] as String,
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
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── CTA SECTION ───────────────────────────────────────────
  Widget _buildCtaSection(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.headset_mic_rounded,
                  color: _blue, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              'Have a Question?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _navy,
                fontFamily: 'Outfit',
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our support team is available Monday–Saturday,\n9 AM – 7 PM IST.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontFamily: 'Outfit',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/contact'),
                icon: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18),
                label: const Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Outfit',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────
  Widget _sectionHeader({required String label, required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _blue,
              fontFamily: 'Outfit',
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _navy,
            fontFamily: 'Outfit',
            letterSpacing: -0.3,
          ),
        ),
      ],
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
}

// ── DOT GRID PAINTER ──────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    const spacing = 20.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}