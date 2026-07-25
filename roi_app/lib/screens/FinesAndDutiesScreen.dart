import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:get/get.dart';

class FinesAndDutiesScreen extends StatefulWidget {
  const FinesAndDutiesScreen({super.key});

  @override
  State<FinesAndDutiesScreen> createState() => _FinesAndDutiesScreenState();
}

class _FinesAndDutiesScreenState extends State<FinesAndDutiesScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'RLRHnWIRDiQ',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'fines_and_duties'.tr,
          style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Hero section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: AppColors.primaryBg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'know_fines_duties'.tr,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'learn_fines_desc'.tr,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'Inter'),
                ),
              ],
            ),
          ),

          // Video player
          Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
