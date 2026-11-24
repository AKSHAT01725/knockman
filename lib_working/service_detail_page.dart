import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ServiceDetailPage extends StatelessWidget {
  final String serviceName;
  final IconData icon;

  const ServiceDetailPage({
    Key? key,
    required this.serviceName,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Main service-specific data (description, price, image)
    final Map<String, Map<String, String>> mainServiceData = {
      'Cleaning': {
        'description': 'Our professional cleaning services include deep cleaning, regular maintenance, and specialized move-in/move-out cleaning to keep your home spotless.',
        'price': '₹2,500 - ₹10,000',
        'image': 'assets/clean.jpg',
      },
      'Wall Paint': {
        'description': 'Transform your home with our expert interior and exterior painting services, using high-quality paints for a lasting, vibrant finish.',
        'price': '₹5,000 - ₹20,000',
        'image': 'assets/paint.jpg',
      },
      'AC Repair': {
        'description': 'Fast and reliable repair and maintenance for air conditioners, ensuring optimal performance and energy efficiency.',
        'price': '₹1,500 - ₹8,000',
        'image': 'assets/repair.jpg',
      },
      'Plumber': {
        'description': 'Comprehensive plumbing solutions for leaks, pipe installations, and bathroom/kitchen repairs, delivered by skilled professionals.',
        'price': '₹1,000 - ₹5,000',
        'image': 'assets/plumber.jpg',
      },
      'Furniture': {
        'description': 'Custom furniture design, repair, and assembly services to create stylish and functional pieces for your home.',
        'price': '₹3,000 - ₹15,000',
        'image': 'assets/furniture.jpg',
      },
      'Pesticides': {
        'description': 'Safe and effective pest control solutions to protect your home from termites, rodents, and other pests.',
        'price': '₹2,000 - ₹7,000',
        'image': 'assets/pesticides.jpg',
      },
    };

    // Sub-services for each main service
    final Map<String, List<Map<String, String>>> subServicesData = {
      'Cleaning': [
        {
          'title': 'Home Cleaning',
          'description': 'Full house cleaning including floors, windows, and furniture.',
          'price': '₹3,000 - ₹8,000',
        },
        {
          'title': 'Bathroom Cleaning',
          'description': 'Deep cleaning of bathrooms, tiles, and fixtures.',
          'price': '₹1,000 - ₹2,500',
        },
        {
          'title': 'Kitchen Cleaning',
          'description': 'Cleaning of kitchen appliances, cabinets, and countertops.',
          'price': '₹1,500 - ₹3,000',
        },
        {
          'title': 'Sofa Cleaning',
          'description': 'Professional sofa and upholstery cleaning.',
          'price': '₹800 - ₹2,000',
        },
        {
          'title': 'Carpet Cleaning',
          'description': 'Deep carpet cleaning and stain removal.',
          'price': '₹1,200 - ₹2,500',
        },
      ],
      'Wall Paint': [
        {
          'title': 'Interior Painting',
          'description': 'Painting of indoor walls and ceilings.',
          'price': '₹4,000 - ₹15,000',
        },
        {
          'title': 'Exterior Painting',
          'description': 'Weather-resistant painting for outdoor surfaces.',
          'price': '₹6,000 - ₹20,000',
        },
        {
          'title': 'Texture Painting',
          'description': 'Decorative texture finishes for walls.',
          'price': '₹5,000 - ₹12,000',
        },
        {
          'title': 'Wallpaper Installation',
          'description': 'Professional wallpaper application and removal.',
          'price': '₹2,000 - ₹8,000',
        },
        {
          'title': 'Paint Removal',
          'description': 'Safe removal of old paint layers.',
          'price': '₹1,500 - ₹5,000',
        },
      ],
      'AC Repair': [
        {
          'title': 'AC Servicing',
          'description': 'Routine maintenance and cleaning of AC units.',
          'price': '₹1,000 - ₹3,000',
        },
        {
          'title': 'AC Installation',
          'description': 'Professional installation of new AC systems.',
          'price': '₹2,000 - ₹5,000',
        },
        {
          'title': 'AC Gas Filling',
          'description': 'Refilling of AC refrigerant gas.',
          'price': '₹1,500 - ₹4,000',
        },
        {
          'title': 'AC Uninstallation',
          'description': 'Safe removal of existing AC units.',
          'price': '₹1,000 - ₹2,500',
        },
        {
          'title': 'AC Repair',
          'description': 'Repair of faulty AC components.',
          'price': '₹1,500 - ₹8,000',
        },
      ],
      'Plumber': [
        {
          'title': 'Leak Repair',
          'description': 'Fixing leaks in pipes and faucets.',
          'price': '₹800 - ₹2,000',
        },
        {
          'title': 'Pipe Installation',
          'description': 'Installation of new piping systems.',
          'price': '₹1,500 - ₹5,000',
        },
        {
          'title': 'Bathroom Fixtures',
          'description': 'Installation and repair of bathroom fixtures.',
          'price': '₹1,000 - ₹3,000',
        },
        {
          'title': 'Kitchen Sink Repair',
          'description': 'Repair and installation of kitchen sinks.',
          'price': '₹1,200 - ₹2,500',
        },
        {
          'title': 'Water Heater Installation',
          'description': 'Installation of water heaters and geysers.',
          'price': '₹2,000 - ₹6,000',
        },
      ],
      'Furniture': [
        {
          'title': 'Furniture Assembly',
          'description': 'Assembly of flat-pack furniture.',
          'price': '₹1,000 - ₹3,000',
        },
        {
          'title': 'Furniture Repair',
          'description': 'Repair of damaged furniture pieces.',
          'price': '₹1,500 - ₹5,000',
        },
        {
          'title': 'Custom Furniture Design',
          'description': 'Design and creation of custom furniture.',
          'price': '₹5,000 - ₹15,000',
        },
        {
          'title': 'Furniture Polishing',
          'description': 'Polishing and refinishing of wooden furniture.',
          'price': '₹1,000 - ₹4,000',
        },
        {
          'title': 'Upholstery Cleaning',
          'description': 'Cleaning and repair of furniture upholstery.',
          'price': '₹1,200 - ₹3,500',
        },
      ],
      'Pesticides': [
        {
          'title': 'Termite Control',
          'description': 'Effective termite inspection and treatment.',
          'price': '₹2,000 - ₹5,000',
        },
        {
          'title': 'Cockroach Control',
          'description': 'Cockroach extermination and prevention.',
          'price': '₹1,000 - ₹3,000',
        },
        {
          'title': 'Bed Bug Control',
          'description': 'Bed bug removal and treatment.',
          'price': '₹1,500 - ₹4,000',
        },
        {
          'title': 'Rodent Control',
          'description': 'Rodent trapping and prevention.',
          'price': '₹1,200 - ₹3,500',
        },
        {
          'title': 'Mosquito Control',
          'description': 'Mosquito fogging and larvicide treatment.',
          'price': '₹1,000 - ₹2,500',
        },
      ],
    };

    final mainInfo = mainServiceData[serviceName] ?? {
      'description': 'Details and features of $serviceName service.',
      'price': '₹2,000 - ₹10,000',
      'image': 'assets/plumber.jpg', // Use an existing asset
    };

    final subServices = subServicesData[serviceName] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue[900],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                serviceName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Icon(
                      icon,
                      size: 60,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(4, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          mainInfo['image']!,
                          width: 400,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1200),
                    child: Text(
                      'About $serviceName',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1300),
                    child: Text(
                      mainInfo['description']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87.withOpacity(0.8),
                        height: 1.5,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1400),
                    child: const Text(
                      'Select Services',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: MediaQuery.of(context).size.width > 800 ? 0.8 : 0.7, // Adjusted for flexibility
                    ),
                    itemCount: subServices.length,
                    itemBuilder: (context, index) {
                      final subService = subServices[index];
                      return FadeInUp(
                        duration: Duration(milliseconds: 1500 + (index * 100)),
                        child: _buildSubServiceCard(
                          context,
                          subService['title']!,
                          subService['description']!,
                          subService['price']!,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubServiceCard(BuildContext context, String title, String description, String price) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 8),
            Expanded( // Makes description flexible
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87.withOpacity(0.7),
                  fontFamily: 'Outfit',
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3, // Limit lines to prevent overflow
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 8),
            Expanded( // Ensures button stays inside
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/booking',
                      arguments: {
                        'serviceName': title,
                        'price': price,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
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
}