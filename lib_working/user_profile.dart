import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'profile_manager.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _nameController.text = ProfileManager.userName;
    _emailController.text = ProfileManager.email;
    _mobileController.text = ProfileManager.mobile;
    _addressController.text = ProfileManager.address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            FadeInUp(duration: const Duration(milliseconds: 800), child: _buildProfileHeader()),
            const SizedBox(height: 30),
            // Editable Fields
            FadeInUp(duration: const Duration(milliseconds: 1000), child: _buildEditSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue[900],
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ProfileManager.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                Text(ProfileManager.email, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontFamily: 'Outfit')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                ElevatedButton(
                  onPressed: _toggleEdit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                  child: Text(_isEditing ? 'Cancel' : 'Edit', style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isEditing) ...[
              _buildTextField('Name', _nameController, TextInputType.name),
              const SizedBox(height: 15),
              _buildTextField('Email', _emailController, TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildTextField('Mobile', _mobileController, TextInputType.phone),
              const SizedBox(height: 15),
              _buildTextField('Address', _addressController, TextInputType.streetAddress, maxLines: 2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('SAVE CHANGES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ] else ...[
              _buildInfoRow('Name', ProfileManager.userName),
              _buildInfoRow('Email', ProfileManager.email),
              _buildInfoRow('Mobile', ProfileManager.mobile),
              _buildInfoRow('Address', ProfileManager.address),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(_getIcon(label), color: Colors.blue[900]),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getIcon(label), color: Colors.blue[900], size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'Outfit'))),
        ],
      ),
    );
  }

  IconData _getIcon(String label) {
    switch (label) {
      case 'Name': return Icons.person;
      case 'Email': return Icons.email;
      case 'Mobile': return Icons.phone;
      case 'Address': return Icons.location_on;
      default: return Icons.info;
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) _loadProfile();
    });
  }

  void _saveProfile() {
    // Update ProfileManager
    ProfileManager.updateField('name', _nameController.text);
    ProfileManager.updateField('email', _emailController.text);
    ProfileManager.updateField('mobile', _mobileController.text);
    ProfileManager.updateField('address', _addressController.text);

    // Refresh UI & Menu
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Profile updated!'), backgroundColor: Colors.blue),
    );

    _toggleEdit();
  }
}