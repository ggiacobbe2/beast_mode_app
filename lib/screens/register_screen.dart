import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import 'home_feed_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isLoading = false;

  void register() async {
    setState(() => isLoading = true);

    String? result = await AuthService().register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (result == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeFeedScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Register", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: register,
                    child: const Text("Register"),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: const Text("Already have an account? Login"),
            )
          ],
        ),
      ),
    );
  }
}