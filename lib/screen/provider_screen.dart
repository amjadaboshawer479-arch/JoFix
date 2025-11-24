import 'package:amjad/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:amjad/screen/login_screen.dart'; // Assuming this imports ServiceProviderHome now
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


//----------a login service provider----------//
class ServiseProviderLogin extends StatefulWidget {
  const ServiseProviderLogin({super.key});
  @override
  State<ServiseProviderLogin> createState() => _ServiseProviderLoginState();
}

class _ServiseProviderLoginState extends State<ServiseProviderLogin> {
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPhoneValid = false;
  bool isEmailValid = false;
  bool isPasswordValid = false;
  bool isPasswordVisible = false;

  // --- Validators --- (Backend logic remains untouched)
  String? _validatePhone(String value) {
    if (value.isEmpty) return "Phone number is required";
    if (!value.startsWith("+962")) return "Must start with +962";
    if (value.length < 13) return "Phone number too short";
    return null;
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return "Email is required";
    final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailReg.hasMatch(value.trim())) return "Invalid email";
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    final hasUpper = value.contains(RegExp(r'[A-Z]'));
    final hasLower = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'[0-9]'));
    final hasSpecial = value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    if (value.length < 8) return "At least 8 characters";
    if (!hasUpper) return "Must contain an uppercase letter";
    if (!hasLower) return "Must contain a lowercase letter";
    if (!hasDigit) return "Must contain a number";
    if (!hasSpecial) return "Must contain a special character";
    return null;
  }

  void _checkAllValid() {
    setState(() {
      isPhoneValid = _validatePhone(phoneController.text) == null;
      isEmailValid = _validateEmail(emailController.text) == null;
      isPasswordValid = _validatePassword(passwordController.text) == null;
    });
  }

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_checkAllValid);
    emailController.addListener(_checkAllValid);
    passwordController.addListener(_checkAllValid);
  }

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  // --- END Validators ---

  // --- Reset Password Logic (Backend logic remains untouched) ---
  Future<void> _resetPassword() async {
    final emailResetController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: emailResetController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Enter your email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailResetController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter your email")),
                  );
                  return;
                }

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password reset link sent!")),
                  );
                } on FirebaseAuthException catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message ?? "Error sending reset link"),
                    ),
                  );
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }
  // --- END Reset Password Logic ---

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00457C);
    bool allValid = isPhoneValid && isEmailValid && isPasswordValid;

    // 🎨 Modern Input Decoration
    InputDecoration customInput(String hint, IconData icon) {
      return InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 1.0),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        filled: true,
        fillColor: primaryColor.withOpacity(0.05),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar( // 🚀 تم تفعيل الـ AppBar
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryColor), // 👈 زر الرجوع
          onPressed: () {
            Navigator.pop(context); // للرجوع للشاشة السابقة (ClientHomePage)
          },
        ),
        title: const Text(
          'Service Provider Login',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Logo Placeholder (Replace with your actual image)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 20, bottom: 40),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child:
                const Icon(Icons.person_pin, size: 50, color: primaryColor),
              ),
            ),
            // 🖋️ Title
            const Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 30,
                color: primaryColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              "Sign in to your Service Provider account.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),

            // ===== Phone =====
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: customInput("Phone e.g. +9627XXXXXXXX", Icons.phone),
            ),
            const SizedBox(height: 16),
            // ===== Email =====
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: customInput("Email", Icons.email),
            ),
            const SizedBox(height: 16),
            // ===== Password =====
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: customInput("Password", Icons.lock).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 50),

            // ===== Login Button =====
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // Backend logic remains untouched
                onPressed: allValid
                    ? () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                    const Center(child: CircularProgressIndicator(color: primaryColor)),
                  );

                  try {
                    final auth = FirebaseAuth.instance;
                    final cred = await auth.signInWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    );

                    final uid = cred.user?.uid;
                    if (uid == null)
                      throw Exception("User ID not found");

                    final firestore = FirebaseFirestore.instance;
                    final doc = await firestore
                        .collection('service_providers')
                        .doc(uid)
                        .get();

                    Navigator.pop(context); // close loading

                    if (!doc.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Profile not found.")),
                      );
                      return;
                    }

                    final data = doc.data()!;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceProviderHome1(
                          firstName: data['firstName'] ?? '',
                          lastName: data['lastName'] ?? '',
                          email: data['email'] ?? '',
                          phone: data['phone'] ?? '',
                        ),
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text(e.message ?? "Login failed")),
                    );
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allValid ? primaryColor : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5, // Subtle shadow
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== Forgot Password =====
            Center(
              child: TextButton(
                onPressed: _resetPassword, // Backend logic remains untouched
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ===== Sign Up =====
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {
                      // ⚠️ يجب استبدال SignupScreen بالشاشة الصحيحة إذا كانت موجودة في ملف آخر.
                      // تم استبدال الكود التالي بـ Navigator.push المؤقت ليتوافق مع السياق.
                      // يجب عليك التأكد من وجود `SignupScreen` في مكان يمكن الوصول إليه.
                      // مثال:
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const SignupScreen(),
                      //   ),
                      // );
                      // بما أن الكود الخاص بـ `SignupScreen` غير مُدرج هنا، نفترض أنه تم استيراده.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

//----------signe up secreen---------//
class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // --- Controllers (Backend logic remains untouched) ---
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController mapLinkController = TextEditingController();

  String? firstNameError;
  String? lastNameError;
  String? phoneError;
  String? emailError;
  String? passError;
  String? mapLinkError;

  bool _obscurePassword = true;

  // --- Getters and Validators (Backend logic remains untouched) ---
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

  bool get isMapLinkValid => _isValidMapLink(mapLinkController.text.trim());

  void validateFirst() =>
      setState(() => firstNameError = isFirstValid ? null : 'Required');

  void validateLast() =>
      setState(() => lastNameError = isLastValid ? null : 'Required');

  void validatePhone() => setState(
        () => phoneError = isPhoneValid ? null : 'Not valid Jordanian number',
  );

  void validateEmail() =>
      setState(() => emailError = isEmailValid ? null : 'Not valid email');

  void validatePass() =>
      setState(() => passError = isPassValid ? null : 'Password not valid');

  void validateMapLink() => setState(
        () => mapLinkError = isMapLinkValid ? null : 'Invalid Google Maps link',
  );

  bool _isValidMapLink(String link) {
    if (link.isEmpty) return false;
    Uri? uri = Uri.tryParse(link);
    if (uri == null || !uri.hasAbsolutePath) return false;

    final host = uri.host.toLowerCase();

    final isGoogleMaps = host.contains('google.com') ||
        host.contains('maps.app.goo.gl') ||
        host.contains('goo.gl') ||
        host.contains('google.co');

    return isGoogleMaps;
  }
  // --- END Getters and Validators ---

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passController.dispose();
    mapLinkController.dispose();
    super.dispose();
  }

  // 🎨 Modern Input Decoration Function for Signup
  InputDecoration _buildInputDecoration(String labelText, String? errorText,
      {Widget? suffixIcon}) {
    const Color primaryColor = Color(0xFF00457C);
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: primaryColor),
      floatingLabelStyle:
      const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      errorText: errorText,
      suffixIcon: suffixIcon,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      filled: true,
      fillColor: primaryColor.withOpacity(0.03),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00457C);
    bool allValid =
        isFirstValid &&
            isLastValid &&
            isPhoneValid &&
            isEmailValid &&
            isPassValid &&
            isMapLinkValid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please fill in the information below to register as a Service Provider.",
              style: TextStyle(fontSize: 16, color: primaryColor),
            ),
            const SizedBox(height: 24),

            // First Name
            TextField(
              controller: firstNameController,
              decoration: _buildInputDecoration("First Name", firstNameError),
              onChanged: (_) => validateFirst(),
            ),
            const SizedBox(height: 16),

            // Last Name
            TextField(
              controller: lastNameController,
              decoration: _buildInputDecoration("Last Name", lastNameError),
              onChanged: (_) => validateLast(),
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration("Phone Number", phoneError),
              onChanged: (_) => validatePhone(),
            ),
            const SizedBox(height: 12),
            // Phone validation helper
            if (!isPhoneValid && phoneController.text.isNotEmpty)
              const Text(
                "Phone number must start with +962 (e.g., +96277xxxxxxxxx)",
                style: TextStyle(fontSize: 13, color: primaryColor),
              ),
            const SizedBox(height: 16),

            // Email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _buildInputDecoration("Email", emailError),
              onChanged: (_) => validateEmail(),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: passController,
              obscureText: _obscurePassword,
              decoration: _buildInputDecoration(
                "Password",
                passError,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: primaryColor,
                  ),
                ),
              ),
              onChanged: (_) => validatePass(),
            ),
            const SizedBox(height: 12),

            // Password requirements
            const Text(
              "Password must contain:",
              style: TextStyle(
                fontSize: 13,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("- At least 8 characters",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  Text("- Uppercase (A-Z)",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  Text("- Lowercase (a-z)",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  Text("- Number (0-9)",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  Text("- Special character (!@#\$%^&*)",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Map Link
            TextField(
              controller: mapLinkController,
              keyboardType: TextInputType.url,
              decoration: _buildInputDecoration(
                "Google Maps Link",
                mapLinkError,
              ).copyWith(
                hintText: "Paste your Google Maps location link here",
                prefixIcon:
                const Icon(Icons.map_outlined, color: primaryColor),
              ),
              onChanged: (_) => validateMapLink(),
            ),
            const SizedBox(height: 12),
            // Map Link validation helper
            if (!isMapLinkValid && mapLinkController.text.isNotEmpty)
              const Text(
                "Please enter a valid Google Maps link.",
                style: TextStyle(fontSize: 13, color: primaryColor),
              ),

            const SizedBox(height: 32),

            // Sign Up Button (Backend logic remains untouched)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: allValid ? primaryColor : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                onPressed: allValid
                    ? () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                    const Center(child: CircularProgressIndicator(color: primaryColor)),
                  );

                  try {
                    final auth = FirebaseAuth.instance;
                    final cred =
                    await auth.createUserWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passController.text,
                    );

                    final user = cred.user;
                    if (user == null)
                      throw Exception("User creation failed");

                    // 🔹 إرسال رابط التحقق (Send verification link)
                    await user.reload();
                    await Future.delayed(
                      const Duration(seconds: 1),
                    );
                    await user.sendEmailVerification();

                    Navigator.pop(context); // إغلاق الـ loader

                    // 🔹 عرض Dialog للتحقق من البريد (Show email verification dialog)
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Text("Verify Your Email"),
                        content: const Text(
                          "A verification link has been sent to your email. "
                              "Please verify it, then click Continue.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await user.reload(); // تحديث حالة المستخدم
                              if (auth.currentUser!.emailVerified) {
                                // ✅ بعد التحقق نضيف المستخدم في Firestore
                                final firestore =
                                    FirebaseFirestore.instance;
                                await firestore
                                    .collection('service_providers')
                                    .doc(user.uid)
                                    .set({
                                  'firstName':
                                  firstNameController.text.trim(),
                                  'lastName':
                                  lastNameController.text.trim(),
                                  'phone': phoneController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'mapLink':
                                  mapLinkController.text.trim(),
                                  'createdAt':
                                  FieldValue.serverTimestamp(),
                                });

                                Navigator.pop(
                                    context); // إغلاق الـ dialog
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Account verified and created!",
                                    ),
                                  ),
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServiceProviderHome1(
                                          firstName:
                                          firstNameController.text.trim(),
                                          lastName:
                                          lastNameController.text.trim(),
                                        ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please verify your email first",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text("Continue"),
                          ),
                        ],
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(e.message ?? "Error")),
                    );
                  }
                }
                    : null,
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ----------------------------- LOGIN NAV (ADDED CODE) -----------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // العودة لشاشة تسجيل الدخول السابقة (ServiseProviderLogin)
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor, // استخدام اللون الرئيسي
                    ),
                  ),
                ),
              ],
            ),
            // ----------------------------------------------------------------------------------
          ],
        ),
      ),
    );
  }
}

//----------- servises of servise provider---------//
class ServiceProviderHome1 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  const ServiceProviderHome1({
    Key? key,
    this.firstName = " ",
    this.lastName = " ",
    this.email = '',
    this.phone = '',
  }) : super(key: key);
  @override
  State<ServiceProviderHome1> createState() => _ServiceProviderHomeState();
}

class _ServiceProviderHomeState extends State<ServiceProviderHome1> {
  int _selectedIndex = 0;
  bool isLoading = true;
  List<String> myServices = [];
  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      myServices = ["Cleaning", "Painting"]; // مثال
      isLoading = false;
    });
  }

  void _onBottomTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OrdersScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceProviderProfileScreen(
            firstName: widget.firstName,
            lastName: widget.lastName,
            email: "user@example.com", // إذا عندك البريد، استبدله هنا
            phone: "+9627XXXXXXX", // إذا عندك رقم الهاتف، استبدله هنا
          ),
        ),
      );
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (myServices.isEmpty) {
      return const Center(
        child: Text(
          "لا توجد خدمات لديك",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myServices.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          leading: const Icon(Icons.build),
          title: Text(myServices[index]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF00457C);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00457C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Dashbord",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF00457C)),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.miscellaneous_services),
                    title: const Text("Manage Services"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageServicesPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_box_outlined),
                    title: const Text("Create and Manage Post"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManagePostsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.message),
                    title: const Text("inpox"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactClientPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // زر Logout ثابت في الأسفل
            Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                        (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======= رسالة الترحيب تحت الـAppBar =======
          Container(
            width: double.infinity,
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Text(
              "Welcome ${widget.firstName} ${widget.lastName} 👋",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00457C),
              ),
            ),
          ),
          // ======= محتوى التابات =======
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeContent(),
                const SizedBox(),
                const SizedBox(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomTap,
        selectedItemColor: activeColor,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: "Orders",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

//------------manage service -------//
class Service {
  String name;
  String description;
  double price;
  String duration;
  bool isAvailable;
  Service({
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.isAvailable,
  });
}

class ManageServicesPage extends StatefulWidget {
  const ManageServicesPage({Key? key}) : super(key: key);
  @override
  State<ManageServicesPage> createState() => _ManageServicesPageState();
}

class _ManageServicesPageState extends State<ManageServicesPage> {
  final Color brown = const Color(0xFF00457C);
  // قائمة الخدمات
  List<Service> services = [
    Service(
      name: "Cleaning",
      description: "Deep home cleaning with eco-friendly materials.",
      price: 50.0,
      duration: "2 hours",
      isAvailable: true,
    ),
  ];
  // ============== إضافة خدمة جديدة ==============
  void _addService() {
    _showServiceDialog();
  }

  // ============== تعديل خدمة موجودة ==============
  void _editService(int index) {
    _showServiceDialog(editIndex: index);
  }

  // ============== حذف خدمة ==============
  void _deleteService(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Service"),
        content: Text(
          "Are you sure you want to delete '${services[index].name}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => services.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ======= Dialog الإضافة/التعديل =======
  void _showServiceDialog({int? editIndex}) {
    final bool isEdit = editIndex != null;
    final service = isEdit
        ? services[editIndex]
        : Service(
      name: "",
      description: "",
      price: 0.0,
      duration: "",
      isAvailable: true,
    );
    final nameCtrl = TextEditingController(text: service.name);
    final descCtrl = TextEditingController(text: service.description);
    final priceCtrl = TextEditingController(
      text: isEdit ? service.price.toString() : "",
    );
    final durationCtrl = TextEditingController(text: service.duration);
    bool availability = service.isAvailable;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(isEdit ? "Edit Service" : "Add Service"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInput("Service Name", nameCtrl),
                const SizedBox(height: 10),
                _buildInput("Description", descCtrl, maxLines: 3),
                const SizedBox(height: 10),
                _buildInput(
                  "Price (JD)",
                  priceCtrl,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _buildInput(
                  "Duration",
                  durationCtrl,
                  hint: "e.g., 2 hours, 1 day",
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text("Available"),
                  activeColor: brown,
                  value: availability,
                  onChanged: (val) => setInnerState(() => availability = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: brown),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty ||
                    descCtrl.text.trim().isEmpty ||
                    priceCtrl.text.trim().isEmpty) {
                  return;
                }
                final newService = Service(
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text.trim()) ?? 0.0,
                  duration: durationCtrl.text.trim(),
                  isAvailable: availability,
                );
                setState(() {
                  if (isEdit) {
                    services[editIndex] = newService;
                  } else {
                    services.add(newService);
                  }
                });
                Navigator.pop(context);
              },
              child: Text(isEdit ? "Save" : "Add"),
            ),
          ],
        ),
      ),
    );
  }

  // حقل إدخال مع ستايل
  Widget _buildInput(
      String label,
      TextEditingController controller, {
        String? hint,
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: brown),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: brown,
        centerTitle: true,
        title: const Text(
          "Manage Services",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: services.isEmpty
            ? const Center(
          child: Text(
            "No services added yet.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        )
            : ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, i) {
            final s = services[i];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: ListTile(
                leading: Icon(
                  Icons.build,
                  color: s.isAvailable ? brown : Colors.grey,
                ),
                title: Text(
                  s.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "${s.description}\nPrice: ${s.price} JD | Duration: ${s.duration}\nStatus: ${s.isAvailable ? "Available" : "Not Available"}",
                  style: const TextStyle(height: 1.4),
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () => _editService(i),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteService(i),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: brown,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Service", style: TextStyle(color: Colors.white)),
        onPressed: _addService,
      ),
    );
  }
}

//--------create &manage post--------//
class ManagePostsPage extends StatefulWidget {
  const ManagePostsPage({super.key});
  @override
  State<ManagePostsPage> createState() => _ManagePostsPageState();
}

class _ManagePostsPageState extends State<ManagePostsPage> {
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> archivedPosts = [];
  // controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String? selectedService;
  bool isActive = true;
  int? editingIndex;
  final List<String> myServices = ["Cleaning", "Painting"]; // مثال
  void _savePost() {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }
    final post = {
      'title': titleController.text,
      'description': descriptionController.text,
      'service': selectedService,
      'price': priceController.text,
      'active': isActive,
      'date': DateTime.now().toString(),
    };
    setState(() {
      if (editingIndex != null) {
        posts[editingIndex!] = post;
        editingIndex = null;
      } else {
        posts.add(post);
      }
    });
    _clearForm();
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    selectedService = null;
    isActive = true;
  }

  void _editPost(int index) {
    final post = posts[index];
    setState(() {
      titleController.text = post['title'];
      descriptionController.text = post['description'];
      priceController.text = post['price'];
      selectedService = post['service'];
      isActive = post['active'];
      editingIndex = index;
    });
  }

  void _deleteOrArchivePost(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete"),
              onTap: () {
                setState(() {
                  posts.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.blue),
              title: const Text("Archive"),
              onTap: () {
                setState(() {
                  archivedPosts.add(posts[index]);
                  posts.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Cancel"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showArchivedPosts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Archived Posts"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: archivedPosts.length,
            itemBuilder: (context, index) {
              final post = archivedPosts[index];
              return ListTile(
                title: Text(post['title']),
                subtitle: Text("${post['service']} - \$${post['price']}"),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00457C);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Manage Posts",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.archive, color: Colors.white),
            onPressed: _showArchivedPosts,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Form
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description *",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedService,
              items: myServices
                  .map(
                    (service) =>
                    DropdownMenuItem(value: service, child: Text(service)),
              )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedService = val;
                });
              },
              decoration: const InputDecoration(
                labelText: "Related Service *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Active: "),
                Switch(
                  value: isActive,
                  onChanged: (val) {
                    setState(() {
                      isActive = val;
                    });
                  },
                  activeColor: primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _savePost,
                child: Text(
                  editingIndex != null ? "Update Post" : "Add Post",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            // Posts List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(post['title']),
                    subtitle: Text("${post['service']} - \$${post['price']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editPost(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteOrArchivePost(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//-----------contact with client------//

class ContactClientPage extends StatefulWidget {
  const ContactClientPage({super.key});

  @override
  State<ContactClientPage> createState() => _ContactClientPageState();
}

class _ContactClientPageState extends State<ContactClientPage> {
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00457C);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Clients",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clients').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No clients found."));
          }

          final clients = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final data = clients[index].data() as Map<String, dynamic>;
              final clientId = clients[index].id;
              final firstName = data['firstName'] ?? '';
              final lastName = data['lastName'] ?? '';
              final fullName = '$firstName $lastName';

              return Card(
                child: ListTile(
                  title: Text(fullName),
                  subtitle: Text(data['email'] ?? ''),
                  trailing: const Icon(Icons.chat, color: primaryColor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProviderChatScreen(
                          clientId: clientId,
                          clientName: fullName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------- Chat Screen ---------- //
class ProviderChatScreen extends StatefulWidget {
  final String clientId;
  final String clientName;

  const ProviderChatScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<ProviderChatScreen> createState() => _ProviderChatScreenState();
}

class _ProviderChatScreenState extends State<ProviderChatScreen> {
  final TextEditingController msgController = TextEditingController();
  late String providerId;
  late String chatId;

  @override
  void initState() {
    super.initState();
    providerId = FirebaseAuth.instance.currentUser!.uid;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("⚠️ Provider not logged in!");
      return;
    }
    providerId = user.uid;
    // chatId ثابت لكل محادثة بين نفس الكلينت والبروفايدر
    chatId = providerId.compareTo(widget.clientId) < 0
        ? "${providerId}_${widget.clientId}"
        : "${widget.clientId}_${providerId}";

    // ✅ عند فتح الشات، نعمل تحديث للرسائل غير المقروءة
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    final unreadMessages = await messagesRef
        .where('receiverId', isEqualTo: providerId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      doc.reference.update({'isRead': true});
    }
  }

  Future<void> _sendMessage() async {
    final text = msgController.text.trim();
    if (text.isEmpty) return;

    final msgData = {
      'senderId': providerId,
      'receiverId': widget.clientId,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    // مرجع الدردشة
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);

    // إنشاء أو تحديث الدردشة الأساسية
    await chatRef.set({
      'participants': [providerId, widget.clientId],
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // إضافة الرسالة للمحادثة
    await chatRef.collection('messages').add(msgData);

    msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00457C);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.clientName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          // ✅ عرض الرسائل
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                // ✅ فحص الأخطاء أولاً
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                // ✅ فحص حالة التحميل
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // ✅ فحص إذا ما في رسائل بعد
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isProvider = msg['senderId'] == providerId;
                    final time = msg['timestamp'] != null
                        ? (msg['timestamp'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .toString()
                        .substring(11, 16)
                        : '';

                    return Align(
                      alignment: isProvider
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isProvider
                              ? primaryColor.withOpacity(0.8)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['message'] ?? '',
                              style: TextStyle(
                                color: isProvider ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                color: isProvider
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ✅ مربع إرسال الرسائل
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: primaryColor,
                  child: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//----------order navigation bar-----//
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final Color brown = const Color(0xFF00457C);
  List<Map<String, dynamic>> orders = [
    {
      "id": 1,
      "service": "Cleaning",
      "status": "Pending",
      "date": DateTime.now(),
    },
    {
      "id": 2,
      "service": "Painting",
      "status": "Pending",
      "date": DateTime.now(),
    },
  ];
  void updateOrder(int index, String newStatus) {
    setState(() {
      orders[index]["status"] = newStatus;
      orders[index]["date"] = DateTime.now(); // تحديث التاريخ
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green;
      case "Completed":
        return Colors.blue;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case "Accepted":
        return Icons.check_circle;
      case "Completed":
        return Icons.done_all;
      case "Rejected":
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders", style: TextStyle(color: Colors.white)),
        backgroundColor: brown,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: brown, width: 1),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #${order['id']}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: brown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Service: ${order['service']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        getStatusIcon(order["status"]),
                        color: brown, // أيقونة بلون JoFix
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        order["status"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(order["status"]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Date: ${order['date'].day}/${order['date'].month}/${order['date'].year}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brown,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => updateOrder(index, "Accepted"),
                        child: const Text("Accept"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brown,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => updateOrder(index, "Rejected"),
                        child: const Text("Reject"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brown,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => updateOrder(index, "Completed"),
                        child: const Text("Complete"),
                      ),
                    ],
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

//--------- srevice provider profile------//
class ServiceProviderProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  const ServiceProviderProfileScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  }) : super(key: key);
  @override
  State<ServiceProviderProfileScreen> createState() =>
      _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState
    extends State<ServiceProviderProfileScreen> {
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
    const primaryColor = Color(0xFF00457C);
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
                color: Color(0xFF00457C),
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
                    builder: (context) => EditServiceProviderProfileScreen(
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
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ====================== Edit Profile ======================
class EditServiceProviderProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  const EditServiceProviderProfileScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  }) : super(key: key);
  @override
  State<EditServiceProviderProfileScreen> createState() =>
      _EditServiceProviderProfileScreenState();
}

class _EditServiceProviderProfileScreenState
    extends State<EditServiceProviderProfileScreen> {
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
    const primaryColor = Color(0xFF00457C);
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
    const primaryColor = Color(0xFF00457C);
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
                        backgroundColor: Color(0xFF00457C),
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
