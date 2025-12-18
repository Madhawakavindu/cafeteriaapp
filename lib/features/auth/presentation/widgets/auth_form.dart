import 'package:flutter/material.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../services/firebase_auth_service.dart';
import '../../../../services/firestore_service.dart';
import '.././canteen_selection/presentation/canteen_select_screen.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  const AuthForm({required this.isLogin, super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _authService = FirebaseAuthService();
  final _firestore = FirestoreService();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (widget.isLogin) {
        await _authService.signIn(_emailController.text, _passController.text);
      } else {
        final user = await _authService.register(
          _emailController.text,
          _passController.text,
        );
        await _firestore.users.doc(user!.uid).set({
          'email': _emailController.text,
          'role': 'student',
        });
      }

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
