import 'package:flutter/material.dart';
import 'package:amjad/screen/login_screen.dart';

//------------------ 2. Phone Number Screen ------------------//
class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPhoneValid = false;
  bool isEmailValid = false;
  bool isPasswordValid = false;
  bool isPasswordVisible = false;

  // Phone validation
  void _checkPhone(String value) {
    setState(() {
      isPhoneValid = value.trim().length >= 13; // مثال بسيط للتحقق من الهاتف
    });
  }

  // Email validation
  void _checkEmail(String value) {
    setState(() {
      final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      isEmailValid = emailReg.hasMatch(value.trim());
    });
  }

  // Password validation
  void _checkPassword(String value) {
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

    setState(() {
      isPasswordValid =
          value.length >= 8 && hasUpper && hasLower && hasDigit && hasSpecial;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFB68645);
    const Color buttonColor = Color(0xFFB68645);

    bool allValid = isPhoneValid && isEmailValid && isPasswordValid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Your Details",
              style: TextStyle(
                fontSize: 20,
                color: borderColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              onChanged: _checkPhone,
              decoration: InputDecoration(
                hintText: "Phone e.g. +9627XXXXXXXX",
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: _checkEmail,
              decoration: InputDecoration(
                hintText: "Email",
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              onChanged: _checkPassword,
              decoration: InputDecoration(
                hintText: "Password",
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: borderColor,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Password rules
            const Text(
              "Password must include:\n"
              "- At least 8 characters\n"
              "- Uppercase letter (A-Z)\n"
              "- Lowercase letter (a-z)\n"
              "- Number (0-9)\n"
              "- Special character (!@#\$%^&*)",
              style: TextStyle(color: borderColor, fontSize: 12),
            ),
            const SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: allValid
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ActivityHomeScreen(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allValid ? buttonColor : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Divider with OR
            Row(
              children: const [
                Expanded(child: Divider(color: Colors.grey)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("or"),
                ),
                Expanded(child: Divider(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 24),

            // Social Buttons
            _buildSocialButton("Continue With Email"),
            const SizedBox(height: 12),
            _buildSocialButton("Continue With Google"),
            const SizedBox(height: 12),
            _buildSocialButton("Continue With Apple"),
            const SizedBox(height: 12),
            _buildSocialButton(
              "Continue With Facebook",
              icon: Icons.facebook,
              isFacebook: true,
            ),
            const SizedBox(height: 24),

            // Don’t have an account? + Sign Up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don’t have an account?",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Builder(
                  builder: (context) {
                    return TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sign Up clicked")),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String text, {
    IconData? icon,
    bool isFacebook = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          // هون بتحط اللوجيك الخاص بكل زر
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        icon: icon != null
            ? Icon(icon, color: isFacebook ? Colors.blue : Colors.black)
            : const SizedBox.shrink(),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}

//------------------ 3. SignUp Screen ------------------//

// الصفحة الرابعة التي ستستقبل الأسماء

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  // رسائل الخطأ
  String? firstNameError;
  String? lastNameError;
  String? phoneError;
  String? emailError;
  String? passError;

  bool _obscurePassword = true;

  // ===== شروط التحقق =====
  bool get isFirstValid => firstNameController.text.trim().isNotEmpty;
  bool get isLastValid => lastNameController.text.trim().isNotEmpty;

  bool get isPhoneValid {
    final phone = phoneController.text.trim();
    return phone.isNotEmpty && phone.startsWith("+962") && phone.length > 4;
  }

  bool get isEmailValid {
    final email = emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool get isPassValid {
    final pass = passController.text;
    final lengthOK = pass.length >= 8;
    final numberOK = RegExp(r'\d').hasMatch(pass);
    final upperOK = RegExp(r'[A-Z]').hasMatch(pass);
    final lowerOK = RegExp(r'[a-z]').hasMatch(pass);
    final specialOK = RegExp(r'[!@#\$&*~]').hasMatch(pass);
    return lengthOK && numberOK && upperOK && lowerOK && specialOK;
  }

  // ===== Validation functions =====
  void validateFirst() {
    setState(() => firstNameError = isFirstValid ? null : 'Required');
  }

  void validateLast() {
    setState(() => lastNameError = isLastValid ? null : 'Required');
  }

  void validatePhone() {
    setState(
      () => phoneError = isPhoneValid ? null : 'Not valid Jordanian number',
    );
  }

  void validateEmail() {
    setState(() => emailError = isEmailValid ? null : 'Not valid email');
  }

  void validatePass() {
    setState(() => passError = isPassValid ? null : 'Password not valid');
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allValid =
        isFirstValid &&
        isLastValid &&
        isPhoneValid &&
        isEmailValid &&
        isPassValid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create Account',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please fill in the information below",
              style: TextStyle(fontSize: 16, color: Color(0xFFB68645)),
            ),
            const SizedBox(height: 24),

            // First Name
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "First Name",
                border: const OutlineInputBorder(),
                errorText: firstNameError,
              ),
              onChanged: (_) => validateFirst(),
            ),
            const SizedBox(height: 16),

            // Last Name
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name",
                border: const OutlineInputBorder(),
                errorText: lastNameError,
              ),
              onChanged: (_) => validateLast(),
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                border: const OutlineInputBorder(),
                errorText: phoneError,
              ),
              onChanged: (_) => validatePhone(),
            ),
            const SizedBox(height: 12),

            // ملاحظة تظهر فقط إذا الرقم مش صحيح
            if (!isPhoneValid && phoneController.text.isNotEmpty)
              const Text(
                "Phone number must start with +962",
                style: TextStyle(fontSize: 13, color: Color(0xFFB68645)),
              ),
            const SizedBox(height: 16),

            // Email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: const OutlineInputBorder(),
                errorText: emailError,
              ),
              onChanged: (_) => validateEmail(),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: passController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                errorText: passError,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              onChanged: (_) => validatePass(),
            ),

            const SizedBox(height: 12),
            const Text(
              "Password must contain:\n"
              "• At least 8 characters\n"
              "• One uppercase letter\n"
              "• One lowercase letter\n"
              "• One number\n"
              "• One special character (!@#\$&*~)",
              style: TextStyle(fontSize: 13, color: Color(0xFFB68645)),
            ),

            const SizedBox(height: 32),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: allValid ? Color(0xFFB68645) : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: allValid
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActivityHomeScreen(
                              firstName: firstNameController.text.trim(),
                              lastName: lastNameController.text.trim(),
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  "Sign UP",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// dummy ActivityHomeScreen

//-----------active home screen-----//

class ActivityHomeScreen extends StatefulWidget {
  final String firstName;
  final String lastName;

  const ActivityHomeScreen({Key? key, this.firstName = '', this.lastName = ''})
    : super(key: key);

  @override
  State<ActivityHomeScreen> createState() => _ActivityHomeScreenState();
}

class _ActivityHomeScreenState extends State<ActivityHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<Map<String, String>> activities = [
    {"title": "House cleaning", "image": "images/houseCleaning.png"},
    {"title": "Handyman", "image": "https://via.placeholder.com/80"},
    {"title": "Home nursing", "image": "https://via.placeholder.com/80"},
    {"title": "Local moving", "image": "https://via.placeholder.com/80"},
    {"title": "Junk removal", "image": "https://via.placeholder.com/80"},
    {"title": "Furniture assembly", "image": "https://via.placeholder.com/80"},
  ];

  List<Map<String, String>> filteredActivities = [];
  int _selectedIndex = 2; // Service بالمنتصف

  @override
  void initState() {
    super.initState();
    filteredActivities = activities;
    _searchController.addListener(_filterActivities);
  }

  void _filterActivities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredActivities = activities
          .where((activity) => activity["title"]!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB68645),
        elevation: 0,
        title: const Text(
          "Services",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${widget.firstName} ${widget.lastName}",
              style: const TextStyle(fontSize: 18, color: Color(0xFFB68645)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: "What's on Your to-do List",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Based On Your Activity",
              style: TextStyle(fontSize: 16, color: Color(0xFFB68645)),
            ),
            const SizedBox(height: 12),
            filteredActivities.isEmpty
                ? const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.orange,
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "The service is not exist",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: filteredActivities.length,
                    itemBuilder: (context, index) {
                      final activity = filteredActivities[index];
                      return InkWell(
                        onTap: () {
                          if (activity["title"] == "House cleaning") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HouseCleaningProsPage(),
                              ),
                            );
                          }
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  activity["image"]!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity["title"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 3) {
            // Messages
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatScreen(
                  clientName: "Client",
                  providerName: "Service Provider",
                ),
              ),
            );
          } else if (index == 4) {
            // Profile
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  firstName: widget.firstName,
                  lastName: widget.lastName,
                  email: "user@example.com", // إذا عندك البريد، استبدله هنا
                  phone: "+9627XXXXXXX", // إذا عندك رقم الهاتف، استبدله هنا
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Color(0xFFB68645)),
            label: "Notification",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Color(0xFFB68645)),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service, color: Color(0xFFB68645)),
            label: "Service",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, color: Color(0xFFB68645)),
            label: "Inbox",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Color(0xFFB68645)),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

//------- اذا كبس على hose cleaning من جوا ---//

class HouseCleaningProsPage extends StatelessWidget {
  const HouseCleaningProsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // بيانات مؤقتة
    final cleaners = [
      {
        "name": "Tarek A. Shaker",
        "rating": 5.0,
        "reviews": 6,
        "desc":
            "“Tarek was amazing. House looked spotless and smell so refreshing. Totally worth the price.”",
        "image": "assets/cleaner1.jpg",
      },
      {
        "name": "Amjad Abo Shawar",
        "rating": 4.2,
        "reviews": 12,
        "desc":
            "“Mohamad is thorough and great with organizing. Would definitely hire again!”",
        "image": "assets/cleaner2.jpg",
      },
      {
        "name": "Sami G. Garann",
        "rating": 4.9,
        "reviews": 35,
        "desc":
            "“Sami is fast, reliable, and friendly. Left my place shining!”",
        "image": "assets/cleaner3.jpg",
      },
      {
        "name": "Nour A. Falah",
        "rating": 4.7,
        "reviews": 18,
        "desc": "“Nour pays attention to every detail. Highly recommended.”",
        "image": "assets/cleaner4.jpg",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.search, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "House Cleaning . Zarqa",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.bookmark_border, color: Colors.black54),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cleaners.length,
        itemBuilder: (context, index) {
          final c = cleaners[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      c["image"]! as String,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c["name"]! as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              "Exceptional ${c["rating"]}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.star, color: Colors.green, size: 16),
                            Text(
                              " (${c["reviews"]})",
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c["desc"]! as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            if (c["name"] == "Tarek A. Shaker") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CleanerDetailsPage(
                                    name: c["name"] as String,
                                    image: c["image"] as String,
                                  ),
                                ),
                              );
                            }
                            // هنا ممكن تفتح صفحة تفاصيل العامل
                          },
                          child: const Text(
                            "Read more",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
//-------في حال كبس على read more ------//

class CleanerDetailsPage extends StatelessWidget {
  final String name;
  final String image;

  const CleanerDetailsPage({Key? key, required this.name, required this.image})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(name),
        backgroundColor: const Color(0xFFB68645),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 35, backgroundImage: AssetImage(image)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tarek A. Shaker",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "🟢 Online Now · Responds within a day",
                        style: TextStyle(fontSize: 13, color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Text(
                            "JOD 70 ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Starting Price",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Your project box
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Project",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "House Cleaning · Zarqa 13110",
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB68645),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Check Availability"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// About This Pro
            const Text(
              "About This Pro",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "I do the best work for a decent price. I have a heart for helping people.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            /// Overview
            const Text(
              "Overview",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Hired 10 times\nServes Zarqa\nBackground checked",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            /// Business hours
            const Text(
              "Business hours",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "This pro hasn’t listed their business hours.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            /// Payment methods
            const Text(
              "Payment methods",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "This pro accepts payments via Cash, Zain Cash, and Bank transfer.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            /// Reviews
            const Text(
              "Reviews",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text(
                "Salma K. Malek",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "April 25 - 2025",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Since my project is still in progress, Tarek has been able to find a cleaner and send a cleaning lady home.",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Details: 1 bedroom - 2 bathrooms - 1 living room - Window cleaning - House Cleaning",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                ),
                child: const Text("See More Reviews"),
              ),
            ),

            const SizedBox(height: 20),

            /// Bottom price box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "JOD 70",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Starting Price",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB68645),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Check Availability"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//------------ chat screen-------//
class ChatScreen extends StatefulWidget {
  final String clientName;
  final String providerName;

  const ChatScreen({
    Key? key,
    required this.clientName,
    required this.providerName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // الرسائل محلية
  List<Map<String, String>> messages = [];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // إضافة رسالة العميل
    setState(() {
      messages.add({
        "sender": "client",
        "message": text,
        "time": TimeOfDay.now().format(context),
      });
    });

    _messageController.clear();

    // Scroll تلقائي لآخر رسالة
    _scrollToBottom();

    // محاكاة رد من الـ Provider بعد ثواني
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.add({
          "sender": "provider",
          "message": "Reply from ${widget.providerName}",
          "time": TimeOfDay.now().format(context),
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.providerName),
        backgroundColor: const Color(0xFFB68645),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isClient = msg["sender"] == "client";
                return Align(
                  alignment: isClient
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB68645),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isClient ? 12 : 0),
                        topRight: Radius.circular(isClient ? 0 : 12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg["message"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg["time"]!,
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: InputBorder.none,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFB68645)),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//---------- profile screen ----------//

class ProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const ProfileScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String firstName;
  late String lastName;
  late String email;
  late String phone;

  @override
  void initState() {
    super.initState();
    firstName = widget.firstName;
    lastName = widget.lastName;
    email = widget.email;
    phone = widget.phone;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFB68645);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // صورة الملف الشخصي
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: primaryColor,
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // الاسم الكامل
            Text(
              "$firstName $lastName",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB68645),
              ),
            ),
            const SizedBox(height: 8),

            // البريد الإلكتروني
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 4),

            // رقم الهاتف
            Text(
              phone,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 12),

            // إعدادات الحساب
            _buildSettingTile(
              Icons.edit,
              "Edit Profile",
              primaryColor,
              () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      firstName: firstName,
                      lastName: lastName,
                      email: email,
                      phone: phone,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    firstName = result['firstName'];
                    lastName = result['lastName'];
                    email = result['email'];
                    phone = result['phone'];
                  });
                }
              },
            ),
            _buildSettingTile(Icons.lock, "Change Password", primaryColor, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            }),
            _buildSettingTile(
              Icons.notifications,
              "Notifications",
              primaryColor,
              () {},
            ),
            _buildSettingTile(
              Icons.help_outline,
              "Help & Support",
              primaryColor,
              () {},
            ),
            _buildSettingTile(Icons.logout, "Logout", primaryColor, () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false, // يمسح كل الصفحات السابقة
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: title == "Logout" ? Colors.red : Colors.black87,
            fontWeight: title == "Logout" ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: title == "Logout"
            ? null
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ====================== Edit Profile Screen ======================
class EditProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const EditProfileScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.firstName);
    lastNameController = TextEditingController(text: widget.lastName);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFB68645);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "First Name",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: "Phone",
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                  });
                },
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== Change Password Screen ======================
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  String? errorMessage;

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  bool get isPasswordValid {
    final pass = newController.text;
    final lengthOK = pass.length >= 8;
    final numberOK = RegExp(r'\d').hasMatch(pass);
    final upperOK = RegExp(r'[A-Z]').hasMatch(pass);
    final lowerOK = RegExp(r'[a-z]').hasMatch(pass);
    final specialOK = RegExp(r'[!@#\$&*~]').hasMatch(pass);
    return lengthOK && numberOK && upperOK && lowerOK && specialOK;
  }

  // ✅ دالة للتحقق من التطابق
  bool get isConfirmMatching =>
      confirmController.text.isNotEmpty &&
      newController.text.isNotEmpty &&
      confirmController.text == newController.text;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFB68645);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: currentController,
              obscureText: _obscureCurrent,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: "New Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              onChanged: (_) =>
                  setState(() {}), // إعادة بناء الواجهة للتحديث الفوري
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              onChanged: (_) =>
                  setState(() {}), // ✅ تحديث الرسالة أثناء الكتابة
            ),

            // ✅ الرسالة تحت confirm password
            const SizedBox(height: 6),
            if (confirmController.text.isNotEmpty)
              Text(
                isConfirmMatching
                    ? "Passwords match ✔"
                    : "Passwords do not match ✖",
                style: TextStyle(
                  color: isConfirmMatching ? Colors.green : Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 12),
            if (!isPasswordValid && newController.text.isNotEmpty)
              const Text(
                "Password must be at least 8 chars, include uppercase, lowercase, number & special char",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (!isConfirmMatching) {
                    setState(() {
                      errorMessage = "Confirm password does not match";
                    });
                  } else if (!isPasswordValid) {
                    setState(() {
                      errorMessage = "New password does not meet requirements";
                    });
                  } else {
                    setState(() {
                      errorMessage = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Password changed successfully (Front-end only)",
                        ),
                        backgroundColor: Color(0xFFB68645),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
