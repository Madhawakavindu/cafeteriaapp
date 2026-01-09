import 'package:flutter/material.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:cafeteria/features/auth/presentation/canteen_selection/presentation/canteen_select_screen.dart';

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
    if (_emailController.text.isEmpty || _passController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // TODO: Implement authentication logic
      // For now, just navigate to canteen selection
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CanteenSelectScreen()),
        );
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    if (mounted) {
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
}
