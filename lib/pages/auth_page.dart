import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  final _form  = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _busy = false;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onSubmit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_isLogin) {
        await _auth.signInWithEmail(_email.text.trim(), _pass.text.trim());
      } else {
        await _auth.signUpWithEmail(_email.text.trim(), _pass.text.trim());
      }
      // Giriş/Kayıt başarılı → AuthGate yönlendirecek.
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Bir hata oluştu');
    } catch (e) {
      _showSnack('Hata: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() => _busy = true);
    try {
      await _auth.signInWithGoogle();
      // Başarılıysa AuthGate yönlendirecek.
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Google giriş hatası');
    } catch (e) {
      _showSnack('Google hata: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? 'Giriş Yap' : 'Kayıt Ol';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView( // klavye taşmasını önler
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username, AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'E-posta gir';
                          if (!v.contains('@')) return 'Geçerli e-posta gir';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pass,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _onSubmit(),
                        decoration: const InputDecoration(
                          labelText: 'Şifre',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 6) return 'En az 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _onSubmit,
                          icon: _busy
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.lock_open),
                          label: Text(title),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(_isLogin
                            ? 'Hesabın yok mu? Kayıt ol'
                            : 'Hesabın var mı? Giriş yap'),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('veya'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _signInGoogle,
                          icon: const Icon(Icons.account_circle),
                          label: const Text('Google ile devam et'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}  