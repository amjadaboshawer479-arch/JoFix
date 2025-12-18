import 'package:flutter/material.dart';
import 'package:amjad/screen/login_screen.dart';

class TravelloOnboarding extends StatefulWidget {
  const TravelloOnboarding({super.key});

  @override
  State<TravelloOnboarding> createState() => _TravelloOnboardingState();
}

class _TravelloOnboardingState extends State<TravelloOnboarding> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "imagee/onBording.jpg",
      "title": "Find trusted services easily",
      "subtitle": "All your daily needs in one place",
    },
    {
      "image": "imagee/OnBording2.jpg",
      "title": "Book professionals instantly",
      "subtitle": "Fast, reliable, and affordable help",
    },
    {
      "image": "imagee/Onbording3.jpg",
      "title": "Relax, we’ll handle the rest",
      "subtitle": "From cleaning to repair — we’ve got you covered",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            //  (PageView.builder)
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = onboardingData[index];
                  return OnboardingPageContent(
                    data: data,
                    index: index,
                    currentIndex: _currentIndex,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: List.generate(
                      onboardingData.length,
                          (dotIndex) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: _currentIndex == dotIndex ? 20 : 6,
                        decoration: BoxDecoration(
                          color: _currentIndex == dotIndex
                              ? const Color(0xFF00457C)
                              : const Color(0xFF00457C).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (_currentIndex == onboardingData.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 50,
                      width: _currentIndex == onboardingData.length - 1
                          ? 140
                          : 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00457C),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: _currentIndex == onboardingData.length - 1
                            ? const Text(
                          "Get Started",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            : const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final Map<String, String> data;
  final int index;
  final int currentIndex;

  const OnboardingPageContent({
    super.key,
    required this.data,
    required this.index,
    required this.currentIndex,
  });

  bool get _isActive => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _isActive ? 1.0 : 0.4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, _isActive ? 0 : 50, 0),
                child: Image.asset(data["image"]!, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 40),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _isActive ? 1.0 : 0.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, _isActive ? 0 : 20, 0),
              child: Text(
                data["title"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00457C),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: _isActive ? 1.0 : 0.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, _isActive ? 0 : 20, 0),
              child: Text(
                data["subtitle"]!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
