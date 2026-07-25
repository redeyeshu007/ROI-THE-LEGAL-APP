import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:login_signup/screens/wrapper.dart';
import 'package:login_signup/screens/signin_screen.dart';
import 'package:login_signup/theme/app_colors.dart';

class Verify extends StatefulWidget {
  const Verify({super.key});

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  @override
  void initState() {
    sendverifylink();
    super.initState();
  }

  sendverifylink() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
  }

  reload() async {
    await FirebaseAuth.instance.currentUser!
        .reload()
        .then((value) => {Get.offAll(const Wrapper())});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.mark_email_unread_rounded, size: 56, color: AppColors.info),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Verify your email',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We\'ve sent a verification link to your\nemail address. Please check your inbox\nand click the link to verify.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.6,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => reload(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('I\'ve verified — Reload',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Get.offAll(() => const SignInScreen());
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
                  label: const Text('Cancel & Go Back',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    side: const BorderSide(color: AppColors.border),
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
