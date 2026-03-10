import 'package:flutter/material.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:cafeteria/features/auth/presentation/screens/home_page.dart';
import 'package:cafeteria/features/admin/presentation/screens/admin_dashboard_screen.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  const AuthForm({required this.isLogin, super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      showSnackBar(context, 'Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);
    // Backend login removed
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      // Default navigation to home page
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Email'),
          controller: _emailController,
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(labelText: 'Password'),
          controller: _passController,
          obscureText: true,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Demo Admin: admin@cafeteria.com / admin123',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 30),
        _isLoading
            ? const CircularProgressIndicator()
            : CustomButton(
                text: widget.isLogin ? 'Login' : 'Register',
                onPressed: _submit,
              ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }
}
