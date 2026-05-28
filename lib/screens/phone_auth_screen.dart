import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/auth_service.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen>
    with TickerProviderStateMixin {
  final AuthService _auth = AuthService();

  // Controllers
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  // State
  String _completePhoneNumber = '';
  String? _verificationId;
  int? _resendToken;
  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isVerifying = false;
  String? _errorMessage;
  int _resendCountdown = 60;
  Timer? _resendTimer;

  // Animasi
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;

  // Warna tema Melodya
  static const Color _accentColor = Color(0xFFD946EF);
  static const Color _bgStart = Color(0xFF0F172A);
  static const Color _bgMid = Color(0xFF1E1B4B);
  static const Color _bgEnd = Color(0xFF4C1D95);

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _resendTimer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Kirim OTP
  // ─────────────────────────────────────────────
  Future<void> _sendOtp({bool isResend = false}) async {
    if (_completePhoneNumber.isEmpty) {
      setState(() => _errorMessage = 'Masukkan nomor telepon terlebih dahulu.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _auth.sendPhoneOtp(
      phoneNumber: _completePhoneNumber,
      resendToken: isResend ? _resendToken : null,
      onCodeSent: (verificationId, resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isLoading = false;
            _isOtpSent = true;
          });
          _startResendTimer();
          _slideController.reset();
          _slideController.forward();
          // Fokus ke kotak OTP pertama
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _otpFocusNodes[0].requestFocus();
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        }
      },
      onAutoVerified: (PhoneAuthCredential credential) async {
        if (mounted) {
          setState(() => _isVerifying = true);
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (mounted) Navigator.of(context).pop(true);
          } catch (_) {
            if (mounted) setState(() => _isVerifying = false);
          }
        }
      },
    );
  }

  // ─────────────────────────────────────────────
  // Verifikasi OTP
  // ─────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Masukkan 6 digit kode OTP.');
      return;
    }
    if (_verificationId == null) {
      setState(() => _errorMessage = 'Sesi tidak valid. Minta kode baru.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      await _auth.verifyPhoneOtp(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = e.toString();
        });
        // Bersihkan kotak OTP
        for (final c in _otpControllers) {
          c.clear();
        }
        _otpFocusNodes[0].requestFocus();
      }
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // ─────────────────────────────────────────────
  // Handle input OTP (auto-advance focus)
  // ─────────────────────────────────────────────
  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }

    // Auto-submit jika semua terisi
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtp();
    }
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgStart, _bgMid, _bgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar Custom
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white70),
                      onPressed: () {
                        if (_isOtpSent) {
                          setState(() {
                            _isOtpSent = false;
                            _verificationId = null;
                            _errorMessage = null;
                            for (final c in _otpControllers) {
                              c.clear();
                            }
                            _resendTimer?.cancel();
                          });
                          _slideController.reset();
                          _slideController.forward();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const Spacer(),
                    // Logo kecil
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _accentColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(Icons.music_note,
                            color: _accentColor, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              // Konten utama
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _slideController,
                      child: _isOtpSent
                          ? _buildOtpSection()
                          : _buildPhoneSection(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION 1: Input Nomor Telepon
  // ─────────────────────────────────────────────
  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),

        // Ikon
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _accentColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border:
                Border.all(color: _accentColor.withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.phone_android, color: _accentColor, size: 44),
        ),
        const SizedBox(height: 24),

        const Text(
          'Masuk dengan\nNomor Telepon',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Kami akan mengirimkan kode OTP\nke nomor telepon Anda',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),

        // Input nomor dengan kode negara
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Nomor Telepon',
              labelStyle:
                  TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              hintText: '812 3456 7890',
              hintStyle:
                  TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: _accentColor, width: 1.5),
              ),
              counterText: '',
            ),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            dropdownTextStyle:
                const TextStyle(color: Colors.white, fontSize: 14),
            dropdownIcon:
                Icon(Icons.arrow_drop_down, color: _accentColor),
            initialCountryCode: 'ID',
            keyboardType: TextInputType.phone,
            onChanged: (phone) {
              setState(() {
                _completePhoneNumber = phone.completeNumber;
                _errorMessage = null;
              });
            },
            onCountryChanged: (_) {
              setState(() => _errorMessage = null);
            },
          ),
        ),

        // Pesan error
        if (_errorMessage != null) ...[
          const SizedBox(height: 14),
          _buildErrorBox(_errorMessage!),
        ],

        const SizedBox(height: 28),

        // Tombol kirim OTP
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: _accentColor.withValues(alpha: 0.5),
            ),
            onPressed: _isLoading ? null : _sendOtp,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Kirim Kode OTP',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),

        const SizedBox(height: 20),
        Text(
          'Pastikan nomor telepon Anda aktif dan\ndapat menerima SMS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SECTION 2: Input OTP
  // ─────────────────────────────────────────────
  Widget _buildOtpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),

        // Ikon
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF22D3EE).withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFF22D3EE).withValues(alpha: 0.4),
                width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22D3EE).withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.sms_outlined,
              color: Color(0xFF22D3EE), size: 44),
        ),
        const SizedBox(height: 24),

        const Text(
          'Masukkan Kode OTP',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.55),
                height: 1.5),
            children: [
              const TextSpan(text: 'Kode dikirim ke\n'),
              TextSpan(
                text: _completePhoneNumber,
                style: const TextStyle(
                  color: _accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // 6 kotak OTP
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _buildOtpBox(i)),
        ),

        // Pesan error
        if (_errorMessage != null) ...[
          const SizedBox(height: 14),
          _buildErrorBox(_errorMessage!),
        ],

        const SizedBox(height: 28),

        // Tombol verifikasi
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: _accentColor.withValues(alpha: 0.5),
            ),
            onPressed: _isVerifying ? null : _verifyOtp,
            child: _isVerifying
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Verifikasi',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 20),

        // Tombol kirim ulang
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tidak menerima kode? ',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
            ),
            _resendCountdown > 0
                ? Text(
                    'Kirim ulang (${ _resendCountdown}s)',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 13),
                  )
                : GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => _sendOtp(isResend: true),
                    child: const Text(
                      'Kirim Ulang',
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Kode OTP berlaku selama 60 detik',
          style: TextStyle(
              fontSize: 11, color: Colors.white.withValues(alpha: 0.3)),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Widget helper: kotak OTP tunggal
  // ─────────────────────────────────────────────
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.07),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accentColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
        ),
        onChanged: (val) => _onOtpChanged(val, index),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Widget helper: kotak error
  // ─────────────────────────────────────────────
  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
