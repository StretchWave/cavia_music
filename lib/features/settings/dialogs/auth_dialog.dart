import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../app/theme/cavia_typography.dart';
import '../../../app/theme/cavia_glass.dart';
import '../../../core/components/glass_container.dart';
import '../../../core/components/toast.dart';
import '../../../core/state/settings_controller.dart';

class AuthDialog extends StatefulWidget {
  final SettingsController settings;

  const AuthDialog({super.key, required this.settings});

  static Future<void> show(BuildContext context, SettingsController settings) {
    return showDialog(
      context: context,
      barrierColor: CaviaColors.scrim,
      builder: (ctx) => AuthDialog(settings: settings),
    );
  }

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  bool _isSignUp = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_isSignUp) {
      final name = _nameController.text.trim();
      final res = await widget.settings.signUp(
        email,
        password,
        displayName: name.isNotEmpty ? name : null,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        if (res.isSuccess) {
          Navigator.pop(context);
          CaviaToast.show(context, 'Account created • Library synced');
        } else {
          setState(() => _errorMessage = res.errorOrNull?.userMessage ?? 'Account creation failed');
        }
      }
    } else {
      final res = await widget.settings.signIn(email, password);
      if (mounted) {
        setState(() => _isLoading = false);
        if (res.isSuccess) {
          Navigator.pop(context);
          CaviaToast.show(context, 'Signed in • Library synced');
        } else {
          setState(() => _errorMessage = res.errorOrNull?.userMessage ?? 'Invalid email or password');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassContainer(
          radius: CaviaGlass.radiusCard,
          blur: CaviaGlass.blurHeavy,
          surfaceColor: CaviaColors.overlaySheet,
          padding: const EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // Header & Mode Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isSignUp ? 'Create Account' : 'Sign In',
                      style: CaviaTypography.display.copyWith(fontSize: 20),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isSignUp = !_isSignUp;
                                _errorMessage = null;
                              });
                            },
                      child: Text(
                        _isSignUp ? 'Have account? Sign in' : 'New here? Sign up',
                        style: const TextStyle(
                          color: CaviaColors.vermilionBright,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Error Banner
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: CaviaColors.vermilion.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CaviaColors.vermilionBright.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: CaviaColors.vermilionBright, fontSize: 12),
                    ),
                  ),

                // Display Name (if sign up)
                if (_isSignUp) ...[
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: CaviaColors.textIvory),
                    decoration: InputDecoration(
                      labelText: 'Display Name (optional)',
                      labelStyle: const TextStyle(color: CaviaColors.textSilver),
                      filled: true,
                      fillColor: CaviaColors.glassSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: CaviaColors.glassBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: CaviaColors.textIvory),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: CaviaColors.textSilver),
                    filled: true,
                    fillColor: CaviaColors.glassSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CaviaColors.glassBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: CaviaColors.textIvory),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: CaviaColors.textSilver),
                    filled: true,
                    fillColor: CaviaColors.glassSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CaviaColors.glassBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: CaviaColors.textSilver)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CaviaColors.vermilion,
                        foregroundColor: CaviaColors.textIvory,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(_isSignUp ? 'Create Account' : 'Sign In'),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
