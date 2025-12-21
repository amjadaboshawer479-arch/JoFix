import 'package:flutter/material.dart';
import 'client_screen.dart';
import 'provider_screen.dart';
import 'package:amjad/screen/admain_admin_full.dart';

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
      backgroundColor: Colors.white,
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
                          Image.asset("imagee/lojo2.jpg", height: 220),
                          const SizedBox(height: 30),
                          const Text(
                            "Find Your\nPerfect Fix",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF00457C),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Whether it's maintenance, cleaning, or care, find the right expert to get the job done.",
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

            Positioned(
              top: 20,
              left: 20,
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
                  color: Colors.transparent, // لون واضح بدل الشفاف
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
