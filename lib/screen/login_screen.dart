import 'package:flutter/material.dart';
import 'client_screen.dart';
import 'provider_screen.dart';
import 'admain.dart'; // صفحة الأدمن

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const Color brown = Color(0xFFB68645);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page", style: TextStyle(color: Colors.white)),
        backgroundColor: brown,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 160),
                // زر الكلينت
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClientHomePage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login as a Client",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // زر البروفايدر
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ServiseProviderLogin(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login as a Service Provider",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Spacer(), // يرفع النص للأسفل
                const Text(
                  "Thanks for using JoFix",
                  style: TextStyle(color: brown, fontSize: 20),
                ),
                const SizedBox(height: 20), // مسافة من الأسفل
              ],
            ),
          ),
          // زر الأدمن في الزاوية السفلية اليمنى
          // زر الأدمن في الزاوية السفلية اليمنى
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onLongPress: () async {
                // اضغط لمدة 3 ثواني قبل الانتقال
                await Future.delayed(const Duration(seconds: 3));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
