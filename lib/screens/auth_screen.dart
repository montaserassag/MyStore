import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/auth_service.dart';

enum _Mode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  _Mode _mode        = _Mode.signIn;
  bool  _submitting  = false;
  bool  _obscure     = true;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _submitting = true; _error = null; });
    try {
      _mode == _Mode.signIn
          ? await AuthService.signIn(email: _emailCtrl.text, password: _passCtrl.text)
          : await AuthService.signUp(email: _emailCtrl.text, password: _passCtrl.text);
      // StreamBuilder in main.dart navigates automatically on success.
    } on AuthException catch (e) {
      if (!mounted) return;   
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignIn = _mode == _Mode.signIn;
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(key: _formKey, child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: kGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.storefront_rounded, size: 34, color: kGold),
                  )),
                  const SizedBox(height: 16),
                  const Center(child: Text('MyStore',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white))),
                  const SizedBox(height: 4),
                  Center(child: Text(
                    isSignIn ? 'Sign in to continue' : 'Create a new account',
                    style: const TextStyle(fontSize: 13, color: kTextSecond))),
                  const SizedBox(height: 28),

                  // Mode tabs
                  Container(
                    decoration: BoxDecoration(color: kCardColor,
                      borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorderColor)),
                    padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      _Tab(label: 'Sign In',  active: isSignIn, onTap: () => setState(() { _mode = _Mode.signIn;  _error = null; })),
                      _Tab(label: 'Sign Up', active: !isSignIn, onTap: () => setState(() { _mode = _Mode.signUp; _error = null; })),
                    ]),
                  ),
                  const SizedBox(height: 22),

                  // Email
                  const _Label('Email'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec(hint: 'you@example.com', icon: Icons.email_outlined),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Email is required';
                      if (!s.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  const _Label('Password'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec(
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: kTextSecond, size: 18),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'At least 6 characters required';
                      return null;
                    },
                  ),

                  // Error
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: kRed.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kRed.withValues(alpha: 0.4)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded, size: 16, color: kRed),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(fontSize: 12, color: kRed))),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Submit
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGold, foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    child: _submitting
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : Text(isSignIn ? 'Sign In' : 'Create Account'),
                  ),
                ],
              )),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec({required String hint, required IconData icon, Widget? suffix}) =>
      InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: kTextSecond, fontSize: 13),
        prefixIcon: Icon(icon, color: kTextSecond, size: 18),
        suffixIcon: suffix,
        filled: true, fillColor: kCardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border:             OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
        enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorderColor)),
        focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kAccent)),
        errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kRed)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kRed)),
      );
}

class _Tab extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: active ? kGold : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w800,
        color: active ? Colors.black : kTextSecond)),
    ),
  ));
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kTextSecond));
}
