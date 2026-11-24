// lib/profile_manager.dart
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManager {
  static File? profilePhoto;
  static String userName = 'User';
  static String email = '';
  static String mobile = '';
  static String address = '';
  static String role = 'user'; // user | vendor | admin

  static Future loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? 'User';
    email = prefs.getString('email') ?? '';
    mobile = prefs.getString('mobile') ?? '';
    address = prefs.getString('address') ?? '';
    role = prefs.getString('role') ?? 'user';
  }

  static Future saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('userName', userName),
      prefs.setString('email', email),
      prefs.setString('mobile', mobile),
      prefs.setString('address', address),
      prefs.setString('role', role),
    ]);
  }

  static void updateField(String field, String value) {
    switch (field) {
      case 'name': userName = value; break;
      case 'email': email = value; break;
      case 'mobile': mobile = value; break;
      case 'address': address = value; break;
      case 'role': role = value; break;
    }
    saveProfile();
  }
}