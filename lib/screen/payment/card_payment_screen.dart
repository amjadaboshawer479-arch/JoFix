import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:amjad/screen/client_screen.dart';

class CardPaymentScreen extends StatefulWidget {
  final String serviceName;
  final String providerId;
  final double price;

  const CardPaymentScreen({
    super.key,
    required this.serviceName,
    required this.providerId,
    required this.price,
  });

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final TextEditingController _cardNumber = TextEditingController(text: '4242 4242 4242 4242');
  final TextEditingController _name = TextEditingController(text: 'JOHN DOE');
  final TextEditingController _expiry = TextEditingController(text: '12/28');
  final TextEditingController _cvv = TextEditingController(text: '123');
  bool _isProcessing = false;

  Future<void> _processCardPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection('orders').add({
        'clientId': user.uid,
        'providerId': widget.providerId,
        'serviceName': widget.serviceName,
        'price': widget.price,
        'paymentMethod': 'card',
        'status': 'paid',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Payment successful!')));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ActivityHomeScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Payment failed: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Card Payment', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF00457C), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.credit_card, color: Colors.white, size: 40)),
            const SizedBox(height: 20),
            const Text('Secure Card Payment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Enter your card details below', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            TextField(controller: _cardNumber, decoration: const InputDecoration(labelText: 'Card Number', prefixIcon: Icon(Icons.credit_card)), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Cardholder Name', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _expiry, decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', prefixIcon: Icon(Icons.calendar_today)))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _cvv, obscureText: true, decoration: const InputDecoration(labelText: 'CVV', prefixIcon: Icon(Icons.lock)))),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00457C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isProcessing ? null : _processCardPayment,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Pay Now', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.network('https://upload.wikimedia.org/wikipedia/commons/5/5e/Visa_Inc._logo.svg', height: 24),
              const SizedBox(width: 16),
              Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/800px-Mastercard-logo.svg.png', height: 24),
            ]),
            const SizedBox(height: 8),
            const Text('We do not store your card details', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}