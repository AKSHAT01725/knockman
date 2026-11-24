// lib/service_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

// ─────────────────────────────────────────────────────────────
//  SERVICE DETAIL PAGE  –  Premium editorial design
// ─────────────────────────────────────────────────────────────
class ServiceDetailPage extends StatefulWidget {
  final String serviceName;
  final IconData icon;

  const ServiceDetailPage({
    Key? key,
    required this.serviceName,
    required this.icon,
  }) : super(key: key);

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  double _heroOpacity = 1.0;
  int? _hoveredIndex;

  // ── palette ──────────────────────────────────────────────
  static const Color _ink = Color(0xFF0A1628);
  static const Color _navy = Color(0xFF0D2137);
  static const Color _blue = Color(0xFF1565C0);
  static const Color _sky = Color(0xFF00B4D8);
  static const Color _surface = Color(0xFFF4F7FB);
  static const Color _card = Colors.white;

  // ── per-service theming ───────────────────────────────────
  static const Map<String, Map<String, dynamic>> _serviceTheme = {
    'Cleaning': {
      'gradient': [Color(0xFF1565C0), Color(0xFF00B4D8)],
      'tag': 'Most Booked',
      'tagColor': Color(0xFF00B4D8),
      'rating': '4.8',
      'reviews': '2.3k',
      'badge': '✦ Top Rated',
    },
    'Wall Paint': {
      'gradient': [Color(0xFF6A1B9A), Color(0xFFE91E8C)],
      'tag': 'Popular',
      'tagColor': Color(0xFFE91E8C),
      'rating': '4.7',
      'reviews': '1.8k',
      'badge': '✦ Premium',
    },
    'AC Repair': {
      'gradient': [Color(0xFF00695C), Color(0xFF00BCD4)],
      'tag': 'Fast Response',
      'tagColor': Color(0xFF00BCD4),
      'rating': '4.9',
      'reviews': '3.1k',
      'badge': '✦ Expert',
    },
    'Plumber': {
      'gradient': [Color(0xFF1B5E20), Color(0xFF66BB6A)],
      'tag': '24/7 Available',
      'tagColor': Color(0xFF66BB6A),
      'rating': '4.6',
      'reviews': '1.5k',
      'badge': '✦ Reliable',
    },
    'Furniture': {
      'gradient': [Color(0xFFBF360C), Color(0xFFFFAB40)],
      'tag': 'Custom Work',
      'tagColor': Color(0xFFFFAB40),
      'rating': '4.7',
      'reviews': '980',
      'badge': '✦ Craftsmen',
    },
    'Pesticides': {
      'gradient': [Color(0xFF37474F), Color(0xFF78909C)],
      'tag': 'Safe & Certified',
      'tagColor': Color(0xFF78909C),
      'rating': '4.8',
      'reviews': '1.2k',
      'badge': '✦ Certified',
    },
  };

  // ── data ─────────────────────────────────────────────────
  final Map<String, Map<String, String>> _mainServiceData = {
    'Cleaning': {
      'description':
      'Our professional cleaning crew handles everything from deep scrubs to routine upkeep — leaving every corner spotless and fresh.',
      'price': '₹2,500 – ₹10,000',
      'image': 'assets/clean.jpg',
      'duration': '2 – 6 hrs',
      'professionals': '50+',
    },
    'Wall Paint': {
      'description':
      'Transform your space with our premium interior and exterior painting services, using certified paints for a lasting, vibrant finish.',
      'price': '₹5,000 – ₹20,000',
      'image': 'assets/paint.jpg',
      'duration': '1 – 3 days',
      'professionals': '30+',
    },
    'AC Repair': {
      'description':
      'Fast, reliable repair and maintenance for all AC brands — restoring optimal cooling and energy efficiency in no time.',
      'price': '₹1,500 – ₹8,000',
      'image': 'assets/repair.jpg',
      'duration': '1 – 3 hrs',
      'professionals': '40+',
    },
    'Plumber': {
      'description':
      'Comprehensive plumbing for leaks, pipe installations, and bathroom or kitchen repairs — delivered by licensed professionals.',
      'price': '₹1,000 – ₹5,000',
      'image': 'assets/plumber.jpg',
      'duration': '1 – 4 hrs',
      'professionals': '35+',
    },
    'Furniture': {
      'description':
      'Custom design, precision assembly, and expert repair services to bring stunning, functional furniture into your home.',
      'price': '₹3,000 – ₹15,000',
      'image': 'assets/furniture.jpg',
      'duration': '2 – 5 hrs',
      'professionals': '20+',
    },
    'Pesticides': {
      'description':
      'Safe, government-certified pest control solutions to permanently protect your home from termites, rodents, and more.',
      'price': '₹2,000 – ₹7,000',
      'image': 'assets/pesticides.jpg',
      'duration': '1 – 3 hrs',
      'professionals': '25+',
    },
  };

  final Map<String, List<Map<String, String>>> _subServicesData = {
    'Cleaning': [
      {'title': 'Home Cleaning', 'desc': 'Full house cleaning — floors, windows & furniture.', 'price': '₹3,000 – ₹8,000', 'duration': '3-6 hrs', 'icon': '🏠'},
      {'title': 'Bathroom Cleaning', 'desc': 'Deep clean tiles, fixtures & drainage.', 'price': '₹1,000 – ₹2,500', 'duration': '1-2 hrs', 'icon': '🚿'},
      {'title': 'Kitchen Cleaning', 'desc': 'Appliances, cabinets & countertop detailing.', 'price': '₹1,500 – ₹3,000', 'duration': '2-3 hrs', 'icon': '🍳'},
      {'title': 'Sofa Cleaning', 'desc': 'Professional upholstery steam cleaning.', 'price': '₹800 – ₹2,000', 'duration': '1-2 hrs', 'icon': '🛋️'},
      {'title': 'Carpet Cleaning', 'desc': 'Deep clean & stubborn stain removal.', 'price': '₹1,200 – ₹2,500', 'duration': '2-3 hrs', 'icon': '🧹'},
    ],
    'Wall Paint': [
      {'title': 'Interior Painting', 'desc': 'Walls & ceilings with premium finish.', 'price': '₹4,000 – ₹15,000', 'duration': '1-2 days', 'icon': '🖌️'},
      {'title': 'Exterior Painting', 'desc': 'Weather-resistant outdoor coatings.', 'price': '₹6,000 – ₹20,000', 'duration': '2-4 days', 'icon': '🏗️'},
      {'title': 'Texture Painting', 'desc': 'Decorative 3D texture wall finishes.', 'price': '₹5,000 – ₹12,000', 'duration': '1-3 days', 'icon': '🎨'},
      {'title': 'Wallpaper', 'desc': 'Professional application & removal.', 'price': '₹2,000 – ₹8,000', 'duration': '4-8 hrs', 'icon': '📋'},
      {'title': 'Paint Removal', 'desc': 'Safe stripping of old paint layers.', 'price': '₹1,500 – ₹5,000', 'duration': '1-2 days', 'icon': '🔧'},
    ],
    'AC Repair': [
      {'title': 'AC Servicing', 'desc': 'Routine maintenance & deep cleaning.', 'price': '₹1,000 – ₹3,000', 'duration': '1-2 hrs', 'icon': '❄️'},
      {'title': 'AC Installation', 'desc': 'Professional split & window AC setup.', 'price': '₹2,000 – ₹5,000', 'duration': '2-4 hrs', 'icon': '⚙️'},
      {'title': 'Gas Filling', 'desc': 'Refrigerant recharge for max cooling.', 'price': '₹1,500 – ₹4,000', 'duration': '1-2 hrs', 'icon': '💨'},
      {'title': 'AC Uninstallation', 'desc': 'Safe and careful unit removal.', 'price': '₹1,000 – ₹2,500', 'duration': '1-2 hrs', 'icon': '🔌'},
      {'title': 'AC Repair', 'desc': 'Fault diagnosis and part replacement.', 'price': '₹1,500 – ₹8,000', 'duration': '1-4 hrs', 'icon': '🛠️'},
    ],
    'Plumber': [
      {'title': 'Leak Repair', 'desc': 'Fixing leaks in pipes, faucets & joints.', 'price': '₹800 – ₹2,000', 'duration': '1-2 hrs', 'icon': '💧'},
      {'title': 'Pipe Installation', 'desc': 'New piping layout and installation.', 'price': '₹1,500 – ₹5,000', 'duration': '2-6 hrs', 'icon': '🔩'},
      {'title': 'Bathroom Fixtures', 'desc': 'Shower, tap & toilet installation.', 'price': '₹1,000 – ₹3,000', 'duration': '2-4 hrs', 'icon': '🚰'},
      {'title': 'Kitchen Sink', 'desc': 'Repair and upgrade kitchen sinks.', 'price': '₹1,200 – ₹2,500', 'duration': '1-3 hrs', 'icon': '🪣'},
      {'title': 'Water Heater', 'desc': 'Geyser & water heater installation.', 'price': '₹2,000 – ₹6,000', 'duration': '2-4 hrs', 'icon': '🔥'},
    ],
    'Furniture': [
      {'title': 'Assembly', 'desc': 'Flat-pack and modular furniture assembly.', 'price': '₹1,000 – ₹3,000', 'duration': '2-5 hrs', 'icon': '🪛'},
      {'title': 'Furniture Repair', 'desc': 'Restore and fix damaged pieces.', 'price': '₹1,500 – ₹5,000', 'duration': '2-4 hrs', 'icon': '🔨'},
      {'title': 'Custom Design', 'desc': 'Bespoke furniture crafted to order.', 'price': '₹5,000 – ₹15,000', 'duration': '3-7 days', 'icon': '✏️'},
      {'title': 'Polishing', 'desc': 'Full refinishing of wooden surfaces.', 'price': '₹1,000 – ₹4,000', 'duration': '2-4 hrs', 'icon': '✨'},
      {'title': 'Upholstery', 'desc': 'Fabric cleaning and reupholstering.', 'price': '₹1,200 – ₹3,500', 'duration': '2-5 hrs', 'icon': '🪑'},
    ],
    'Pesticides': [
      {'title': 'Termite Control', 'desc': 'Certified termite treatment & prevention.', 'price': '₹2,000 – ₹5,000', 'duration': '2-4 hrs', 'icon': '🐛'},
      {'title': 'Cockroach Control', 'desc': 'Gel and spray treatment.', 'price': '₹1,000 – ₹3,000', 'duration': '1-2 hrs', 'icon': '🪳'},
      {'title': 'Bed Bug Control', 'desc': 'Heat and chemical bed bug removal.', 'price': '₹1,500 – ₹4,000', 'duration': '2-3 hrs', 'icon': '🛏️'},
      {'title': 'Rodent Control', 'desc': 'Trapping and exclusion service.', 'price': '₹1,200 – ₹3,500', 'duration': '1-3 hrs', 'icon': '🐀'},
      {'title': 'Mosquito Control', 'desc': 'Fogging and larvicide treatment.', 'price': '₹1,000 – ₹2,500', 'duration': '1-2 hrs', 'icon': '🦟'},
    ],
  };

  // ── trust badges ──────────────────────────────────────────
  static const List<Map<String, String>> _trustBadges = [
    {'icon': '🛡️', 'label': 'Verified Pros'},
    {'icon': '⚡', 'label': 'Fast Booking'},
    {'icon': '💰', 'label': 'Best Price'},
    {'icon': '🔄', 'label': 'Free Revisit'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      setState(() {
        _heroOpacity = (1 - offset / 220).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _serviceTheme[widget.serviceName] ?? _serviceTheme['Cleaning']!;
    final gradColors = (theme['gradient'] as List).cast<Color>();
    final main = _mainServiceData[widget.serviceName] ??
        {'description': '', 'price': '₹2,000+', 'image': '', 'duration': '—', 'professionals': '—'};
    final subs = _subServicesData[widget.serviceName] ?? [];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _surface,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // ── HERO SLIVER ──────────────────────────────
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  stretch: true,
                  backgroundColor: gradColors[0],
                  leading: _backButton(),
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: _buildHero(gradColors, theme, main),
                  ),
                ),

                // ── BODY ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Stats strip ──
                      _buildStatsStrip(main, theme),

                      // ── Trust badges ──
                      _buildTrustBadges(),

                      // ── About ──
                      _buildAboutSection(main),

                      // ── Services grid ──
                      _buildServicesSection(subs),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),

            // ── FLOATING BOTTOM BAR ───────────────────────
            _buildBottomBar(main),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  HERO
  // ─────────────────────────────────────────────────────────
  Widget _buildHero(
      List<Color> gradColors, Map<String, dynamic> theme, Map<String, String> main) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // subtle dot-grid pattern
        Opacity(
          opacity: 0.06,
          child: CustomPaint(painter: _DotGridPainter()),
        ),

        // blurred image overlay
        Positioned.fill(
          child: Image.asset(
            main['image']!,
            fit: BoxFit.cover,
            color: gradColors[0].withOpacity(0.65),
            colorBlendMode: BlendMode.srcOver,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),

        // content
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
            opacity: _heroOpacity,
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 60, 22, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, gradColors[0].withOpacity(0.9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      theme['badge'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // service name
                  Text(
                    widget.serviceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Outfit',
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // rating row
                  Row(
                    children: [
                      ...List.generate(
                        5,
                            (i) => Icon(
                          i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${theme['rating']}  (${theme['reviews']} reviews)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // tag pill
        Positioned(
          top: 90,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (theme['tagColor'] as Color).withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              theme['tag'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  STATS STRIP
  // ─────────────────────────────────────────────────────────
  Widget _buildStatsStrip(Map<String, String> main, Map<String, dynamic> theme) {
    final gradColors = (theme['gradient'] as List).cast<Color>();
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradColors[0].withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _statItem(main['price']!, 'Price Range', gradColors[0]),
            _divider(),
            _statItem(main['duration']!, 'Duration', gradColors[0]),
            _divider(),
            _statItem(main['professionals']!, 'Experts', gradColors[0]),
            _divider(),
            _statItem(theme['rating'] as String, 'Rating', gradColors[0]),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
              fontFamily: 'Outfit',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontFamily: 'Outfit',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: Colors.grey.shade100);

  // ─────────────────────────────────────────────────────────
  //  TRUST BADGES
  // ─────────────────────────────────────────────────────────
  Widget _buildTrustBadges() {
    return FadeInUp(
      duration: const Duration(milliseconds: 450),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: _trustBadges
              .map(
                (b) => Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: b == _trustBadges.last ? 0 : 8,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(b['icon']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      b['label']!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                        fontFamily: 'Outfit',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  ABOUT SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildAboutSection(Map<String, String> main) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('About the Service'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                main['description']!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.65,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SERVICES SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildServicesSection(List<Map<String, String>> subs) {
    final theme = _serviceTheme[widget.serviceName] ?? _serviceTheme['Cleaning']!;
    final gradColors = (theme['gradient'] as List).cast<Color>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Select a Service'),
          const SizedBox(height: 4),
          Text(
            '${subs.length} services available',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(subs.length, (i) {
            final s = subs[i];
            return FadeInUp(
              duration: Duration(milliseconds: 400 + i * 60),
              child: _buildServiceCard(s, gradColors, i),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      Map<String, String> s, List<Color> gradColors, int index) {
    final isHovered = _hoveredIndex == index;

    return GestureDetector(
      onTapDown: (_) => setState(() => _hoveredIndex = index),
      onTapUp: (_) {
        setState(() => _hoveredIndex = null);
        HapticFeedback.lightImpact();
        Navigator.pushNamed(
          context,
          '/booking',
          arguments: {'serviceName': s['title'], 'price': s['price']},
        );
      },
      onTapCancel: () => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? gradColors[0].withOpacity(0.18)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isHovered ? 20 : 12,
              offset: Offset(0, isHovered ? 8 : 4),
            ),
          ],
          border: Border.all(
            color: isHovered ? gradColors[0].withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // emoji icon box
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradColors[0].withOpacity(0.12),
                      gradColors[1].withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(s['icon']!, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),

              // text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            s['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s['desc']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontFamily: 'Outfit',
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // price chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gradColors[0].withOpacity(0.12),
                                gradColors[1].withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            s['price']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: gradColors[0],
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),

                        const Spacer(),

                        // book button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isHovered
                                  ? gradColors
                                  : [gradColors[0], gradColors[0]],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isHovered
                                ? [
                              BoxShadow(
                                color: gradColors[0].withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                                : [],
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  FLOATING BOTTOM BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomBar(Map<String, String> main) {
    final theme = _serviceTheme[widget.serviceName] ?? _serviceTheme['Cleaning']!;
    final gradColors = (theme['gradient'] as List).cast<Color>();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Starting from',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  main['price']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: gradColors[0],
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  // scroll to services section
                  _scrollController.animateTo(
                    600,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradColors),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradColors[0].withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Book a Service',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: _ink,
        fontFamily: 'Outfit',
        letterSpacing: -0.3,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DOT GRID PATTERN PAINTER
// ─────────────────────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 22.0;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}