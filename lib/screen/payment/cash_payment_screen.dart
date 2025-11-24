import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:amjad/screen/client_screen.dart';

class CashPaymentScreen extends StatelessWidget {
  final String serviceName;
  final String providerId;
  final double price;

  const CashPaymentScreen({
    super.key,
    required this.serviceName,
    required this.providerId,
    required this.price,
  });

  Future<void> _placeOrder(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'clientId': user.uid,
        'providerId': providerId,
        'serviceName': serviceName,
        'price': price,
        'paymentMethod': 'cash',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Order placed! We’ll notify the provider.')));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ActivityHomeScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Failed to place order: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Cash Payment', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF00457C), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.money, color: Colors.white, size: 40)),
            const SizedBox(height: 20),
            const Text('Cash Payment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('You will pay in cash after the service is completed.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 32),
            ...[
              '✅ Pay only after work is done',
              '✅ No extra fees',
              '✅ Receipt provided',
            ]
                .map((text) => Row(children: [const Icon(Icons.check_circle, color: Color(0xFF00457C)), const SizedBox(width: 10), Text(text)]))
                .toList(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00457C),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _placeOrder(context),
                child: const Text('Confirm & Place Order', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}