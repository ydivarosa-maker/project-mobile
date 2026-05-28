import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream untuk memantau perubahan status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Ambil user saat ini
  User? get currentUser => _auth.currentUser;

  // ─────────────────────────────────────────────
  // Login dengan Email & Password
  // ─────────────────────────────────────────────
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan saat login: ${e.toString()}';
    }
  }

  // Register akun baru
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan saat mendaftar: ${e.toString()}';
    }
  }

  // ─────────────────────────────────────────────
  // Login dengan Google
  // ─────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Buka dialog pilih akun Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User membatalkan proses
      if (googleUser == null) return null;

      // Ambil token autentikasi
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Buat kredensial Firebase dari token Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase dengan kredensial Google
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Gagal masuk dengan Google: ${e.toString()}';
    }
  }

  // Logout dari Google dan Firebase sekaligus
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────
  // Login dengan Nomor Telepon (OTP)
  // ─────────────────────────────────────────────

  /// Kirim kode OTP ke nomor telepon.
  /// [phoneNumber] harus dalam format E.164, contoh: +6281234567890
  /// [onCodeSent] dipanggil dengan verificationId saat OTP berhasil dikirim
  /// [onError] dipanggil jika terjadi error
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto-retrieved on Android (SMS auto-fill)
        onAutoVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(_handleAuthException(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Timeout, tidak perlu aksi khusus
      },
    );
  }

  /// Verifikasi kode OTP yang dimasukkan pengguna.
  Future<UserCredential?> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Gagal verifikasi OTP: ${e.toString()}';
    }
  }

  // ─────────────────────────────────────────────
  // Login sebagai Tamu (Anonymous)
  // ─────────────────────────────────────────────
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan saat masuk sebagai tamu: ${e.toString()}';
    }
  }

  // ─────────────────────────────────────────────
  // Reset Password
  // ─────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan saat mengirim email reset: ${e.toString()}';
    }
  }

  // ─────────────────────────────────────────────
  // Logout
  // ─────────────────────────────────────────────
  Future<void> signOut() async {
    // Pastikan juga logout dari Google jika menggunakannya
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────
  // Handle Error Firebase Auth → Pesan Bahasa Indonesia
  // ─────────────────────────────────────────────
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email sudah digunakan oleh akun lain.';
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      case 'invalid-credential':
        return 'Email atau password tidak valid.';
      case 'account-exists-with-different-credential':
        return 'Akun sudah terdaftar dengan metode login berbeda.';
      case 'invalid-verification-code':
        return 'Kode OTP tidak valid. Periksa kembali kode yang Anda masukkan.';
      case 'invalid-verification-id':
        return 'Sesi verifikasi tidak valid. Silakan minta kode baru.';
      case 'session-expired':
        return 'Sesi OTP telah kedaluwarsa. Silakan minta kode baru.';
      case 'quota-exceeded':
        return 'Batas pengiriman SMS telah tercapai. Coba lagi besok.';
      case 'missing-phone-number':
        return 'Nomor telepon tidak boleh kosong.';
      case 'invalid-phone-number':
        return 'Format nomor telepon tidak valid.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
