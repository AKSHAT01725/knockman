// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'order_manager.dart';
import 'profile_manager.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'service_detail_page.dart';
import 'booking_page.dart';
import 'user_profile.dart';
import 'about_us.dart';
import 'services.dart';
import 'contact_us.dart';
import 'login_page.dart';
import 'admin_page.dart';
import 'vendor_page.dart';
import 'orders_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SAFE FIREBASE INIT
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCO6SanHOgs_9lF_m8kkh3Mxy8YSKGSgrw",
        authDomain: "knockman-476b4.firebaseapp.com",
        projectId: "knockman-476b4",
        storageBucket: "knockman-476b4.firebasestorage.app",
        messagingSenderId: "704875682387",
        appId: "1:704875682387:web:7451e953300ed87d3c04a6",
      ),
    );
  } else {
    await Firebase.initializeApp(); // Uses google-services.json
  }

  await OrderManager.init();
  await ProfileManager.loadProfile();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'KnockMan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Outfit',
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
        '/service_detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          return ServiceDetailPage(
            serviceName: args?['serviceName'] ?? 'Cleaning',
            icon: args?['icon'] ?? Icons.cleaning_services,
          );
        },
        '/booking': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map?;
          return BookingPage(
            serviceName: args?['serviceName'] ?? 'Cleaning',
            price: args?['price'] ?? '₹2,500 - ₹10,000',
          );
        },
        '/profile': (context) => const UserProfilePage(),
        '/about': (context) => const AboutUsPage(),
        '/services': (context) => const ServicesPage(),
        '/contact': (context) => const ContactUsPage(),
        '/orders': (context) => const OrdersPage(),
        '/admin': (context) => const AdminPage(),
        '/vendor': (context) => const VendorPage(),
      },
    );
  }
}