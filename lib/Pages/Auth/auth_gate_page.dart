import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'setup_profile_screen.dart';
// Auth Popup দেখানোর মূল ফাংশন
void showAuthPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const VxAuthGateContent();
    },
  );
}

class VxAuthGateContent extends StatefulWidget {
  const VxAuthGateContent({super.key});

  @override
  State<VxAuthGateContent> createState() => _VxAuthGateContentState();
}

enum AuthStep { emailStep, otpStep }

class _VxAuthGateContentState extends State<VxAuthGateContent> {
  AuthStep _currentStep = AuthStep.emailStep;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isLoading = false; 
  final String _baseUrl = "https://app.easysarvice.com";

  // ১. ইমেইলে ওটিপি রিকোয়েস্ট পাঠানোর ফাংশন
  Future<void> _sendOTP() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/v1/auth/email-request"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _emailController.text.trim()}),
      );

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || data['status'] == true) {
        setState(() {
          _currentStep = AuthStep.otpStep;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "OTP sent successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to send OTP")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ২. ওটিপি ভেরিফাই করে টোকেন সেভ করার আপডেটেড লজিক
  Future<void> _verifyOTP() async {
    if (_otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter the 6-digit OTP code")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/api/v1/auth/email-verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "otp": _otpController.text.trim(),
        }),
      );

      if (!mounted) return;
      final data = jsonDecode(response.body);

      // স্ট্যাটাস কোড ২০০-২৯৯ এর মধ্যে থাকলে সাকসেস ধরবে
      if (response.statusCode >= 200 && response.statusCode < 300 && data['status'] == true) {
        
        String accessToken = data['access_token'] ?? '';
        String refreshToken = data['refresh_token'] ?? '';
        int userId = data['user']?['id'] ?? 0;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        await prefs.setInt('user_id', userId);
        await prefs.setBool('is_logged_in', true);

        if (!mounted) return;
        Navigator.of(context).pop(); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful! 🚀")),
        );
      } else {
        String errorMsg = data['message'] ?? "Invalid OTP! (Status: ${response.statusCode})";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goBackToEmail() {
    setState(() {
      _currentStep = AuthStep.emailStep;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // লোগো ও টেক্সট পার্ট
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFF4FB3),
                              Color(0xFFB24FF3),
                              Color(0xFF4F9DFF),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            "Vx",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Welcome to Vx",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Discover short videos that will\nmake your day. Join millions of\ncreators and viewers.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFeatureChip("⚡ Create"),
                            const SizedBox(width: 12),
                            _buildFeatureChip("❤️ Like"),
                            const SizedBox(width: 12),
                            _buildFeatureChip("💬 Comment"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // এনিমেশন ইনপুট এরিয়া
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _currentStep == AuthStep.otpStep 
                    ? _buildOtpStepView() 
                    : _buildEmailStepView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStepView() {
    return Column(
      key: const ValueKey('emailStep'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAuthButton(
          icon: MdiIcons.google,
          text: "Continue with Google",
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4FB3), Color(0xFFB24FF3)],
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Google login coming soon")),
            );
          },
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "OR",
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
          ],
        ),
        const SizedBox(height: 24),

        TextField(
          controller: _emailController,
          enabled: !_isLoading, 
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Enter your email address",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        _buildAuthButton(
          icon: Icons.arrow_forward,
          text: "Continue with Email",
          isLoading: _isLoading, 
          gradient: null, 
          onPressed: _sendOTP,
        ),
        const SizedBox(height: 24),
        
        Center(
          child: Text(
            "By continuing you agree to our\nTerms of Service and Privacy Policy",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStepView() {
    return Column(
      key: const ValueKey('otpStep'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _isLoading ? null : _goBackToEmail,
            ),
            const Text(
              "Verify Email",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            "We sent a 6-digit code to ${_emailController.text}",
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),
        
        TextField(
          controller: _otpController,
          enabled: !_isLoading,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 10,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: "",
            hintText: "000000",
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.2),
              letterSpacing: 10,
            ),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        _buildAuthButton(
          icon: Icons.check_circle_outline,
          text: "Verify & Login",
          isLoading: _isLoading, 
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4FB3), Color(0xFFB24FF3)],
          ),
          onPressed: _verifyOTP,
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    LinearGradient? gradient,
    bool isLoading = false, 
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? const Color(0xFF1E1E1E) : null,
        borderRadius: BorderRadius.circular(30),
        boxShadow: gradient != null
            ? [
                BoxShadow(
                  color: const Color(0xFFFF4FB3).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        onPressed: isLoading ? null : onPressed, 
        child: isLoading 
            ? const CupertinoActivityIndicator(color: Colors.white) 
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

