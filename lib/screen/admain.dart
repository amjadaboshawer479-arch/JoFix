import 'package:flutter/material.dart';
import 'package:amjad/screen/login_screen.dart';

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
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // Front-end simulation: admin username/password
    if (usernameController.text == "amjad" &&
        passwordController.text == "amjad@ahmad") {
      setState(() {
        errorMessage = null;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//-----------manage user from adman-------//
class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({Key? key}) : super(key: key);
  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final Color primaryColor = const Color(0xFF00457C);
  List<Map<String, String>> allUsers = [
    {
      "firstName": "Ahmad",
      "lastName": "Ali",
      "email": "ahmad@example.com",
      "phone": "+962790000001",
      "type": "Client",
      "status": "Active",
    },
    {
      "firstName": "Sara",
      "lastName": "Khalid",
      "email": "sara@example.com",
      "phone": "+962790000002",
      "type": "Service Provider",
      "status": "Inactive",
    },
    {
      "firstName": "Khaled",
      "lastName": "Omar",
      "email": "khaled@example.com",
      "phone": "+962790000003",
      "type": "Client",
      "status": "Active",
    },
  ];
  List<Map<String, String>> users = [];
  String filterType = "All";
  @override
  void initState() {
    super.initState();
    users = List.from(allUsers);
  }

  void _filterUsers(String type) {
    setState(() {
      filterType = type;
      if (type == "All") {
        users = List.from(allUsers);
      } else {
        users = allUsers.where((u) => u['type'] == type).toList();
      }
    });
  }

  void _searchUsers(String query) {
    setState(() {
      users = allUsers
          .where(
            (u) =>
                u['firstName']!.toLowerCase().contains(query.toLowerCase()) ||
                u['lastName']!.toLowerCase().contains(query.toLowerCase()) ||
                u['email']!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
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
                    onChanged: (value) => _searchUsers(value),
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
                    if (value != null) _filterUsers(value);
                  },
                ),
              ],
            ),
          ),
          // ===== قائمة المستخدمين =====
          Expanded(
            child: ListView.builder(
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
                      "${user['firstName']} ${user['lastName']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${user['email']}"),
                        Text("Phone: ${user['phone']}"),
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
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditUserScreen(user: user),
                                ),
                              );
                              if (result != null) {
                                setState(() {
                                  users[index] = result;
                                  allUsers[allUsers.indexWhere(
                                        (u) => u['email'] == result['email'],
                                      )] =
                                      result;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteDialog(index);
                            },
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _toggleStatus(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleStatus(int index) {
    setState(() {
      users[index]['status'] = users[index]['status'] == "Active"
          ? "Inactive"
          : "Active";
      // تحديث جميع المستخدمين
      final i = allUsers.indexWhere((u) => u['email'] == users[index]['email']);
      if (i != -1) allUsers[i]['status'] = users[index]['status']!;
    });
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: Text(
          "Are you sure you want to delete ${users[index]['firstName']} ${users[index]['lastName']}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                allUsers.removeWhere(
                  (u) => u['email'] == users[index]['email'],
                );
                users.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
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

//---------manage services--------//
class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({Key? key}) : super(key: key);
  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  static const primaryColor = Color(0xFF00457C);
  List<Map<String, dynamic>> services = [
    {
      "name": "House Cleaning",
      "description": "Deep cleaning for houses",
      "price": 50,
      "provider": "Ali Ahmad",
      "active": true,
    },
    {
      "name": "Plumbing",
      "description": "Fixing leaks and pipes",
      "price": 30,
      "provider": "ServicePro Co.",
      "active": false,
    },
    {
      "name": "Electrician",
      "description": "Wiring & electrical issues",
      "price": 40,
      "provider": "Mohammed Saleh",
      "active": true,
    },
  ];
  String searchQuery = "";
  String filter = "All"; // All, Active, Inactive
  void _showServiceDialog({Map<String, dynamic>? service, int? index}) {
    final nameController = TextEditingController(text: service?['name'] ?? "");
    final descController = TextEditingController(
      text: service?['description'] ?? "",
    );
    final priceController = TextEditingController(
      text: service?['price']?.toString() ?? "",
    );
    final providerController = TextEditingController(
      text: service?['provider'] ?? "",
    );
    bool active = service?['active'] ?? true;
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
                  service == null ? "Add Service" : "Edit Service",
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
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        descController.text.isEmpty)
                      return;
                    final newService = {
                      "name": nameController.text,
                      "description": descController.text,
                      "price": int.tryParse(priceController.text) ?? 0,
                      "provider": providerController.text,
                      "active": active,
                    };
                    setState(() {
                      if (service == null) {
                        services.add(newService);
                      } else {
                        services[index!] = newService;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    service == null ? "Add" : "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text(
          "Are you sure you want to delete ${services[index]['name']}?",
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

  List<Map<String, dynamic>> get filteredServices {
    return services.where((s) {
      final matchesSearch = s['name'].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesFilter =
          filter == "All" ||
          (filter == "Active" && s['active'] == true) ||
          (filter == "Inactive" && s['active'] == false);
      return matchesSearch && matchesFilter;
    }).toList();
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
            itemBuilder: (context) => [
              const PopupMenuItem(value: "All", child: Text("All")),
              const PopupMenuItem(value: "Active", child: Text("Active")),
              const PopupMenuItem(value: "Inactive", child: Text("Inactive")),
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
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00457C)),
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
              child: ListView.builder(
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  final service = filteredServices[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.2),
                        child: Icon(Icons.build, color: primaryColor),
                      ),
                      title: Text(
                        service['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service['description']),
                          Text("Price: \$${service['price']}"),
                          Text("Provider: ${service['provider']}"),
                          Text(
                            "Status: ${service['active'] ? 'Active' : 'Inactive'}",
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: primaryColor),
                            onPressed: () => _showServiceDialog(
                              service: service,
                              index: index,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(index),
                          ),
                        ],
                      ),
                    ),
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

//-------manage post------//
class ManagePostsScreen extends StatefulWidget {
  const ManagePostsScreen({Key? key}) : super(key: key);
  @override
  State<ManagePostsScreen> createState() => _ManagePostsScreenState();
}

class _ManagePostsScreenState extends State<ManagePostsScreen> {
  final Color primaryColor = const Color(0xFF00457C);
  List<Map<String, dynamic>> posts = [
    {
      "title": "Cleaning Tips",
      "content": "Here are the top 5 tips for home cleaning...",
      "author": "Admin",
      "date": DateTime.now().subtract(const Duration(days: 1)),
      "status": "Published",
    },
    {
      "title": "Discount Announcement",
      "content": "We are offering 20% discount this week!",
      "author": "Admin",
      "date": DateTime.now().subtract(const Duration(days: 2)),
      "status": "Hidden",
    },
  ];
  String searchQuery = "";
  String filter = "All";
  List<Map<String, dynamic>> get filteredPosts {
    return posts.where((post) {
      final matchesSearch =
          post["title"].toLowerCase().contains(searchQuery.toLowerCase()) ||
          post["content"].toLowerCase().contains(searchQuery.toLowerCase());

      final matchesFilter = filter == "All" || post["status"] == filter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _showPostDialog({Map<String, dynamic>? post, int? index}) {
    final titleController = TextEditingController(text: post?["title"] ?? "");
    final contentController = TextEditingController(
      text: post?["content"] ?? "",
    );
    final authorController = TextEditingController(
      text: post?["author"] ?? "Admin",
    );
    String status = post?["status"] ?? "Published";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(post == null ? "Add Post" : "Edit Post"),
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
                    .map(
                      (s) =>
                          DropdownMenuItem(value: s, child: Text(s.toString())),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
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
            onPressed: () {
              if (titleController.text.isEmpty ||
                  contentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Title and Content cannot be empty"),
                  ),
                );
                return;
              }
              final newPost = {
                "title": titleController.text,
                "content": contentController.text,
                "author": authorController.text,
                "date": DateTime.now(),
                "status": status,
              };
              setState(() {
                if (post == null) {
                  posts.add(newPost);
                } else {
                  posts[index!] = newPost;
                }
              });
              Navigator.pop(context);
            },
            child: Text(
              post == null ? "Add" : "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
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
            onPressed: () {
              setState(() {
                posts.removeAt(index);
              });
              Navigator.pop(context);
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
            onSelected: (value) {
              setState(() {
                filter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "All", child: Text("All")),
              const PopupMenuItem(value: "Published", child: Text("Published")),
              const PopupMenuItem(value: "Hidden", child: Text("Hidden")),
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
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
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
                          post["title"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          post["content"],
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
                                  onPressed: () =>
                                      _showPostDialog(post: post, index: index),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _confirmDelete(index),
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
    const primaryColor = Color(0xFFB68645);
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
              post["title"],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("By: ${post["author"]}"),
            Text("Date: ${post["date"].toString().split(" ")[0]}"),
            Text("Status: ${post["status"]}"),
            const Divider(height: 20, thickness: 1),
            Text(post["content"], style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
