import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> services = const [
    {
      'title': 'Cleaning',
      'icon': Icons.cleaning_services,
      'description': 'Comprehensive home cleaning services, including deep cleaning and regular maintenance.',
    },
    {
      'title': 'Wall Paint',
      'icon': Icons.format_paint,
      'description': 'Professional interior and exterior paint with premium quality paints for a vibrant finish.',
    },
    {
      'title': 'AC Repair',
      'icon': Icons.ac_unit,
      'description': 'Expert repair and maintenance for air conditioners, ensuring optimal efficiency.',
    },
    {
      'title': 'Plumber',
      'icon': Icons.plumbing,
      'description': 'Reliable plumbing services for leaks, pipe installations, and bathroom/kitchen repairs.',
    },
    {
      'title': 'Furniture',
      'icon': Icons.chair,
      'description': 'Custom furniture design, repair, and assembly for a stylish and functional home.',
    },
    {
      'title': 'Pesticides',
      'icon': Icons.bug_report,
      'description': 'Safe and effective pest control solutions to protect your home from unwanted pests.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Our Services',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Center(
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: const Text(
                      'Our Premium Services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Introduction
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: const Text(
                    'We offer a wide range of home services delivered by verified and trained professionals. Choose a service below to learn more or book now.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Services Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      itemCount: services.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth > 800 ? 3 : 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: constraints.maxWidth > 800 ? 0.9 : 0.7,
                      ),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return FadeInUp(
                          duration: Duration(milliseconds: 400 + (index * 100)),
                          child: _buildServiceCard(
                            context,
                            title: service['title'],
                            icon: service['icon'],
                            description: service['description'],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {required String title, required IconData icon, required String description}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/service_detail',
          arguments: {'serviceName': title, 'icon': icon},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.95), Colors.white70],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade900, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Outfit',
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87.withOpacity(0.7),
                      fontFamily: 'Outfit',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}