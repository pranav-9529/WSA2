import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsa2/Theme/colors.dart';
import 'package:wsa2/screens/folder%20and%20contacts/contact.dart';
import 'package:wsa2/screens/main_bottom_nav.dart';
import '../../service/api_service.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<dynamic> folders = [];
  bool isLoading = true;

  final TextEditingController folderController = TextEditingController();

  String? userID;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ---------------------- LOAD USER ID ----------------------
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID");

    print("Loaded User ID: $userID");

    if (userID == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("UserID missing. Please login again.")),
      );
      return;
    }

    _fetchFolders();
  }

  // ---------------------- FETCH USER FOLDERS ----------------------
  Future<void> _fetchFolders() async {
    setState(() => isLoading = true);

    try {
      final res = await ApiService2.getFolders(userID!);

      print("Folders API Response: $res");

      final List data = res["folders"] ?? [];

      setState(() {
        folders = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching folders: $e")));
    }
  }

  // ---------------------- CREATE FOLDER ----------------------
  Future<void> _createFolder() async {
    final name = folderController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter folder name")));
      return;
    }

    if (userID == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID missing")));
      return;
    }

    try {
      final res = await ApiService2.addFolder(
        userID: userID!,
        folderName: name,
      );

      print("Create Folder Response: $res");

      if (res["success"] == true) {
        folderController.clear();
        _fetchFolders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Failed to create folder")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: $e")));
    }
  }

  // ---------------------- DELETE FOLDER ----------------------
  Future<void> _deleteFolder(String folderID) async {
    try {
      final res = await ApiService2.deleteFolder(
        folderID: folderID,
        userID: userID!,
      );

      if (res["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Folder deleted successfully")),
        );
        _fetchFolders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Failed to delete folder")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ---------------------- CONFIRM DELETE DIALOG ----------------------
  void _confirmDelete(String folderID) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Folder?", style: AppTextStyles.subHeading),
          content: Text(
            "This will remove the folder and all contacts inside it.",
            style: AppTextStyles.body1,
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: AppTextStyles.button2),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Delete", style: AppTextStyles.redbutton),
              onPressed: () {
                Navigator.pop(context);
                _deleteFolder(folderID);
              },
            ),
          ],
        );
      },
    );
  }

  // ---------------------- OPEN FOLDER ----------------------
  void _openFolder(Map folder) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactScreen(folder: folder)),
    ).then((_) => _fetchFolders());
  }

  //------------------------- create folder dialog box ---------
  void _showCreateFolderPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Create New Folder", style: AppTextStyles.subHeading),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    controller: folderController,
                    decoration: InputDecoration(
                      labelText: "Enter folder name",
                      icon: Icon(Icons.folder, color: const Color(0xFFC2144E)),
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
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      folderController.clear();
                    },
                    child: Text("Cancel", style: AppTextStyles.button2),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      final name = folderController.text.trim();
                      if (name.isEmpty) return;

                      _createFolder();
                      Navigator.pop(context);
                      folderController.clear();
                    },
                    child: Text("Add", style: AppTextStyles.redbutton),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  //----------folder icon ---------------------------
  Widget folderIcon() {
    return Container(
      height: 90,
      width: 85,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
          Center(child: Icon(Icons.person, size: 40, color: AppColors.primary)),
        ],
      ),
    );
  }

  // ---------------------- UI ----------------------
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text("My Circle", style: AppTextStyles.heading)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showCreateFolderPopup(),
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
                    "Create new circle + ",
                    style: AppTextStyles.body1,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: height * 0.001,
              width: width * 20,
              decoration: BoxDecoration(color: AppColors.primary),
            ),
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.loder,
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                      ),
                    )
                  : folders.isEmpty
                  ? const Center(child: Text("No folders found"))
                  : GridView.builder(
                      itemCount: folders.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 25,
                        mainAxisSpacing: 25,
                        childAspectRatio: 0.90,
                      ),
                      itemBuilder: (context, index) {
                        final f = folders[index];

                        final folder = {
                          "id": f["_id"] ?? f["id"],
                          "folderName":
                              f["folderName"] ?? f["foldername"] ?? "Unnamed",
                        };

                        return GestureDetector(
                          onTap: () => _openFolder(folder),
                          onLongPress: () => _confirmDelete(folder["id"]),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                folderIcon(),
                                SizedBox(height: 10),
                                Text(
                                  folder["folderName"],
                                  style: AppTextStyles.cardtext1,
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

//-------- folder structure -------
class FolderCard extends StatelessWidget {
  final String title;

  const FolderCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.black12, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.pink.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person, size: 35, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
