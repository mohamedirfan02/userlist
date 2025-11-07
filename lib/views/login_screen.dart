
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:userlist/viewmodels/auth_viewmodel.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

/// A screen that allows users to log in using their phone number.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+91'; // default India

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Fetches the SIM phone number after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthViewModel>(context, listen: false);
      await auth.fetchSimPhoneNumber();

      if (auth.phoneNumber != null && auth.phoneNumber!.isNotEmpty) {
        final phone = auth.phoneNumber!;
        if (phone.startsWith('+')) {
          for (final code in ['+91', '+1', '+44', '+61', '+971']) {
            if (phone.startsWith(code)) {
              _selectedCountryCode = code;
              _phoneController.text = phone.replaceFirst(code, '');
              break;
            }
          }
        } else {
          _phoneController.text = phone;
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// A helper method to validate the phone number.
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    return null;
  }

  /// Submits the phone number to get an OTP.
  void _submitPhone() {
    if (_formKey.currentState!.validate()) {
      String phone = _phoneController.text.trim();

      if (phone.startsWith(_selectedCountryCode)) {
        phone = phone.replaceFirst(_selectedCountryCode, '');
      }

      final fullPhone = '$_selectedCountryCode$phone';
      debugPrint('📞 Sending phone: $fullPhone');

      _showOTPDialog(context, fullPhone);
    }
  }

  /// Shows a dialog for entering the OTP.
  void _showOTPDialog(BuildContext context, String fullPhone) {
    String enteredOTP = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        final screenWidth = size.width;
        final dialogWidth = screenWidth * 0.9;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          titlePadding: const EdgeInsets.all(16),

          title: Row(
            children: const [
              Icon(Icons.lock_outline, color: Colors.blueAccent, size: 26),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: SizedBox(
              width: dialogWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'A 6-digit OTP has been sent to your phone number.',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: const Text(
                      'Test OTP: 123456',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final fieldWidth =
                          (constraints.maxWidth - 50) / 6; 
                      return OtpTextField(
                        numberOfFields: 6,
                        fieldWidth: fieldWidth,
                        borderColor: Colors.blueAccent,
                        focusedBorderColor: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                        showFieldAsBox: true,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        onCodeChanged: (String code) {},
                        onSubmit: (String verificationCode) {
                          enteredOTP = verificationCode;
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    'Please enter the 6-digit code to verify',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Cancel'),
            ),

            ElevatedButton.icon(
              onPressed: () async {
                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                final success = await authViewModel.verifyOtp(enteredOTP);

                if (success) {
                  Navigator.pop(dialogContext);
                  Navigator.pushReplacementNamed(context, '/address-list');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid OTP. Please use: 123456'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 18),
              label: const Text('Verify'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0072ff), Color(0xFF00c6ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                /// Animated Logo
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 90,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Address Manager',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Smart way to manage your addresses',
                    style: TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 50),

                /// Login Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 55,
                                padding:
                                const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.4)),
                                ),
                                child: CountryCodePicker(
                                  onChanged: (code) {
                                    setState(() =>
                                    _selectedCountryCode = code.dialCode!);
                                  },
                                  initialSelection: _selectedCountryCode,
                                  favorite: const ['+91', 'IN', '+1', 'US'],
                                  showFlag: true,
                                  padding: EdgeInsets.zero,
                                  showCountryOnly: false,
                                  alignLeft: false,
                                  textStyle: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  dialogTextStyle:
                                  const TextStyle(color: Colors.black),
                                  searchDecoration: const InputDecoration(
                                    hintText: 'Search country',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    labelText: 'Phone Number',
                                    labelStyle:
                                    const TextStyle(color: Colors.white70),
                                    filled: true,
                                    fillColor:
                                    Colors.white.withOpacity(0.05),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color:
                                          Colors.white.withOpacity(0.4)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Colors.white),
                                    ),
                                  ),
                                  validator: _validatePhone,
                                ),
                              ),
                            ],
                          ),
                          if (authProvider.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                authProvider.errorMessage!,
                                style: const TextStyle(
                                    color: Colors.redAccent, fontSize: 12),
                              ),
                            ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _submitPhone,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0072ff),
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0072ff),
                                ),
                              )
                                  : const Text(
                                'Send OTP',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Note: For testing, use OTP: 123456',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
