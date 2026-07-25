import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_signup/screens/signin_screen.dart';
import 'package:login_signup/screens/wrapper.dart';
import 'package:login_signup/theme/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController fullName = TextEditingController();

  final _formSignupKey = GlobalKey<FormState>();
  bool isloading = false;
  String errorMessage = '';

  Future<void> signUp() async {
    if (_formSignupKey.currentState?.validate() ?? false) {
      setState(() {
        isloading = true;
        errorMessage = '';
      });
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text,
          password: password.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'username': fullName.text,
          'email': email.text,
          'easyQuizzesCompleted': 0,
          'hardQuizzesCompleted': 0,
          'totalQuizzesCompleted': 0,
          'level': 'beginner',
        });

        Get.offAll(const Wrapper());
      } on FirebaseAuthException catch (e) {
        debugPrint('SIGN UP FIREBASE ERROR: ${e.code} - ${e.message}');
        String errorMsg = 'signup_failed_err'.tr;
        if (e.code == 'email-already-in-use') {
          errorMsg = 'email_in_use_err'.tr;
        } else if (e.code == 'weak-password') {
          errorMsg = 'weak_password_err'.tr;
        } else if (e.code == 'invalid-email') {
          errorMsg = 'invalid_email_msg'.tr;
        } else {
          errorMsg = 'Error (${e.code}): ${e.message ?? e.toString()}';
        }
        setState(() {
          errorMessage = errorMsg;
        });
      }
      setState(() {
        isloading = false;
      });
    }
  }

  login() async {
    setState(() {
      isloading = true;
      errorMessage = '';
    });
    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email'],
        serverClientId: '224150240249-edpp85q0a84tvak2gd9fi19s4kad8eq8.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() { isloading = false; });
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();
        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
            'username': userCredential.user?.displayName ?? 'new_user_default'.tr,
            'email': userCredential.user?.email ?? '',
            'easyQuizzesCompleted': 0,
            'hardQuizzesCompleted': 0,
            'totalQuizzesCompleted': 0,
            'level': 'beginner',
          });
        }
        Get.offAll(() => const Wrapper());
      }
    } catch (e) {
      debugPrint('GOOGLE SIGN UP/IN ERROR: $e');
      setState(() {
        errorMessage = 'google_signin_failed'.trParams({'error': e.toString()});
      });
    }
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Text(
                          'create_account_title'.tr,
                          softWrap: true,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        'start_journey_desc'.tr,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Full Name
                      _buildLabel('full_name_label'.tr),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: fullName,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'enter_name_err'.tr;
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'full_name_hint'.tr,
                          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Email
                      _buildLabel('email_label'.tr),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: email,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'enter_email_err'.tr;
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'invalid_email_err'.tr;
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'email_hint'.tr,
                          prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Password
                      _buildLabel('password_label'.tr),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: password,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'enter_password_err'.tr;
                          if (value.length < 6) return 'password_length_err'.tr;
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'password_hint'.tr,
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Error
                      if (errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
                          ),
                        ),

                      // Sign Up button
                      ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('signup_btn'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or_signup_with'.tr,
                              style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Google button
                      OutlinedButton.icon(
                        onPressed: () => login(),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                        label: Text('continue_google'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      const SizedBox(height: 28),

                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('already_have_account'.tr,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => Get.to(() => const SignInScreen()),
                            child: Text(
                              'sign_in_link'.tr,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    );
  }
}
