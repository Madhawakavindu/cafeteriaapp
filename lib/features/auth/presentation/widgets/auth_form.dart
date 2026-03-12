import 'package:flutter/material.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/custom_button.dart';
import 'package:cafeteria/features/auth/presentation/canteen_selection/presentation/canteen_select_screen.dart';
import 'package:cafeteria/features/auth/presentation/screens/home_page.dart';
import 'package:cafeteria/features/auth/presentation/screens/owner_dashboard_screen.dart';
import 'package:cafeteria/features/auth/core/services/auth_service.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  const AuthForm({required this.isLogin, super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _submit() async {
    final isRegister = !widget.isLogin;
    if (_emailController.text.isEmpty ||
        _passController.text.isEmpty ||
        (isRegister && _nameController.text.isEmpty)) {
      showSnackBar(context, 'Please fill all fields');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (widget.isLogin) {
        await _authService.login(
          _emailController.text.trim(),
          _passController.text,
        );
      } else {
        await _authService.register(
          _emailController.text.trim(),
          _passController.text,
          _nameController.text.trim(),
          role: 'user',
        );
      }

      if (mounted) {
        if (!widget.isLogin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CanteenSelectScreen()),
          );
        } else if (_authService.isOwner) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceFirst('Exception: ', '');
        showSnackBar(context, message);
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.isLogin)
          TextField(
            decoration: const InputDecoration(labelText: 'Name'),
            controller: _nameController,
          ),
        if (!widget.isLogin) const SizedBox(height: 12),
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }
}
