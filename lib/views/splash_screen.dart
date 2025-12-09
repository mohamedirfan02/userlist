import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:userlist/core/constant/app_hive_storage_constants.dart';
import 'login_screen.dart';

/// The splash screen of the application.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _navigate();

    // Initialize the animation controller.
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define the scale and fade animations.
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Start the animation.
    _controller.forward();

  }

  Future<void> _navigate() async {

    await Future.delayed(const Duration(seconds: 2)); // just for animation/demo

    final authBox = Hive.box(AppHiveStorageConstants.authBoxKey);
    final isLoggedIn =
    authBox.get(AppHiveStorageConstants.isAuthLoggedInStatus, defaultValue: false);

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/address-list');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
    print('Hive login: ${authBox.get(AppHiveStorageConstants.isAuthLoggedInStatus)}');
    print('Hive phone: ${authBox.get(AppHiveStorageConstants.userPhoneNumber)}');


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Glow
            Positioned(
              top: size.height * 0.25,
              child: AnimatedOpacity(
                opacity: 0.4,
                duration: const Duration(seconds: 2),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),

            // Animated Logo
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo or Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // App Name
                    const Text(
                      "Address Manager",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tagline
                    const Text(
                      "Simplify your address management",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 40),
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
