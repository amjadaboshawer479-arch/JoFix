import 'package:flutter/material.dart';
import 'package:amjad/screen/payment/cash_payment_screen.dart';
import 'package:amjad/screen/payment/card_payment_screen.dart';

class PaymentMethodSelection extends StatelessWidget {
  final String serviceName;
  final String providerId;
  final double price;

  const PaymentMethodSelection({
    super.key,
    required this.serviceName,
    required this.providerId,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00457C),
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking **$serviceName**',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Total: JOD ${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),

            _buildPaymentOption(
              context,
              icon: Icons.account_balance_wallet_outlined,
              title: 'Cash Payment',
              subtitle: 'Pay after service completion',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CashPaymentScreen(
                      serviceName: serviceName,
                      providerId: providerId,
                      price: price,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildPaymentOption(
              context,
              icon: Icons.credit_card_outlined,
              title: 'Credit/Debit Card',
              subtitle: 'Secure payment via card',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardPaymentScreen(
                      serviceName: serviceName,
                      providerId: providerId,
                      price: price,
                    ),
                  ),
                );
              },
            ),

            const Spacer(),
            _buildSecurityNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF00457C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF00457C)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          'Secure & encrypted payment',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
