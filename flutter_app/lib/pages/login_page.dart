import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation_project/pages/signup_page.dart';
import 'package:graduation_project/providers/api_user_credentials.dart';
import 'package:graduation_project/widgets/custom_button.dart';
import 'package:graduation_project/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  bool _isSubmitting = false;

  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiProvider>(context);
    void validateForm() {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter your name or email and password.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      } else {
        // Proceed with form submission
        setState(() {
          _isSubmitting = true;
        });
        api.checkUserExists(
            context, emailController.text, passwordController.text);
      }
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 40, 0, 0),
                child: Text(
                  'Welcome back',
                  style: GoogleFonts.sora(
                      color: const Color(0xff1F5460),
                      fontSize: 32,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              CustomTextField(
                obscureText: false,
                hintText: 'enter your name or email',
                icon: Icons.person,
                controller: emailController,
              ),
              const SizedBox(
                height: 25,
              ),
              CustomTextField(
                hintText: 'enter your password',
                icon: Icons.lock,
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(
                height: 80,
              ),
              MyButton(
                color: const Color(0xff659A9D),
                text: _isSubmitting ? '' : "sign in",
                method: validateForm,
                child: _isSubmitting
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : null,
              ),
              const SizedBox(
                height: 150,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUp()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.sora(
                          fontSize: 14, color: const Color(0xff659A9D)),
                      children: const <TextSpan>[
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
