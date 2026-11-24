import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({Key? key}) : super(key: key);

  static const List<Map<String, dynamic>> services = [
    {
      'title': 'Cleaning',
      'icon': Icons.cleaning_services_rounded,
      'color': Color(0xFF6C63FF),
      'bgColor': Color(0xFFEEEDFF),
      'description': 'Deep & regular home cleaning by verified professionals.',
    },
    {
      'title': 'Wall Paint',
      'icon': Icons.format_paint_rounded,
      'color': Color(0xFFFF6584),
      'bgColor': Color(0xFFFFEEF2),
      'description': 'Premium interior & exterior painting for a vibrant finish.',
    },
    {
      'title': 'AC Repair',
      'icon': Icons.ac_unit_rounded,
      'color': Color(0xFF00B4D8),
      'bgColor': Color(0xFFE0F7FC),
      'description': 'Expert AC servicing for peak cooling efficiency.',
    },
    {
      'title': 'Plumber',
      'icon': Icons.plumbing_rounded,
      'color': Color(0xFF43AA8B),
      'bgColor': Color(0xFFE8F5F1),
      'description': 'Leaks, pipe installs, and bathroom & kitchen repairs.',
    },
    {
      'title': 'Furniture',
      'icon': Icons.chair_rounded,
      'color': Color(0xFFFF9F1C),
      'bgColor': Color(0xFFFFF4E0),
      'description': 'Custom design, repair, and assembly for your home.',
    },
    {
      'title': 'Pesticides',
      'icon': Icons.bug_report_rounded,
      'color': Color(0xFFE63946),
      'bgColor': Color(0xFFFFECED),
      'description': 'Safe, targeted solutions to protect your home.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What do you need\nhelp with today?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                        height: 1.3,
                        fontFamily: 'Outfit',
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trusted professionals at your doorstep.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final service = services[index];
                  return FadeInUp(
                    duration: Duration(milliseconds: 400 + (index * 80)),
                    child: _ServiceCard(
                      title: service['title'],
                      icon: service['icon'],
                      accentColor: service['color'],
                      bgColor: service['bgColor'],
                      description: service['description'],
                    ),
                  );
                },
                childCount: services.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -10,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF).withOpacity(0.18),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: 20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
                    ),
                    child: const Text(
                      '✦  Premium Services',
                      style: TextStyle(
                        color: Color(0xFFB8B4FF),
                        fontSize: 12,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Our Services',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Outfit',
                      letterSpacing: -0.5,
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
}

class _ServiceCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final String description;

  const _ServiceCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.description,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.pushNamed(
          context,
          '/service_detail',
          arguments: {'serviceName': widget.title, 'icon': widget.icon},
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Icon badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, size: 24, color: widget.accentColor),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  fontFamily: 'Outfit',
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Description
              Expanded(
                child: Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontFamily: 'Outfit',
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              // Book now
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Book now',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Outfit',
                      color: widget.accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 13, color: widget.accentColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}