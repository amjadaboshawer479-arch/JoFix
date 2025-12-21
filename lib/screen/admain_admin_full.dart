
import 'package:flutter/material.dart';
import 'package:amjad/screen/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ================== Admin Login Screen ==================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  // ✅ ضع بيانات حساب الأدمن في Firebase Auth هنا (email/password)
  // IMPORTANT: هذه القيم لازم تكون نفس المستخدم اللي أضفته في Firebase Authentication.
  static const String _firebaseAdminEmail = "admin@myapp.com";
  static const String _firebaseAdminPassword = "Admin@12345";

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Front-end simulation: admin username/password
    if (usernameController.text == "amjad" &&
        passwordController.text == "amjad@ahmad") {
      setState(() => errorMessage = null);

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _firebaseAdminEmail.trim(),
          password: _firebaseAdminPassword,
        );

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = "Firebase admin login failed: ${e.code}";
        });
      } catch (e) {
        setState(() {
          errorMessage = "Firebase admin login failed: $e";
        });
      }
    } else {
      setState(() {
        errorMessage = "Invalid admin credentials";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brown = Color(0xFF00457C);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brown,
        title: const Text("Admin Login", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brown,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _login,
                child: const Text(
                  "Login",
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

// ================== Admin Dashboard ==================
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    // نفس الواجهة، فقط navigation أنظف
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brown = Color(0xFF00457C);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brown,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Welcome, Admin.",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00457C),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF00457C)),
              title: const Text("Manage Users"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageUsersPage(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.miscellaneous_services,
                color: Color(0xFF00457C),
              ),
              title: const Text("Manage Services"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageServicesScreen(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.article, color: Color(0xFF00457C)),
              title: const Text("Manage Posts"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagePostsScreen(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== Manage Users (Admin) ==================
class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({Key? key}) : super(key: key);
  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final Color primaryColor = const Color(0xFF00457C);

  String filterType = "All";
  String _searchQuery = "";

  // collections حسب مشروعك
  final _clientsRef = FirebaseFirestore.instance.collection('clients');
  final _providersRef = FirebaseFirestore.instance.collection(
    'service_providers',
  );

  List<Map<String, dynamic>> _applySearchAndFilter(
      List<Map<String, dynamic>> all,
      ) {
    final q = _searchQuery.trim().toLowerCase();
    return all.where((u) {
      final typeOk = filterType == "All" || (u['type'] == filterType);
      if (!typeOk) return false;

      if (q.isEmpty) return true;

      final fn = (u['firstName'] ?? '').toString().toLowerCase();
      final ln = (u['lastName'] ?? '').toString().toLowerCase();
      final em = (u['email'] ?? '').toString().toLowerCase();
      return fn.contains(q) || ln.contains(q) || em.contains(q);
    }).toList();
  }

  Future<void> _toggleStatus(Map<String, dynamic> user) async {
    final DocumentReference ref = user['_ref'] as DocumentReference;
    final current = (user['status'] ?? 'Active').toString();
    final next = current == "Active" ? "Inactive" : "Active";
    await ref.update({
      'status': next,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _showDeleteDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: Text(
          "Are you sure you want to delete ${user['firstName']} ${user['lastName']}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                final DocumentReference ref = user['_ref'] as DocumentReference;
                await ref.delete();
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUser(
      Map<String, dynamic> user,
      Map<String, String> updated,
      ) async {
    final DocumentReference ref = user['_ref'] as DocumentReference;
    await ref.update({
      'firstName': updated['firstName'],
      'lastName': updated['lastName'],
      'email': updated['email'],
      'phone': updated['phone'],
      // type/status لا نغيرهم من شاشة edit (نفس UI)
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Manage Users",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ===== البحث والفلتر =====
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: filterType,
                  items: const [
                    DropdownMenuItem(value: "All", child: Text("All")),
                    DropdownMenuItem(value: "Client", child: Text("Client")),
                    DropdownMenuItem(
                      value: "Service Provider",
                      child: Text("Service Provider"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => filterType = value);
                  },
                ),
              ],
            ),
          ),

          // ===== قائمة المستخدمين =====
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _clientsRef.snapshots(),
              builder: (context, clientsSnap) {
                if (clientsSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (clientsSnap.hasError) {
                  return Center(child: Text("Error: ${clientsSnap.error}"));
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: _providersRef.snapshots(),
                  builder: (context, providersSnap) {
                    if (providersSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (providersSnap.hasError) {
                      return Center(
                        child: Text("Error: ${providersSnap.error}"),
                      );
                    }

                    final allUsers = <Map<String, dynamic>>[];

                    for (final d in (clientsSnap.data?.docs ?? [])) {
                      final data = (d.data() as Map<String, dynamic>? ?? {});
                      allUsers.add({
                        ...data,
                        'type': 'Client',
                        'status': data['status'] ?? 'Active',
                        '_ref': d.reference,
                      });
                    }

                    for (final d in (providersSnap.data?.docs ?? [])) {
                      final data = (d.data() as Map<String, dynamic>? ?? {});
                      allUsers.add({
                        ...data,
                        'type': 'Service Provider',
                        'status': data['status'] ?? 'Active',
                        '_ref': d.reference,
                      });
                    }

                    final users = _applySearchAndFilter(allUsers);

                    if (users.isEmpty) {
                      return const Center(
                        child: Text(
                          "No users found.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            title: Text(
                              "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Email: ${user['email'] ?? ''}"),
                                Text("Phone: ${user['phone'] ?? ''}"),
                                Text("Type: ${user['type']}"),
                                Text("Status: ${user['status']}"),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditUserScreen(
                                            user: {
                                              "firstName":
                                              (user['firstName'] ?? '')
                                                  .toString(),
                                              "lastName":
                                              (user['lastName'] ?? '')
                                                  .toString(),
                                              "email": (user['email'] ?? '')
                                                  .toString(),
                                              "phone": (user['phone'] ?? '')
                                                  .toString(),
                                              "type": (user['type'] ?? '')
                                                  .toString(),
                                              "status": (user['status'] ?? '')
                                                  .toString(),
                                            },
                                          ),
                                        ),
                                      );

                                      if (result != null) {
                                        try {
                                          await _updateUser(
                                            user,
                                            Map<String, String>.from(result),
                                          );
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Update failed: $e",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _showDeleteDialog(user),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              try {
                                await _toggleStatus(user);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Status update failed: $e"),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== Edit User Screen ======================
class EditUserScreen extends StatefulWidget {
  final Map<String, String> user;
  const EditUserScreen({Key? key, required this.user}) : super(key: key);
  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user['firstName']);
    lastNameController = TextEditingController(text: widget.user['lastName']);
    emailController = TextEditingController(text: widget.user['email']);
    phoneController = TextEditingController(text: widget.user['phone']);
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
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Edit User"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    "firstName": firstNameController.text,
                    "lastName": lastNameController.text,
                    "email": emailController.text,
                    "phone": phoneController.text,
                    "type": widget.user['type']!,
                    "status": widget.user['status']!,
                  });
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== Manage Services (Admin) ==================
class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({Key? key}) : super(key: key);
  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  static const primaryColor = Color(0xFF00457C);

  String searchQuery = "";
  String filter = "All"; // All, Active, Inactive

  final _servicesGroup = FirebaseFirestore.instance.collectionGroup('services');

  void _showServiceDialog({DocumentSnapshot? doc}) {
    final data = (doc?.data() as Map<String, dynamic>?) ?? {};

    final nameController = TextEditingController(text: data['name'] ?? "");
    final descController = TextEditingController(
      text: data['description'] ?? "",
    );
    final priceController = TextEditingController(
      text: (data['price'] ?? "").toString(),
    );

    // ⚠️ نفس UI عندك "Provider Name" — بنستخدمه كـ ProviderId (UID) بدون تغيير الواجهة
    final providerIdFromPath =
    (doc != null && doc.reference.parent.parent != null)
        ? doc.reference.parent.parent!.id
        : "";
    final providerController = TextEditingController(
      text: (data['providerId'] ?? providerIdFromPath).toString(),
    );

    bool active = (data['active'] ?? true) as bool;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  doc == null ? "Add Service" : "Edit Service",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Service Name"),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
                TextField(
                  controller: providerController,
                  decoration: const InputDecoration(labelText: "Provider Name"),
                ),
                SwitchListTile(
                  value: active,
                  activeColor: primaryColor,
                  title: const Text("Active"),
                  onChanged: (val) => setState(() => active = val),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        descController.text.trim().isEmpty ||
                        providerController.text.trim().isEmpty) {
                      return;
                    }

                    final providerId = providerController.text.trim();

                    final payload = <String, dynamic>{
                      "name": nameController.text.trim(),
                      "description": descController.text.trim(),
                      "price": int.tryParse(priceController.text.trim()) ?? 0,
                      "providerId": providerId,
                      "active": active,
                      "updatedAt": FieldValue.serverTimestamp(),
                    };

                    try {
                      if (doc == null) {
                        // ✅ إضافة تحت service_providers/{providerId}/services
                        await FirebaseFirestore.instance
                            .collection('service_providers')
                            .doc(providerId)
                            .collection('services')
                            .add({
                          ...payload,
                          "createdAt": FieldValue.serverTimestamp(),
                        });
                      } else {
                        final oldProviderId = providerIdFromPath;

                        // إذا الأدمن غيّر providerId لازم ننقل الوثيقة
                        if (oldProviderId.isNotEmpty &&
                            providerId != oldProviderId) {
                          await FirebaseFirestore.instance
                              .collection('service_providers')
                              .doc(providerId)
                              .collection('services')
                              .add({
                            ...payload,
                            "createdAt": FieldValue.serverTimestamp(),
                          });
                          await doc.reference.delete();
                        } else {
                          await doc.reference.update(payload);
                        }
                      }

                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Failed: $e")));
                      }
                    }
                  },
                  child: Text(
                    doc == null ? "Add" : "Save",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text(
          "Are you sure you want to delete ${(doc.data() as Map<String, dynamic>)['name'] ?? ''}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await doc.reference.delete();
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
                }
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  bool _matchesFilter(Map<String, dynamic> s) {
    if (filter == "All") return true;
    if (filter == "Active") return (s['active'] ?? false) == true;
    if (filter == "Inactive") return (s['active'] ?? true) == false;
    return true;
  }

  bool _matchesSearch(Map<String, dynamic> s) {
    final name = (s['name'] ?? '').toString().toLowerCase();
    return name.contains(searchQuery.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Manage Services",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => setState(() => filter = val),
            itemBuilder: (context) => const [
              PopupMenuItem(value: "All", child: Text("All")),
              PopupMenuItem(value: "Active", child: Text("Active")),
              PopupMenuItem(value: "Inactive", child: Text("Inactive")),
            ],
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showServiceDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search services...",
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _servicesGroup.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final filtered = docs.where((d) {
                    final data = (d.data() as Map<String, dynamic>? ?? {});
                    return _matchesFilter(data) && _matchesSearch(data);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text("No services found."));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final service = doc.data() as Map<String, dynamic>;
                      final providerId = (doc.reference.parent.parent != null)
                          ? doc.reference.parent.parent!.id
                          : (service['providerId'] ?? '').toString();

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.2),
                            child: const Icon(Icons.build, color: primaryColor),
                          ),
                          title: Text(
                            (service['name'] ?? '').toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((service['description'] ?? '').toString()),
                              Text("Price: \$${service['price'] ?? 0}"),
                              Text("Provider: $providerId"),
                              Text(
                                "Status: ${(service['active'] ?? true) ? 'Active' : 'Inactive'}",
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: primaryColor,
                                ),
                                onPressed: () => _showServiceDialog(doc: doc),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(doc),
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
          ],
        ),
      ),
    );
  }
}

// ================== Manage Posts (Admin) ==================
class ManagePostsScreen extends StatefulWidget {
  const ManagePostsScreen({Key? key}) : super(key: key);
  @override
  State<ManagePostsScreen> createState() => _ManagePostsScreenState();
}

class _ManagePostsScreenState extends State<ManagePostsScreen> {
  final Color primaryColor = const Color(0xFF00457C);

  final _postsRef = FirebaseFirestore.instance.collection('posts');

  String searchQuery = "";
  String filter = "All";

  List<Map<String, dynamic>> _filterPosts(List<Map<String, dynamic>> posts) {
    final q = searchQuery.toLowerCase();

    return posts.where((post) {
      final title = (post["title"] ?? "").toString().toLowerCase();
      final content = (post["content"] ?? "").toString().toLowerCase();

      final matchesSearch = title.contains(q) || content.contains(q);
      final matchesFilter = filter == "All" || (post["status"] == filter);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _showPostDialog({DocumentSnapshot? doc}) {
    final data = (doc?.data() as Map<String, dynamic>?) ?? {};

    final titleController = TextEditingController(text: data["title"] ?? "");
    final contentController = TextEditingController(
      text: data["content"] ?? "",
    );
    final authorController = TextEditingController(
      text: data["author"] ?? "Admin",
    );
    String status = (data["status"] ?? "Published").toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(doc == null ? "Add Post" : "Edit Post"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Content"),
                maxLines: 3,
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: "Author"),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: status,
                items: ["Published", "Hidden"]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => status = value);
                },
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
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              if (titleController.text.trim().isEmpty ||
                  contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Title and Content cannot be empty"),
                  ),
                );
                return;
              }

              final payload = <String, dynamic>{
                "title": titleController.text.trim(),
                "content": contentController.text.trim(),
                "author": authorController.text.trim(),
                "status": status,
                "updatedAt": FieldValue.serverTimestamp(),
              };

              try {
                if (doc == null) {
                  await _postsRef.add({
                    ...payload,
                    "date": FieldValue.serverTimestamp(),
                    "createdAt": FieldValue.serverTimestamp(),
                  });
                } else {
                  await doc.reference.update(payload);
                }
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Save failed: $e")));
                }
              }
            },
            child: Text(
              doc == null ? "Add" : "Save",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await doc.reference.delete();
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
                }
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _openPostDetails(Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailsScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Manage Posts",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => filter = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: "All", child: Text("All")),
              PopupMenuItem(value: "Published", child: Text("Published")),
              PopupMenuItem(value: "Hidden", child: Text("Hidden")),
            ],
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showPostDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search posts...",

                prefixIcon: const Icon(Icons.search, color: Color(0xFF00457C)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _postsRef.orderBy('date', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final docs = snapshot.data?.docs ?? [];
                final posts = docs.map((d) {
                  final data = (d.data() as Map<String, dynamic>? ?? {});
                  final dateVal = data['date'];
                  DateTime dt = DateTime.now();
                  if (dateVal is Timestamp) dt = dateVal.toDate();
                  return {...data, "_ref": d.reference, "date": dt};
                }).toList();

                final filtered = _filterPosts(posts);

                if (filtered.isEmpty) {
                  return const Center(child: Text("No posts found."));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final post = filtered[index];
                    final ref = post["_ref"] as DocumentReference;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (post["title"] ?? "").toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              (post["content"] ?? "").toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => _openPostDetails(post),
                                  child: const Text(
                                    "Read More",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Color(0xFF00457C),
                                      ),
                                      onPressed: () async {
                                        final snap = await ref.get();
                                        if (!mounted) return;
                                        _showPostDialog(doc: snap);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final snap = await ref.get();
                                        if (!mounted) return;
                                        _confirmDelete(snap);
                                      },
                                    ),
                                  ],
                                ),
                              ],
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
        ],
      ),
    );
  }
}

class PostDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostDetailsScreen({Key? key, required this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00457C);

    final date = post["date"] is DateTime
        ? (post["date"] as DateTime)
        : DateTime.now();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          "Post Details",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (post["title"] ?? "").toString(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("By: ${(post["author"] ?? "").toString()}"),
            Text("Date: ${date.toString().split(" ")[0]}"),
            Text("Status: ${(post["status"] ?? "").toString()}"),
            const Divider(height: 20, thickness: 1),
            Text(
              (post["content"] ?? "").toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
