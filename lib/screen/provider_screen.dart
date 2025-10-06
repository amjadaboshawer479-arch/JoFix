import 'package:amjad/screen/login_screen.dart';
import 'package:flutter/material.dart';

//----------اlogin service provider----------//

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

  // --- Validators ---
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

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFB68645);
    const Color buttonColor = Color(0xFFB68645);

    bool allValid = isPhoneValid && isEmailValid && isPasswordValid;

    InputDecoration customInput(String hint) {
      return InputDecoration(
        hintText: hint,
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
      );
    }

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

            // ===== Phone =====
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: customInput("Phone e.g. +9627XXXXXXXX"),
            ),
            const SizedBox(height: 16),

            // ===== Email =====
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: customInput("Email"),
            ),
            const SizedBox(height: 16),

            // ===== Password =====
            TextField(
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: customInput("Password").copyWith(
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

            // ===== Continue Button =====
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: allValid
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ServiceProviderHome(),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("All fields are valid ✅"),
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
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ===== Small Sign Up Button =====
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sign Up clicked")),
                  );
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: buttonColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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

//----------signe up secreen---------//

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
                            builder: (context) => ServiceProviderHome(
                              firstName: firstNameController.text.trim(),
                              lastName: lastNameController.text.trim(),
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text(
                  "Sign Up",
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

//----------- servises of servise provider---------//
class ServiceProviderHome extends StatefulWidget {
  final String firstName;
  final String lastName;

  const ServiceProviderHome({
    Key? key,
    this.firstName = " ",
    this.lastName = " ",
  }) : super(key: key);

  @override
  State<ServiceProviderHome> createState() => _ServiceProviderHomeState();
}

class _ServiceProviderHomeState extends State<ServiceProviderHome> {
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
    final Color activeColor = const Color(0xFFB68645);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB68645),
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
              decoration: BoxDecoration(color: Color(0xFFB68645)),
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
                    leading: const Icon(Icons.phone),
                    title: const Text("Contact Client"),
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
                color: Color(0xFFB68645),
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
  final Color brown = const Color(0xFFB68645);

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
    const Color primaryColor = Color(0xFFB68645);

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
  List<String> clients = ["Client A", "Client B", "Client C"]; // مثال
  Map<String, List<String>> messages = {}; // لكل عميل قائمة رسائل

  @override
  void initState() {
    super.initState();
    for (var client in clients) {
      messages[client] = [];
    }
  }

  void _openChat(String clientName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          clientName: clientName,
          messages: messages[clientName]!,
          onSend: (msg) {
            setState(() {
              messages[clientName]!.add("You: $msg");
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFB68645);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Clients",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return Card(
            child: ListTile(
              title: Text(client),
              subtitle: Text(
                messages[client]!.isNotEmpty
                    ? messages[client]!.last
                    : "No messages yet",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chat, color: Color(0xFFB68645)),
              onTap: () => _openChat(client),
            ),
          );
        },
      ),
    );
  }
}
//----------chat screen inside contact client-------//

class ChatScreen extends StatefulWidget {
  final String clientName;
  final List<String> messages;
  final Function(String) onSend;

  const ChatScreen({
    super.key,
    required this.clientName,
    required this.messages,
    required this.onSend,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFB68645);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientName, style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final msg = widget.messages[index];
                return Align(
                  alignment: msg.startsWith("You:")
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: msg.startsWith("You:")
                          ? primaryColor.withOpacity(0.8)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.replaceFirst("You:", ""),
                      style: TextStyle(
                        color: msg.startsWith("You:")
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
                  backgroundColor: primaryColor,
                  mini: true,
                  child: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    if (msgController.text.trim().isEmpty) return;
                    widget.onSend(msgController.text.trim());
                    setState(() {
                      widget.messages.add("You: ${msgController.text.trim()}");
                    });
                    msgController.clear();
                  },
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
  final Color brown = const Color(0xFFB68645);

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
