import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wsa2/Theme/colors.dart';
import 'package:wsa2/screens/auth/login_page.dart';
// import 'package:wsa2/home_page.dart';
import 'package:wsa2/screens/home_page.dart';
// import 'package:safecircle/Theme/colors.dart';
// import 'package:safecircle/screens/home_page.dart';
import '../../service/api_service.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final fnameCtrl = TextEditingController();
  final lnameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;

  signupUser() async {
    final fname = fnameCtrl.text.trim();
    final lname = lnameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (fname.isEmpty ||
        lname.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => loading = true);

    try {
      final res = await ApiService.signup(
        fname: fname,
        lname: lname,
        email: email,
        phone: phone,
        password: password,
      );

      setState(() => loading = false);

      // ---------------------------
      // ⭐ SIGNUP SUCCESS? THEN LOGIN
      // ---------------------------
      if (res["status"] == 200 || res["status"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful, logging in...")),
        );

        // Now login to get token + userID
        final loginRes = await ApiService.login(
          email: email,
          password: password,
        );

        if (loginRes["status"] == 200) {
          final data = loginRes["data"];
          final token = data["token"];
          final userID = data["userID"];

          if (token != null && userID != null) {
            await ApiService.saveToken(token);
            await ApiService.saveUserID(userID);
          }

          if (!mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Signup done but login failed")),
          );
        }
      } else {
        String msg = res["data"]["message"] ?? "Signup failed";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      //appBar: AppBar(title: const Text("Signup")),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 450,
              width: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/Head.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 50),
            Positioned(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 190,
                  right: 20,
                  //bottom: 30,
                ),
                child: Container(
                  height: 580,
                  width: 400,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        buildInputContainer(
                          controller: fnameCtrl,
                          label: "First Name",
                          icon: Icons.person,
                        ),
                        SizedBox(height: 15),

                        buildInputContainer(
                          controller: lnameCtrl,
                          label: "Last Name",
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: 15),

                        buildInputContainer(
                          controller: emailCtrl,
                          label: "Email",
                          icon: Icons.email,
                          keyboard: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 15),

                        buildInputContainer(
                          controller: phoneCtrl,
                          label: "Phone",
                          icon: Icons.phone,
                          keyboard: TextInputType.phone,
                        ),
                        SizedBox(height: 15),

                        buildInputContainer(
                          controller: passwordCtrl,
                          label: "Password",
                          icon: Icons.lock,
                          obscure: true,
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: loading ? null : signupUser,
                          child: loading
                              ? CircularProgressIndicator(
                                  color: AppColors.loder,
                                  strokeWidth: 4,
                                  strokeCap: StrokeCap.round,
                                )
                              : Container(
                                  height: 50,
                                  width: 349,

                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Signup",
                                      style: AppTextStyles.button1,
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              height: height * 0.001,
                              width: width * 0.32,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            SizedBox(width: width * 0.05),
                            Text("OR", style: AppTextStyles.body1),
                            SizedBox(width: width * 0.05),
                            Container(
                              height: height * 0.001,
                              width: width * 0.32,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          child: Container(
                            height: 50,
                            width: 349,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        "https://media.licdn.com/dms/image/v2/D4E0BAQGv3cqOuUMY7g/company-logo_200_200/B4EZmhegXHGcAM-/0/1759350753990/google_logo?e=2147483647&v=beta&t=Hzaw0d0Yz1Yi-_mDuQ6JQo-Ph41AG50Z8pWjyaeTI0k",
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Login with Google",
                                  style: AppTextStyles.body1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: Colors.black87),
                              children: [
                                TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

Widget buildInputContainer({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscure = false,
  TextInputType keyboard = TextInputType.text,
}) {
  return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        style: AppTextStyles.body1,
        cursorColor: const Color.fromARGB(135, 0, 0, 0),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.primary),
          labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
          labelText: label,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 5),
        ),
      ),
    ),
  );
}
