// ✅ تم تعديل هذا الملف فقط — لربطه بصفحات الدفع الجديدة في lib/screen/payment/

import 'package:amjad/screen/payment/payment_method_selection.dart';
import 'package:flutter/material.dart';
import 'package:amjad/screen/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

//------------------ 2. Phone Number Screen ------------------//
// ------------------- Client Home Page ------------------- //
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
  String? loginError; // 🔥 متغير لعرض الخطأ تحت الحقول
  // Phone validation
  void _checkPhone(String value) {
    setState(() {
      isPhoneValid = value.trim().length >= 13; // +9627XXXXXXXX
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
  // 🔥 تسجيل الدخول بالبريد وكلمة السر
  Future<void> _loginClient() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    setState(() {
      loginError = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      final cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid == null) throw Exception("User ID not found");
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('clients').doc(uid).get();
      if (!doc.exists) {
        setState(() {
          loginError = "User not found in Firestore.";
        });
        return;
      }
      final data = doc.data()!;
      final storedPhone = (data['phone'] ?? '') as String;
      if (storedPhone.isNotEmpty && storedPhone != phone) {
        setState(() {
          loginError = "Phone number doesn't match our records.";
        });
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ActivityHomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          loginError = "User not found in Firebase Authentication.";
        } else if (e.code == 'wrong-password') {
          loginError = "Wrong password.";
        } else {
          loginError = e.message ?? "Login failed.";
        }
      });
    } catch (e) {
      setState(() {
        loginError = e.toString();
      });
    }
  }
  // 🔥 تسجيل الدخول بالفيسبوك
  Future<void> _loginWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Facebook login failed: ${result.status}")),
        );
        return;
      }
      final accessToken = result.accessToken!;
      final credential = FacebookAuthProvider.credential(accessToken.token);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) throw Exception("User not found");
      final uid = user.uid;
      final email = user.email ?? "";
      final displayName = user.displayName ?? "";
      final phone = "";
      final docRef = FirebaseFirestore.instance.collection("clients").doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          "uid": uid,
          "email": email,
          "fullName": displayName,
          "phone": phone,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ActivityHomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
  // 🔥 تسجيل الدخول بجوجل
  Future<void> _loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) throw Exception("User not found");
      final uid = user.uid;
      final email = user.email ?? "";
      final displayName = user.displayName ?? "";
      final phone = "";
      final docRef = FirebaseFirestore.instance.collection("clients").doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          "uid": uid,
          "email": email,
          "fullName": displayName,
          "phone": phone,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ActivityHomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
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
              "Password must include:"
              "- At least 8 characters"
              "- Uppercase letter (A-Z)"
              "- Lowercase letter (a-z)"
              "- Number (0-9)"
              "- Special character (!@#\$%^&*)",
              style: TextStyle(color: borderColor, fontSize: 12),
            ),
            const SizedBox(height: 16),
            // 🔥 رسالة الخطأ في حالة المستخدم غير موجود
            if (loginError != null)
              Text(
                loginError!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            const SizedBox(height: 16),
            // Login Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: allValid ? _loginClient : null,
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
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB68645),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
            // ✅ Social Buttons (Google & Facebook only)
            _buildSocialButton("Continue With Google", isFacebook: false),
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
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // Social Button builder
  Widget _buildSocialButton(
      String text, {
        IconData? icon,
        bool isFacebook = false,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: isFacebook ? _loginWithFacebook : _loginWithGoogle,
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
//---------FORGET PASSWORD--------//
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;
  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your email.")));
      return;
    }
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset link sent! Check your email."),
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error sending reset email")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFB68645);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter your email and we'll send you a link to reset your password.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryColor),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Send Reset Link",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//------------------ 3. SignUp Screen ------------------//
// الصفحة الرابعة التي ستستقبل الأسماء
// شاشة تسجيل العميل
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
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }
  // 🔥 دالة إنشاء الحساب والتخزين في الكوليكشن clients
  Future<void> _handleSignup() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passController.text;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      // 1️⃣ إنشاء الحساب داخل Firebase Authentication
      final auth = FirebaseAuth.instance;
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.sendEmailVerification();
      final uid = cred.user?.uid;
      if (uid == null) throw Exception("User ID not found");
      // 2️⃣ إضافة بيانات المستخدم داخل كوليكشن clients
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('clients').doc(cred.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context); // إغلاق التحميل
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please check your inbox to verifay your email."),
        ),
      );
      // التنقل للشاشة الرئيسية بعد التسجيل
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyEmailScreen(user: cred.user!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      String msg = "Signup failed";
      if (e.code == 'email-already-in-use')
        msg = "This email is already in use.";
      if (e.code == 'weak-password') msg = "Password too weak.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
            // ========== TextFields ==========
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
            if (!isPhoneValid && phoneController.text.isNotEmpty)
              const Text(
                "Phone number must start with +962",
                style: TextStyle(fontSize: 13, color: Color(0xFFB68645)),
              ),
            const SizedBox(height: 16),
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
              "Password must contain:"
              "• At least 8 characters"
              "• One uppercase letter"
              "• One lowercase letter"
              "• One number"
              "• One special character (!@#\$&*~)",
              style: TextStyle(fontSize: 13, color: Color(0xFFB68645)),
            ),
            const SizedBox(height: 32),
            // ========== Sign Up Button ==========
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: allValid
                      ? const Color(0xFFB68645)
                      : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: allValid ? _handleSignup : null,
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
//verefay you email
class VerifyEmailScreen extends StatefulWidget {
  final User user;
  const VerifyEmailScreen({Key? key, required this.user}) : super(key: key);
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}
class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isVerified = false;
  bool _isLoading = false;
  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    await widget.user.reload();
    final updatedUser = FirebaseAuth.instance.currentUser;
    if (updatedUser != null && updatedUser.emailVerified) {
      setState(() => _isVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email verified successfully!")),
      );
      // ✅ الانتقال إلى الشاشة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityHomeScreen(
            firstName: "", // ممكن تمرر الاسم إذا بدك
            lastName: "",
            email: updatedUser.email ?? "",
            phone: "",
          ),
        ),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Email not verified yet.")));
    }
  }
  Future<void> _resendEmail() async {
    try {
      await widget.user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification email resent.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify your Email"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 80,
                color: Color(0xFFB68645),
              ),
              const SizedBox(height: 20),
              Text(
                "A verification email has been sent to: \n${FirebaseAuth.instance.currentUser?.email ?? ''}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Please check your inbox and click the verification link.After that, click the button below:",
              textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB68645),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("I verified my email"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _resendEmail,
                child: const Text(
                  "Resend verification email",
                  style: TextStyle(color: Color(0xFFB68645)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//-----------active home screen-----//
class ActivityHomeScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  const ActivityHomeScreen({
    Key? key,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
  }) : super(key: key);
  @override
  State<ActivityHomeScreen> createState() => _ActivityHomeScreenState();
}
class _ActivityHomeScreenState extends State<ActivityHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<Map<String, String>> activities = [
    {"title": "House cleaning", "image": "imagee/house clening.jpg"},
    {"title": "Handyman", "image": "imagee/handyman.jpg"},
    {"title": "Home nursing", "image": "imagee/nirs.jpg"},
    {"title": "Local moving", "image": "imagee/sandoq.jpg"},
    {"title": "Junk removal", "image": "imagee/adah.jpg"},
    {"title": "Furniture assembly", "image": "imagee/shakosh.jpg"},
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
                          builder: (context) => const HouseCleaningPage(),
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
                builder: (context) => const ClientChatListScreen(),
              ),
            );
          } else if (index == 4) {
            // Profile
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
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
class HouseCleaningPage extends StatefulWidget {
  const HouseCleaningPage({Key? key}) : super(key: key);
  @override
  State<HouseCleaningPage> createState() => _HouseCleaningPageState();
}
Widget buildServiceCard({
  required String image,
  required String title,
  required String price,
  required String info,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    image,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "JoFix Friendly",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible (child :ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB68645),
                    minimumSize: Size(90, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    child: Text("Search pros", style: TextStyle(color: Colors.white)),
                  ),
                ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(info, style: TextStyle(fontSize: 13, color: Colors.black87)),
            SizedBox(height: 6),
            Text(
              "Tips & info",
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
class _HouseCleaningPageState extends State<HouseCleaningPage> {
  int _selectedIndex = 2; // نحدد إنه Service هو المختار
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keep things clean", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFFB68645),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Get your space sparkling and clutter-free, then build habits to help keep it that way.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 20),
            /// Section 1
            Text(
              "Start with the basics",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB68645),
              ),
            ),
            SizedBox(height: 10),
            buildServiceCard(
              image: "assets/house_cleaning.jpg",
              title: "House Cleaning",
              price: "JOD 30 - 180 avg.",
              info:
              "Did you know? To work properly, most antibacterial sprays need to sit on a surface for 60 seconds before wiping.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HouseCleaningProsPage(),
                  ),
                );
              },
            ),
            buildServiceCard(
              image: "assets/clear_clutter.jpg",
              title: "Clear Out Clutter",
              price: "JOD 40 - 270 avg.",
              info: "",
            ),
            buildServiceCard(
              image: "assets/air_filters.jpg",
              title: "Replace Air Filters",
              price: "JOD 25 - 65 avg.",
              info: "",
            ),
            SizedBox(height: 20),
            /// Section 2
            Text(
              "Really get in there",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            buildServiceCard(
              image: "assets/deep_cleaning.jpg",
              title: "Deep Cleaning",
              price: "JOD 60 - 270 avg.",
              info:
              "Did you know? The stuff that builds up on shower doors is called limescale. You can clean it with lemon juice or vinegar.",
            ),
            buildServiceCard(
              image: "assets/pressure_washing.jpg",
              title: "Pressure Washing",
              price: "JOD 150 - 390 avg.",
              info: "",
            ),
            buildServiceCard(
              image: "assets/carpet_cleaning.jpg",
              title: "Carpet Cleaning",
              price: "JOD 40 - 150 avg.",
              info: "",
            ),
          ],
        ),
      ),
      // 👇 الـ BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // هون ممكن تعمل Navigation حسب كل أيقونة إذا بدك
          if (index == 2) {
            // already on Service page
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
            label: "Message",
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
    // جلب بيانات السيرفس بروفايدر من فايربيس
    final providersStream = FirebaseFirestore.instance
        .collection('service_providers')
        .snapshots();
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
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "House Cleaning • Zarqa",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: providersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No providers found"));
          }
          final providers = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final data = providers[index].data() as Map<String, dynamic>;
              final name =
                  "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}";
              final rating = (data['rating'] is int)
                  ? (data['rating'] as int).toDouble()
                  : (data['rating'] ?? 4.5);
              final reviews = data['reviews'] ?? 10;
              final desc =
                  data['description'] ??
                      "Professional service provider with high experience.";
              final imageUrl =
                  data['imageUrl'] ??
                      "https://via.placeholder.com/150"; // صورة افتراضية لو مش موجودة
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
                        child: Image.network(
                          imageUrl,
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
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  "Exceptional $rating",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.star,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                Text(
                                  " ($reviews)",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: () {
                                // لما الكلاينت يضغط "Read more"
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CleanerDetailsPage(
                                      name: name,
                                      image: imageUrl,
                                      locationLink: data['mapLink'] ?? '',
                                      providerId: providers[index].id,
                                      serviceName: "House Cleaning",
                                      price: 70.0, // يمكنك جعله ديناميكي من الـ Firestore
                                    ),
                                  ),
                                );
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
  final String locationLink; // الرابط من Firebase
  final String providerId;   // ✅ جديد
  final String serviceName; // ✅ جديد
  final double price;       // ✅ جديد

  const CleanerDetailsPage({
    Key? key,
    required this.name,
    required this.image,
    required this.locationLink,
    required this.providerId,
    required this.serviceName,
    required this.price,
  }) : super(key: key);

  // دالة لفتح Google Maps
  void _openMap(String link) async {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open the map link.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.white)),
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
            CircleAvatar(radius: 35, backgroundImage: NetworkImage(image)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
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
                    children: [
                      const Text(
                        "JOD 70 ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        "Starting Price",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // زر الموقع
                  GestureDetector(
                    onTap: () => _openMap(locationLink),
                    child: Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          "Location",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        /// باقي الصفحة كما هي...
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
        const Text(
          "Overview",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
            """
Hired 10 times \n Serves Zarqa \n Background checked""",
        style: TextStyle(fontSize: 14, color: Colors.black87),
      ),
      const SizedBox(height: 20),
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
      const Text(
        "Payment methods",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      const Text(
        "This pro accepts payments via Cash, Zain Cash, and Bank transfer.",
        style: TextStyle(fontSize: 14, color: Colors.black87),
      ),

      // ✅ زر Book Now (بعد أن نرى كل المعلومات)
      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB68645),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentMethodSelection(
                  serviceName: serviceName,
                  providerId: providerId,
                  price: price,
                ),
              ),
            );
          },
          child: const Text(
            "✅ Book Now — Pay Securely",
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
// ---------------- Client Chat List Screen ---------------- //
class ClientChatListScreen extends StatelessWidget {
  const ClientChatListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFB68645);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Service Providers',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('service_providers')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No service providers found.'));
          }
          final providers = snapshot.data!.docs;
          return ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              final data = provider.data();
              final fullName =
              '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
              final email = data['email'] ?? 'No email';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(fullName.isEmpty ? 'Unknown Provider' : fullName),
                  subtitle: Text(email),
                  trailing: const Icon(Icons.chat, color: Color(0xFFB68645)),
                  onTap: () {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    final currentUserId = currentUser?.uid ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientChatScreen(
                          providerId: provider.id,
                          providerName: fullName,
                          clientId: currentUserId,
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
// ✅ Chat Screen
class ClientChatScreen extends StatefulWidget {
  final String clientId;
  final String providerId;
  final String providerName;
  const ClientChatScreen({
    super.key,
    required this.clientId,
    required this.providerId,
    required this.providerName,
  });
  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}
class _ClientChatScreenState extends State<ClientChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late String chatId;
  @override
  void initState() {
    super.initState();
    // ✅ نفس منطق السيرفس بروفايدر
    chatId = widget.clientId.compareTo(widget.providerId) < 0
        ? "${widget.clientId}_${widget.providerId}"
        : "${widget.providerId}_${widget.clientId}";
  }
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final msgData = {
      'senderId': widget.clientId,
      'receiverId': widget.providerId,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    // ✅ إنشاء أو تحديث الدردشة الأساسية
    await chatRef.set({
      'participants': [widget.clientId, widget.providerId],
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // ✅ إضافة الرسالة للمحادثة
    await chatRef.collection('messages').add(msgData);
    _messageController.clear();
  }
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFB68645);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.providerName),
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
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }
                final messages = snapshot.data!.docs;
                // ✅ نحدّث حالة القراءة
                for (var doc in messages) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['receiverId'] == widget.clientId &&
                      data['isRead'] == false) {
                    doc.reference.update({'isRead': true});
                  }
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isClient = msg['senderId'] == widget.clientId;
                    final time = msg['timestamp'] != null
                        ? (msg['timestamp'] as Timestamp)
                        .toDate()
                        .toLocal()
                        .toString()
                        .substring(11, 16)
                        : '';
                    return Align(
                      alignment: isClient
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isClient
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
                                color: isClient ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                color: isClient
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
          // ✅ مربع الإرسال
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
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
//---------- profile screen ----------//
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  // تحميل بيانات المستخدم من Firestore
  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('clients') // اسم الكولكشن تبع المستخدمين
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() {
            firstName = doc['firstName'] ?? '';
            lastName = doc['lastName'] ?? '';
            email = doc['email'] ?? user.email ?? '';
            phone = doc['phone'] ?? '';
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        isLoading = false;
      });
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // صورة الملف الشخصي
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: primaryColor,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
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
            // زر تعديل الملف الشخصي
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
            // تغيير كلمة المرور
            _buildSettingTile(
              Icons.lock,
              "Change Password",
              primaryColor,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            // الإشعارات
            _buildSettingTile(
              Icons.notifications,
              "Notifications",
              primaryColor,
                  () {},
            ),
            // المساعدة والدعم
            _buildSettingTile(
              Icons.help_outline,
              "Help & Support",
              primaryColor,
                  () {},
            ),
            // تسجيل الخروج
            _buildSettingTile(
              Icons.logout,
              "Logout",
              primaryColor,
                  () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  // عنصر إعداد (Tile)
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
  bool isLoading = false;
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
  Future<void> _updateUserData() async {
    try {
      setState(() => isLoading = true);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception("User not logged in");
      }
      await FirebaseFirestore.instance.collection('clients').doc(uid).update({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      Navigator.pop(context); // يرجع للشاشة السابقة بعد التحديث
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
    } finally {
      setState(() => isLoading = false);
    }
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
              decoration: const InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone",
                border: OutlineInputBorder(),
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
                onPressed: isLoading ? null : _updateUserData,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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