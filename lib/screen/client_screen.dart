import 'package:amjad/screen/payment/payment_method_selection.dart';
import 'package:flutter/material.dart';
import 'package:amjad/screen/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

//-------------------Client Home Page-------------------//
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
  String? loginError;
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

  // login with email and pass
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
  //login with facebook
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
    const Color borderColor = Color(0xFF00457C);
    const Color buttonColor = Color(0xFF00457C);
    bool allValid = isPhoneValid && isEmailValid && isPasswordValid;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Client Login",
          style: TextStyle(
            color: borderColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            const Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 30,
                color: Color(0xFF00457C),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Sign in to your Client account.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 40),
            // --------------------------------PHONE--------------------------------
            // Label for Phone/Full Name
            const Text(
              "Phone Number",
              style: TextStyle(
                fontSize: 14,
                color:
                Colors.black54, // Color similar to the labels in the image
              ),
            ),
            const SizedBox(height: 6), // Small space between label and box
            _buildStyledField(
              controller: phoneController,
              hint: "Phone e.g. +9627XXXXXXXX",
              keyboard: TextInputType.phone,
              onChanged: _checkPhone,
            ),
            if (!isPhoneValid && phoneController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Phone number must start with +962",
                  style: TextStyle(color: borderColor, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            // --------------------------------EMAIL--------------------------------
            // Label for Email
            const Text(
              "Email ID",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            _buildStyledField(
              controller: emailController,
              hint: "Email",
              keyboard: TextInputType.emailAddress,
              onChanged: _checkEmail,
            ),
            const SizedBox(height: 16),
            //-------------------------------PASSWORD-------------------------------
            // Label for Password
            const Text(
              "Password",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            _buildStyledField(
              controller: passwordController,
              hint: "Password",
              obscure: !isPasswordVisible,
              onChanged: _checkPassword,
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
            const SizedBox(height: 50),
            //--------------------------------ERROR--------------------------------
            if (loginError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  loginError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            //-------------------------------LOGIN BUTTON-------------------------------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: allValid ? _loginClient : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allValid ? buttonColor : Colors.grey,
                  elevation: allValid ? 3 : 0,
                  shadowColor: borderColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 14,
                    color: borderColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // --------------------------------- OR ---------------------------------
            Row(
              children: const [
                Expanded(child: Divider(color: Colors.black26)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("or", style: TextStyle(color: Colors.black45)),
                ),
                Expanded(child: Divider(color: Colors.black26)),
              ],
            ),
            const SizedBox(height: 24),
            // ------------------------------- SOCIAL --------------------------------
            _buildSocialButton("Continue With Google", isFacebook: false),
            const SizedBox(height: 12),
            _buildSocialButton(
              "Continue With Facebook",
              icon: Icons.facebook,
              isFacebook: true,
            ),
            const SizedBox(height: 26),
            // ----------------------------- SIGNUP NAV -----------------------------
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

  // 🔥 BEAUTIFUL REUSABLE FIELD -------------------------
  Widget _buildStyledField({
    required TextEditingController controller,
    required String hint, // This will become the placeholder/current value
    required Function(String) onChanged,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        onChanged: onChanged,
        // The image uses the hint text as the current value style
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          suffixIcon: suffixIcon,
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
    const primaryColor = Color(0xFF00457C);

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
  // ... (نفس المتغيرات والتحققات والدوال المنطقية) ...
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
    return phone.isNotEmpty &&
        phone.startsWith("+962") &&
        phone.length >= 13; // +9627XXXXXXXX
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

  // 🔥 دالة إنشاء الحساب والتخزين في الكوليكشن clients (نفس الدالة الأصلية)
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

  // 🔥 وظائف الدخول الاجتماعي (يمكن نقلها إلى كلاس مشترك لاحقًا)
  Future<void> _signupWithGoogle() async {
    // يرجى إضافة منطق التسجيل عبر جوجل هنا
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Google Sign Up logic placeholder")),
    );
  }

  Future<void> _signupWithFacebook() async {
    // يرجى إضافة منطق التسجيل عبر فيسبوك هنا
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Facebook Sign Up logic placeholder")),
    );
  }

  // -------------------------------------------------------------------
  // 🔥 دالة مساعدة لتصميم حقول الإدخال
  Widget _buildStyledField({
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  // 🔥 دالة مساعدة لبناء الحقل مع العنوان ورسالة الخطأ
  Widget _buildFieldWithLabel({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    String? errorText,
    Widget? bottomWidget,
  }) {
    const Color borderColor = Color(0xFF00457C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        _buildStyledField(
          controller: controller,
          hint: hint,
          onChanged: onChanged,
          keyboard: keyboard,
          obscure: obscure,
          suffixIcon: suffixIcon,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
        else if (bottomWidget != null)
          Padding(padding: const EdgeInsets.only(top: 5), child: bottomWidget),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFF00457C);
    const Color buttonColor = Color(0xFF00457C);

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
        centerTitle: true,
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: borderColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            const Text(
              "Please fill in the information below",
              style: TextStyle(
                fontSize: 22,
                color: borderColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // ==================== FIRST NAME ====================
            _buildFieldWithLabel(
              label: "First Name",
              controller: firstNameController,
              hint: "Enter your first name",
              onChanged: (_) => validateFirst(),
              errorText: firstNameError,
            ),
            const SizedBox(height: 16),

            // ===================== LAST NAME =====================
            _buildFieldWithLabel(
              label: "Last Name",
              controller: lastNameController,
              hint: "Enter your last name",
              onChanged: (_) => validateLast(),
              errorText: lastNameError,
            ),
            const SizedBox(height: 16),

            // =================== PHONE NUMBER ===================
            _buildFieldWithLabel(
              label: "Phone Number",
              controller: phoneController,
              hint: "Phone e.g. +9627XXXXXXXX",
              keyboard: TextInputType.phone,
              onChanged: (_) => validatePhone(),
              errorText: phoneError,
              bottomWidget: (!isPhoneValid && phoneController.text.isNotEmpty)
                  ? const Text(
                "Phone number must start with +962",
                style: TextStyle(fontSize: 12, color: borderColor),
              )
                  : null,
            ),
            const SizedBox(height: 16),

            // ======================== EMAIL ========================
            _buildFieldWithLabel(
              label: "Email ID",
              controller: emailController,
              hint: "Email",
              keyboard: TextInputType.emailAddress,
              onChanged: (_) => validateEmail(),
              errorText: emailError,
            ),
            const SizedBox(height: 16),

            // ====================== PASSWORD FIELD =======================
            _buildFieldWithLabel(
              label: "Password",
              controller: passController,
              hint: "Password",
              obscure: _obscurePassword,
              onChanged: (_) => validatePass(),
              errorText: passError,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: borderColor,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Password must contain:\n"
                  "- At least 8 characters\n"
                  "- Uppercase (A-Z)\n"
                  "- Lowercase (a-z)\n"
                  "- Number (0-9)\n"
                  "- Special character (!@#\$%^&*)",
              style: TextStyle(fontSize: 12, color: borderColor, height: 1.4),
            ),

            const SizedBox(height: 16),

            // ==================== SIGN UP BUTTON ====================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: allValid ? buttonColor : Colors.grey,
                  elevation: allValid ? 3 : 0,
                  shadowColor: borderColor.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: allValid ? _handleSignup : null,
                child: const Text(
                  "Sign UP",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 26),

            // ----------------------------- LOGIN NAV -----------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                TextButton(
                  onPressed: () {
                    // افتراض أن LoginScreen موجودة في المسار الصحيح
                    Navigator.pop(
                      context,
                    ); // العودة لشاشة الدخول (ClientHomePage)
                  },
                  child: const Text(
                    "Login",
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
                color: Color(0xFF00457C),
              ),
              const SizedBox(height: 20),
              Text(
                "A verification email has been sent to:\n${FirebaseAuth.instance.currentUser?.email ?? ''}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Please check your inbox and click the verification link.\nAfter that, click the button below:",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00457C),
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
                  style: TextStyle(color: Color(0xFF00457C)),
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

  // 👇 جديد: ScrollController عشان نقدر نطلع لفوق
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> activities = [
    {"title": "Cleanix", "image": "imagee/handlyNew-_2_.jpg"},
    {"title": "Fixer", "image": "imagee/handlyNew-_1_.jpg"},
    {"title": "Carely", "image": "imagee/LocalNew-_2_.jpg"},
    {"title": "Moveit", "image": "imagee/LocalNew-_1_.jpg"},
    {"title": "Clearit", "image": "imagee/removNew.jpg"},
    {"title": "BuildUp", "image": "imagee/assemblyNew.jpg"},
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
    _scrollController
        .dispose(); // 👈 لازم نعمل dispose للـ ScrollController كمان
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const primaryColor = Color(0xFF00457C);

    // تكييف بسيط لعدد الأعمدة حسب عرض الشاشة
    final int crossAxisCount = size.width < 360 ? 2 : 3;
    final double childAspectRatio = size.width < 360 ? 0.8 : 0.85;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00457C),
        elevation: 0,
        title: const Text(
          "Services",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller:
          _scrollController, // 👈 ربطنا الـ ScrollController بالسكول
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, ${widget.firstName} ${widget.lastName}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF00457C),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: "Search for services...",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  //contentPadding: const EdgeInsets.symmetric(
                  //  horizontal: 12,
                  //  vertical: 10,
                  // ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Based On Your Activity",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF00457C),
                  fontWeight: FontWeight.w600,
                ),
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredActivities.length,
                itemBuilder: (context, index) {
                  final activity = filteredActivities[index];
                  return InkWell(
                    onTap: () {
                      if (activity["title"] == "Cleanix") {
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
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        // 👇 نجيب كل الأوردرات لهذا الكلينت
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where(
          'clientId',
          isEqualTo: FirebaseAuth.instance.currentUser?.uid,
        )
            .snapshots(),
        builder: (context, snapshot) {
          int notifCount = 0;

          if (snapshot.hasData) {
            // نعدّ بس الطلبات اللي مش Pending (Accepted / Rejected / Completed)
            final docs = snapshot.data!.docs;
            notifCount = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final status = (data['status'] ?? 'Pending')
                  .toString()
                  .toLowerCase();
              return status != 'pending';
            }).length;
          }

          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final bool isService = index == 2;
                final Color selectedColor = primaryColor;

                // 🔹 الآيتم اللي بالنص (Service) زي ما هو
                if (isService) {
                  return GestureDetector(
                    onTap: () {
                      // هون لو حاب تعمل إشي مثلا ترجع للهوم نفس الشاشة
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00457C), Color(0xFF00C6FF)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.home_repair_service,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Service",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 🔹 باقي الأيقونات (Notification, Search, Inbox, Profile)
                final icons = [
                  Icons.notifications,
                  Icons.search,
                  Icons.message,
                  Icons.person,
                ];
                final labels = ["Notification", "Search", "Inbox", "Profile"];

                // لأن عنا Service بالنص، بنعمل mapping بسيط
                final mappedIndex = index > 2 ? index - 1 : index;

                // ✅ Notification (index 0) مع البادج + فتح صفحة النوتيفيكيشن
                if (mappedIndex == 0) {
                  final baseItem = _AnimatedNavBarItem(
                    icon: icons[mappedIndex],
                    label: labels[mappedIndex],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const ClientNotificationsScreen(),
                        ),
                      );
                    },
                  );

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      baseItem,
                      if (notifCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              notifCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }

                // ✅ Search (index 1) → يطلع لفوق ويفوكس على بوكس السيرش
                if (mappedIndex == 1) {
                  return _AnimatedNavBarItem(
                    icon: icons[mappedIndex],
                    label: labels[mappedIndex],
                    onTap: () async {
                      await _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                      FocusScope.of(context).requestFocus(_searchFocusNode);
                    },
                  );
                }

                // ✅ Inbox و Profile نفس اللي كان عندك
                return _AnimatedNavBarItem(
                  icon: icons[mappedIndex],
                  label: labels[mappedIndex],
                  onTap: () {
                    switch (mappedIndex) {
                      case 2: // Inbox
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClientChatListScreen(),
                          ),
                        );
                        break;
                      case 3: // Profile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ),
                        );
                        break;
                    }
                  },
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _ServiceCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _isHovered ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00457C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Animated NavBar Item =====
class _AnimatedNavBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AnimatedNavBarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_AnimatedNavBarItem> createState() => _AnimatedNavBarItemState();
}

class _AnimatedNavBarItemState extends State<_AnimatedNavBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: _isHovered ? 10 : 6,
            horizontal: _isHovered ? 16 : 12,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.blue.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          transform: Matrix4.identity(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: _isHovered ? Colors.blue : Colors.black54,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered ? Colors.blue : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//------- اذا كبس على hose cleaning من جوا ---//
class HouseCleaningProsPage extends StatelessWidget {
  const HouseCleaningProsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        // 👈 بس ضفت هاي
        child: StreamBuilder<QuerySnapshot>(
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
                final rating = (data['rating'] ?? 4.5).toDouble();
                final reviews = data['reviews'] ?? 10;
                final desc =
                    data['description'] ??
                        "Professional service provider/n with high experience.";
                final image = "imagee/service pro.jpg";

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
                            image,
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CleanerDetailsPage(
                                        name: name,
                                        image: image,
                                        locationLink: data['mapLink'] ?? '',
                                        providerId: providers[index].id,
                                        serviceName: "House Cleaning",
                                        price: 70.0,
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
      ),
    );
  }
}

//-------في حال كبس على read more ------//

class CleanerDetailsPage extends StatelessWidget {
  final String name;
  final String image;
  final String providerId; // ✅ جديد
  final String serviceName; // ✅ جديد
  final double price; // ✅ جديد
  final String locationLink; // الرابط من Firebase

  const CleanerDetailsPage({
    Key? key,
    required this.name,
    required this.image,
    required this.providerId,
    required this.serviceName,
    required this.price,
    required this.locationLink,
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
        backgroundColor: const Color(0xFF00457C),
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

                      // ✅ زر Book Now (بعد أن نرى كل المعلومات)
                      const SizedBox(height: 26),
                      SizedBox(
                        width: 230,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00457C),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                            " Book Now Pay Securely",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
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
              "Hired 10 times\nServes Zarqa\nBackground checked",
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
    const Color primaryColor = Color(0xFF00457C);
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
                  trailing: const Icon(Icons.chat, color: Color(0xFF00457C)),
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
    const Color primaryColor = Color(0xFF00457C);

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

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('clients')
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
    const primaryColor = Color(0xFF00457C);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
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
            // بطاقة شخصية متدرّجة مع صورة كبيرة
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00457C), Color(0xFF00C6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF00457C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "$firstName $lastName",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // قائمة الإعدادات بأسلوب Neumorphism مع Hover / Tap
            Column(
              children: [
                _buildAnimatedSettingTile(
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () async {
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
                _buildAnimatedSettingTile(
                  icon: Icons.lock,
                  title: "Change Password",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                _buildAnimatedSettingTile(
                  icon: Icons.notifications,
                  title: "Notifications",
                  onTap: () {},
                ),
                _buildAnimatedSettingTile(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {},
                ),
                _buildAnimatedSettingTile(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  isLogout: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Tile مع تأثير Hover / Tap
  Widget _buildAnimatedSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    const Color primaryColor = Color(0xFF00457C);
    bool isPressed = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: isLogout ? Colors.red.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isPressed
                  ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLogout ? Colors.red.shade100 : Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isLogout ? Colors.red : primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isLogout ? FontWeight.bold : FontWeight.w600,
                      color: isLogout ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
                if (!isLogout)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.black38,
                  ),
              ],
            ),
          ),
        );
      },
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
      if (uid == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection('clients').doc(uid).update({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: Color(0xFF00457C))
              : null,
          hintText: label,
          hintStyle: const TextStyle(color: Colors.black38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00457C);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(
              controller: firstNameController,
              label: "First Name",
              icon: Icons.person,
            ),
            _buildTextField(
              controller: lastNameController,
              label: "Last Name",
              icon: Icons.person_outline,
            ),
            _buildTextField(
              controller: emailController,
              label: "Email",
              icon: Icons.email,
            ),
            _buildTextField(
              controller: phoneController,
              label: "Phone",
              icon: Icons.phone,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _updateUserData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00457C), Color(0xFF00C6FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
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

  bool get isConfirmMatching =>
      confirmController.text.isNotEmpty &&
          newController.text.isNotEmpty &&
          confirmController.text == newController.text;

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIcon: icon != null
              ? Icon(icon, color: Color(0xFF00457C))
              : null,
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
            onPressed: toggleVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00457C);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPasswordField(
              controller: currentController,
              label: "Current Password",
              obscureText: _obscureCurrent,
              toggleVisibility: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
              icon: Icons.lock_outline,
            ),
            _buildPasswordField(
              controller: newController,
              label: "New Password",
              obscureText: _obscureNew,
              toggleVisibility: () =>
                  setState(() => _obscureNew = !_obscureNew),
              icon: Icons.lock,
            ),
            _buildPasswordField(
              controller: confirmController,
              label: "Confirm Password",
              obscureText: _obscureConfirm,
              toggleVisibility: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icons.lock_person,
            ),
            if (confirmController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  isConfirmMatching
                      ? "Passwords match ✔"
                      : "Passwords do not match ✖",
                  style: TextStyle(
                    color: isConfirmMatching ? Colors.green : Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (!isPasswordValid && newController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "Password must be at least 8 chars, include uppercase, lowercase, number & special char",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
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
                        backgroundColor: primaryColor,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00457C), Color(0xFF00C6FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//في حال كبس المستخدم على تبويب النتوفيكيشن ب البوتم بار ب الهوم سكرين
class ClientNotificationsScreen extends StatelessWidget {
  const ClientNotificationsScreen({Key? key}) : super(key: key);

  String _normalizeStatus(String status) {
    final s = status.toLowerCase();
    if (s == 'pending' || s == 'paid') return 'Pending';
    if (s == 'accepted') return 'Accepted';
    if (s == 'rejected') return 'Rejected';
    if (s == 'completed') return 'Completed';
    return status;
  }

  Color _statusColor(String status) {
    final normalized = _normalizeStatus(status);
    switch (normalized) {
      case 'Accepted':
        return Colors.green;
      case 'Completed':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Notifications",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF00457C),
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Not logged in", style: TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00457C),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('clientId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // فلترة: ما نعرض الـ Pending، بس اللي اتغيّر عليهم إشي
          final docs = snapshot.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final status = (data['status'] ?? 'Pending').toString();
            return _normalizeStatus(status) != 'Pending';
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final service =
              (data['serviceName'] ?? data['service'] ?? 'Service')
                  .toString();
              final rawStatus = (data['status'] ?? 'Pending').toString();
              final status = _normalizeStatus(rawStatus);

              DateTime date = DateTime.now();
              final createdAt = data['updatedAt'] ?? data['createdAt'];
              if (createdAt is Timestamp) {
                date = createdAt.toDate();
              }

              String message;
              if (status == 'Accepted') {
                message = "Your request for $service was accepted.";
              } else if (status == 'Rejected') {
                message = "Your request for $service was rejected.";
              } else if (status == 'Completed') {
                message = "$service has been completed.";
              } else {
                message = "Status of $service: $status";
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: _statusColor(status),
                  ),
                  title: Text(message),
                  subtitle: Text("${date.day}/${date.month}/${date.year}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
