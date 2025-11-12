import 'package:flutter/material.dart';
import 'client_screen.dart';
import 'provider_screen.dart';
import 'admain.dart'; // صفحة الأدمن

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _hoveredIndex = -1;
  final Color mainColor = const Color(0xFF00457C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EE),
      body: SafeArea(
        child: Stack(
          children: [
            // المحتوى الأساسي
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // الصورة والنصوص
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/job_illustration.png",
                            height: 220,
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Discover Your\nDream Job here",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF00457C),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Explore all the existing job roles based on your interest and study major",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // الأزرار السفلية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // زر Client
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ClientHomePage(),
                                ),
                              );
                            },
                            child: MouseRegion(
                              onEnter: (_) => setState(() => _hoveredIndex = 0),
                              onExit: (_) => setState(() => _hoveredIndex = -1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: _hoveredIndex == 0
                                      ? Colors.white
                                      : mainColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: mainColor,
                                    width: 1.3,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Center(
                                  child: Text(
                                    "Client",
                                    style: TextStyle(
                                      color: _hoveredIndex == 0
                                          ? mainColor
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // زر Service Provider
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ServiseProviderLogin(),
                                ),
                              );
                            },
                            child: MouseRegion(
                              onEnter: (_) => setState(() => _hoveredIndex = 1),
                              onExit: (_) => setState(() => _hoveredIndex = -1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: _hoveredIndex == 1
                                      ? Colors.white
                                      : mainColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: mainColor,
                                    width: 1.3,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Center(
                                  child: Text(
                                    "Service Provider",
                                    style: TextStyle(
                                      color: _hoveredIndex == 1
                                          ? mainColor
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // زر الأدمن الشفاف
          ],
        ),
      ),
    );
  }
}
