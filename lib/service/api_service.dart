import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://wsa-1.onrender.com/api/auth";

  // ---------------------- SAVE USERID ----------------------
  static Future<void> saveUserID(String userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userID", userID);
  }

  // ---------------------- SAVE TOKEN ----------------------
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // ---------------------- GET TOKEN ----------------------
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ---------------------- LOGIN ----------------------
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveToken(data["token"]);
    }

    return {"status": response.statusCode, "data": data};
  }

  //

  // -------- SIGNUP --------
  static Future<Map<String, dynamic>> signup({
    required String fname,
    required String lname,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/signup");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fname": fname,
        "lname": lname,
        "email": email,
        "phone": phone,
        "password": password,
      }),
    );

    print("SIGNUP RAW RESPONSE => ${res.body}");

    final data = jsonDecode(res.body);

    // ⭐ IMPORTANT FIXES ⭐
    // backend may return 200 or 201
    int status = res.statusCode;

    // backend may send token directly or inside data
    String? token = data["token"] ?? data["data"]?["token"];
    String? userID = data["userID"] ?? data["data"]?["userID"];

    return {"status": status, "data": data, "token": token, "userID": userID};
  }

  // -------- SAVE TOKEN & USERID --------
  static Future<void> saveToken1(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<void> saveUserID1(String userID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userID", userID);
  }

  // -------- GET TOKEN & USERID --------
  static Future<String?> getToken1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<String?> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userID");
  }
}

// ==============================================================
// ⭐⭐ NEW CODE ADDED BELOW — Folder + Contact API (NO CHANGES ABOVE)
// ==============================================================

class ApiService2 {
  static const String baseUrl = "https://wsa-1.onrender.com/api";

  // ---------------------- SAVE TOKEN ----------------------
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // ---------------------- GET TOKEN ----------------------
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ---------------------- ADD FOLDER ----------------------
  static Future<Map<String, dynamic>> addFolder({
    required String userID,
    required String folderName,
  }) async {
    final url = Uri.parse("$baseUrl/folder/create/$userID");

    final body = {"foldername": folderName};

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("Create Folder Status: ${res.statusCode} | Body: ${res.body}");

    return jsonDecode(res.body);
  }

  // ---------------------- GET ALL FOLDERS ----------------------
  static Future<Map<String, dynamic>> getFolders(String userID) async {
    final token = await getToken() ?? "";

    final response = await http.get(
      Uri.parse("$baseUrl/folder/$userID"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _processResponse(response);
  }

  // ---------------------- DELETE FOLDER ----------------------
  static Future<Map<String, dynamic>> deleteFolder({
    required String folderID,
    required String userID,
  }) async {
    final url = Uri.parse("$baseUrl/folder/delete/$folderID/$userID");

    final res = await http.delete(url);

    print("Delete Folder Status: ${res.statusCode} | ${res.body}");

    return jsonDecode(res.body);
  }

  // ---------------------- ADD CONTACT ----------------------
  static Future<Map<String, dynamic>> addContact({
    required String folderID,
    required String name,
    required String phone,
    required String userID,
  }) async {
    final token = await getToken() ?? "";

    final response = await http.post(
      Uri.parse("$baseUrl/contact/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "folderID": folderID,
        "c_name": name, // backend expects c_name
        "c_phone": phone, // backend expects c_phone
        "userID": userID,
      }),
    );

    return _processResponse(response);
  }

  // ---------------------- GET CONTACTS BY FOLDER ----------------------
  static Future<Map<String, dynamic>> getContacts({
    required String folderID,
    required String userID,
  }) async {
    final token = await getToken() ?? "";

    final response = await http.get(
      Uri.parse("$baseUrl/contact/$folderID/$userID"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _processResponse(response);
  }

  // ---------------- DELETE MULTIPLE CONTACTS ----------------
  static Future<Map<String, dynamic>> deleteMultipleContacts({
    required String userID,
    required String folderID,
    required List<String> contactIDs,
  }) async {
    final url = Uri.parse("$baseUrl/contact/delete-multiple/$userID/$folderID");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"contactIDs": contactIDs}),
    );

    print("Delete multiple contacts: ${res.statusCode} | ${res.body}");

    return jsonDecode(res.body);
  }

  // ---------------------- HELPER: PROCESS RESPONSE ----------------------
  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Error ${response.statusCode}: ${response.reasonPhrase}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Invalid response: $e"};
    }
  }
}
