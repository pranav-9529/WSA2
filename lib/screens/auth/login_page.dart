import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wsa2/Theme/colors.dart';
// import 'package:safecircle/Theme/colors.dart';
import '../../service/api_service.dart';
import '../home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  bool _obscurePassword = true;

  loginUser() async {
    setState(() => loading = true);

    final res = await ApiService.login(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    setState(() => loading = false);

    if (res["status"] == 200) {
      var data = res["data"];
      String token = data['token'];
      String userID = data['userID'];

      await ApiService.saveToken(token);
      await ApiService.saveUserID(userID);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Login", style: AppTextStyles.heading),
            SizedBox(height: 20),
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
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email or Phone",
                    icon: Icon(
                      Icons.attach_email_rounded,
                      color: AppColors.primary,
                    ),
                    labelStyle: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
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
                  obscureText: _obscurePassword,
                  style: AppTextStyles.body2,
                  cursorColor: const Color.fromARGB(135, 0, 0, 0),
                  controller: password,
                  decoration: InputDecoration(
                    labelText: "Password",
                    icon: Icon(Icons.password_sharp, color: AppColors.primary),
                    labelStyle: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 5),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: loading ? null : loginUser,
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
                        child: Text("Login", style: AppTextStyles.button1),
                      ),
                    ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  height: height * 0.001,
                  width: width * 0.40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(width: width * 0.01),
                Text("OR", style: AppTextStyles.body1),
                SizedBox(width: width * 0.01),
                Container(
                  height: height * 0.001,
                  width: width * 0.40,
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
                    Text("Login with Google", style: AppTextStyles.body1),
                  ],
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account ?", style: AppTextStyles.body2),
                TextButton(
                  child: Text(
                    "Create account",
                    style: GoogleFonts.roboto(color: AppColors.primary),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignupPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
