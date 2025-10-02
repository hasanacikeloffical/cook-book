import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  /// Oturum değişimlerini dinlemek için (AuthGate kullanırsan işine yarar)
  Stream<User?> authState() => _auth.authStateChanges();

  /// E-posta/Şifre ile kayıt
  Future<User?> signUpWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// E-posta/Şifre ile giriş
  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Google ile giriş (Web vs Mobil ayrımı)
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: popup ile giriş
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        final cred = await _auth.signInWithPopup(provider);
        return cred.user;
      } else {
        // Mobil: önce eski hesap oturumunu kapatmak iyi bir pratik
        try {
          await _google.signOut();
        } catch (_) {}

        final gUser = await _google.signIn(); // Google hesabı seçtirir
        if (gUser == null) return null; // kullanıcı iptal etti

        final gAuth = await gUser.authentication; // token'ları al
        final credential = GoogleAuthProvider.credential(
          idToken: gAuth.idToken, // idToken çoğu zaman yeter
          accessToken: gAuth.accessToken, // null olabilir, sorun değil
        );
        final cred = await _auth.signInWithCredential(
          credential,
        ); // Firebase'e giriş
        return cred.user;
      }
    } on FirebaseAuthException {
      rethrow; // UI tarafında yakalayıp SnackBar gösteriyorsun
    } catch (_) {
      rethrow;
    }
  }

  /// Şifre sıfırlama (AuthPage'e buton eklemek istersen hazır)
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// Çıkış
  Future<void> signOut() async {
    if (kIsWeb) {
      await _auth.signOut();
    } else {
      try {
        await _google.signOut();
      } catch (_) {}
      await _auth.signOut();
    }
  }

  /// (İstersen) hesabı sil
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
