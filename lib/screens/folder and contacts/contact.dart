// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:safecircle/Theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsa2/Theme/colors.dart';
import 'package:wsa2/screens/main_bottom_nav.dart';
import '../../service/api_service.dart';

class ContactScreen extends StatefulWidget {
  final Map folder;
  const ContactScreen({super.key, required this.folder});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<dynamic> contacts = [];
  bool isLoading = true;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  String? userID;

  // Track selected contacts
  List<String> selectedContacts = [];
  bool selectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ---------------------- LOAD USER ID ----------------------
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID");

    if (userID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found. Please login again.")),
      );
      setState(() => isLoading = false);
      return;
    }

    _fetchContacts();
  }

  // ---------------------- FETCH CONTACTS ----------------------
  Future<void> _fetchContacts() async {
    if (userID == null) return;

    setState(() => isLoading = true);

    try {
      final res = await ApiService2.getContacts(
        folderID: widget.folder["id"],
        userID: userID!,
      );

      setState(() {
        contacts = res["contacts"] ?? [];
        selectedContacts.clear();
        selectionMode = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading contacts: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------------- ADD CONTACT ----------------------
  Future<void> _addContact() async {
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid name & phone")));
      return;
    }

    try {
      final res = await ApiService2.addContact(
        folderID: widget.folder["id"],
        name: name,
        phone: phone,
        userID: userID!,
      );

      if (res["success"] == true) {
        nameCtrl.clear();
        phoneCtrl.clear();
        _fetchContacts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Failed to add contact")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: $e")));
    }
  }

  // ---------------------- DELETE MULTIPLE CONTACTS ----------------------
  Future<void> _deleteSelectedContacts() async {
    if (selectedContacts.isEmpty) return;

    try {
      final res = await ApiService2.deleteMultipleContacts(
        userID: userID!,
        folderID: widget.folder["id"],
        contactIDs: selectedContacts,
      );

      if (res["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contacts deleted successfully")),
        );

        _fetchContacts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Failed to delete")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting contacts: $e")));
    }
  }

  // ---------------------- CONFIRM DELETE POPUP ----------------------
  Future<void> _confirmDeleteContacts() async {
    if (selectedContacts.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Contacts"),
        content: Text(
          "Are you sure you want to delete ${selectedContacts.length} selected contacts?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 250, 217, 214),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteSelectedContacts(); // call delete only if user confirmed
    }
  }

  //------------------------- create folder dialog box ---------
  void _showCreatecontactPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Create New Contact", style: AppTextStyles.subHeading),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(child: Container()),
              Container(
                height: 50,
                width: 349,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: AppTextStyles.body1,
                    cursorColor: const Color.fromARGB(135, 0, 0, 0),
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: "Name",
                      icon: Icon(Icons.person, color: AppColors.primary),
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(138, 0, 0, 0),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 50,
                width: 349,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: AppTextStyles.body2,
                    cursorColor: const Color.fromARGB(135, 0, 0, 0),
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone no.",
                      icon: Icon(Icons.call, color: AppColors.primary),
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(138, 0, 0, 0),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _addContact();
                  Navigator.pop(context);
                },

                child: Text("Add Contact", style: AppTextStyles.redbutton),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------- UI ----------------------
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.folder["folderName"], style: AppTextStyles.heading),
        actions: [
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDeleteContacts,
            ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showCreatecontactPopup(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 44,
                  width: 361,
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Create new contact + ",
                      style: AppTextStyles.body1,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: height * 0.001,
              width: width * 20,
              decoration: BoxDecoration(color: AppColors.primary),
            ),
            SizedBox(height: 20),
            // -------- Contact List --------
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.loder,
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                      ),
                    )
                  : contacts.isEmpty
                  ? const Center(child: Text("No contacts found"))
                  : ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final c = contacts[index];

                        // Normalize ID
                        final rawId = c["_id"] ?? c["id"];
                        final id = rawId?.toString() ?? "";
                        if (id.isEmpty) return const SizedBox.shrink();

                        final isSelected = selectedContacts.contains(id);

                        SizedBox(height: 20);
                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              selectionMode = true;
                              selectedContacts.add(id);
                            });
                          },
                          onTap: () {
                            if (selectionMode) {
                              setState(() {
                                if (isSelected) {
                                  selectedContacts.remove(id);
                                  if (selectedContacts.isEmpty) {
                                    selectionMode = false;
                                  }
                                } else {
                                  selectedContacts.add(id);
                                }
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: height * 0.08,
                              width: width * 0.12,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    selectionMode
                                        ? Checkbox(
                                            value: isSelected,
                                            onChanged: (val) {
                                              setState(() {
                                                if (val == true) {
                                                  selectedContacts.add(id);
                                                } else {
                                                  selectedContacts.remove(id);
                                                }
                                                if (selectedContacts.isEmpty) {
                                                  selectionMode = false;
                                                }
                                              });
                                            },
                                          )
                                        : Container(
                                            height: height * 0.05,
                                            width: width * 0.11,
                                            decoration: BoxDecoration(
                                              color: AppColors.button,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: Icon(
                                              Icons.person_rounded,
                                              size: 30,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c["name"] ?? c["c_name"] ?? "Unnamed",
                                          style: AppTextStyles.cardtext1,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "+91 ",
                                              style: AppTextStyles.cardtext2,
                                            ),
                                            Text(
                                              c["phone"] ??
                                                  c["c_phone"] ??
                                                  "No number",
                                              style: AppTextStyles.cardtext2,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
