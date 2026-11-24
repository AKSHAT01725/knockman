// lib/booking_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'order_manager.dart';

class BookingPage extends StatefulWidget {
  final String serviceName;
  final String price;
  const BookingPage({Key? key, required this.serviceName, required this.price}) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.serviceName}'), backgroundColor: Colors.blue[900]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInUp(child: Text('Book ${widget.serviceName}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Outfit'))),
            const SizedBox(height: 20),
            FadeInUp(child: Text('Price: ${widget.price} | COD', style: TextStyle(fontSize: 18, color: Colors.blue[900], fontWeight: FontWeight.bold, fontFamily: 'Outfit'))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(selectedDate == null ? 'Select Date' : selectedDate!.toLocal().toString().split(' ')[0], style: const TextStyle(fontFamily: 'Outfit')),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
                if (d != null) setState(() => selectedDate = d);
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.blue),
              title: Text(selectedTime == null ? 'Select Time' : selectedTime!.format(context), style: const TextStyle(fontFamily: 'Outfit')),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (t != null) setState(() => selectedTime = t);
              },
            ),
            const SizedBox(height: 10),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Mobile', prefixText: '+91 ', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 30),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: () => _confirmBooking(context),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('CONFIRM BOOKING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext context) async {
    if (selectedDate == null || selectedTime == null || phoneController.text.isEmpty || addressController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid mobile')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      await OrderManager.addOrder(
        userId: user.uid,
        service: widget.serviceName,
        price: widget.price,
        date: selectedDate!.toLocal().toString().split(' ')[0],
        time: selectedTime!.format(context),
        address: addressController.text,
        description: descriptionController.text,
        phone: phoneController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Booking submitted! Awaiting vendor approval.'),
          backgroundColor: Colors.green[700],
          action: SnackBarAction(label: 'My Orders', onPressed: () => Navigator.pushNamed(context, '/orders')),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}