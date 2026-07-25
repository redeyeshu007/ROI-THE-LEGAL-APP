import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/widgets/falling_symbols.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// System Prompts (preserved exactly)
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Dynamic System Prompts Generator
// ─────────────────────────────────────────────────────────────────────────────
String _getChatPrompt(String lang) =>
    'You are NEEDHi, an expert Indian Constitution and legal tutor. '
    'IMPORTANT: Reply ONLY in the $lang language. '
    'STRICT RULE: Give detailed, well-structured answers in PLAIN TEXT ONLY. '
    'DO NOT use **bolding**, *italics*, or any markdown symbols. '
    'Use numbered lists (1. 2. 3.) for steps and Article/Section numbers. '
    'Cover: definition, explanation in simple $lang, real-world example, and legal procedure. '
    'Mention both IPC and BNS. End with: "This is for educational purposes, not formal legal advice."';

String _getVoicePrompt(String lang) =>
    'You are VIDDHI, an Indian legal AI assistant for voice conversations. '
    'IMPORTANT: Reply ONLY in the $lang language. '
    'Give clear, conversational answers in 3-5 sentences. PLAIN TEXT ONLY. '
    'DO NOT use any markdown symbols like **. Cite Article/Section numbers. '
    'Always add: "This is educational, not formal legal advice."';

const _kLanguages = [
  'English', 'Hindi', 'Tamil', 'Telugu', 
  'Marathi', 'Malayalam', 'Kannada', 'Bengali'
];

// ─────────────────────────────────────────────────────────────────────────────
// Message Model
// ─────────────────────────────────────────────────────────────────────────────
class _Msg {
  final String text;
  final bool isUser;
  final bool isVoice;
  _Msg(this.text, {required this.isUser, this.isVoice = false});
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Suggestion Chips
// ─────────────────────────────────────────────────────────────────────────────
const _kQuickSuggestions = [
  ('⚖️ Fundamental Rights', 'Explain my Fundamental Rights under the Indian Constitution'),
  ('📜 Article 21', 'What is Article 21 and what does it protect?'),
  ('🚔 Police Arrest', 'What are my rights if I am arrested by police?'),
  ('📋 RTI Act', 'How do I file an RTI application?'),
  ('🏛️ IPC vs BNS', 'What is the difference between IPC and the new BNS?'),
  ('👩‍⚖️ Legal Aid', 'How can I get free legal aid in India?'),
];

// ─────────────────────────────────────────────────────────────────────────────
// UI Localization
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, Map<String, String>> _kLoc = {
  'English': {
    'hi': 'Hello, I\'m',
    'legal_ai': 'Your Legal AI',
    'choose_lang': 'Choose Language',
    'popular': 'Popular Questions',
    'fact': 'Fact of the Day',
    'voice_mode': 'Voice Mode',
    'hands_free': 'Hands-free legal advice in your local language.',
    'try_now': 'Try Now',
    'listening': 'Listening… speak now',
    'type_here': 'Or type here…',
    'ask': 'Ask about Indian law…',
    'thinking': 'thinking…',
    'q1': '⚖️ Fundamental Rights', 'p1': 'Explain my Fundamental Rights under the Indian Constitution',
    'q2': '📜 Article 21', 'p2': 'What is Article 21 and what does it protect?',
    'q3': '🚔 Police Arrest', 'p3': 'What are my rights if I am arrested by police?',
    'q4': '📋 RTI Act', 'p4': 'How do I file an RTI application?',
    'q5': '🏛️ IPC vs BNS', 'p5': 'What is the difference between IPC and the new BNS?',
    'q6': '👩‍⚖️ Legal Aid', 'p6': 'How can I get free legal aid in India?',
  },
  'Hindi': {
    'hi': 'नमस्ते, मैं हूँ',
    'legal_ai': 'आपका कानूनी एआई',
    'choose_lang': 'भाषा चुनें',
    'popular': 'लोकप्रिय प्रश्न',
    'fact': 'आज का तथ्य',
    'voice_mode': 'वॉइस मोड',
    'hands_free': 'अपनी स्थानीय भाषा में हाथों से मुक्त कानूनी सलाह।',
    'try_now': 'अभी आज़माएं',
    'listening': 'सुन रहा हूँ… अब बोलें',
    'type_here': 'या यहाँ टाइप करें…',
    'ask': 'भारतीय कानून के बारे में पूछें…',
    'thinking': 'सोच रहा हूँ…',
    'q1': '⚖️ मौलिक अधिकार', 'p1': 'भारतीय संविधान के तहत मेरे मौलिक अधिकारों की व्याख्या करें',
    'q2': '📜 अनुच्छेद 21', 'p2': 'अनुच्छेद 21 क्या है और यह क्या रक्षा करता है?',
    'q3': '🚔 पुलिस गिरफ्तारी', 'p3': 'यदि मुझे पुलिस गिरफ्तार करती है तो मेरे क्या अधिकार हैं?',
    'q4': '📋 सूचना का अधिकार', 'p4': 'मैं RTI आवेदन कैसे दाखिल करूं?',
    'q5': '🏛️ IPC बनाम BNS', 'p5': 'IPC और नई BNS के बीच क्या अंतर है?',
    'q6': '👩‍⚖️ कानूनी सहायता', 'p6': 'मैं भारत में मुफ्त कानूनी सहायता कैसे प्राप्त कर सकता हूँ?',
  },
  'Tamil': {
    'hi': 'வணக்கம், நான்',
    'legal_ai': 'உங்கள் சட்ட உதவி AI',
    'choose_lang': 'மொழியைத் தேர்ந்தெடுக்கவும்',
    'popular': 'பிரபலமான கேள்விகள்',
    'fact': 'இன்றைய உண்மை',
    'voice_mode': 'குரல் முறை',
    'hands_free': 'உங்கள் உள்ளூர் மொழியில் ஹேண்ட்ஸ்-ஃப்ரீ சட்ட ஆலோசனை.',
    'try_now': 'இப்போது முயற்சிக்கவும்',
    'listening': 'கேட்கிறது… இப்போது பேசுங்கள்',
    'type_here': 'அல்லது இங்கே தட்டச்சு செய்க…',
    'ask': 'இந்திய சட்டத்தைப் பற்றி கேளுங்கள்…',
    'thinking': 'யோசிக்கிறது…',
    'q1': '⚖️ அடிப்படை உரிமைகள்', 'p1': 'இந்திய அரசியலமைப்பின் கீழ் எனது அடிப்படை உரிமைகளை விளக்குங்கள்',
    'q2': '📜 பிரிவு 21', 'p2': 'பிரிவு 21 என்றால் என்ன மற்றும் அது எதைப் பாதுகாக்கிறது?',
    'q3': '🚔 போலீஸ் கைது', 'p3': 'போலீசார் என்னை கைது செய்தால் எனது உரிமைகள் என்ன?',
    'q4': '📋 RTI சட்டம்', 'p4': 'RTI விண்ணப்பத்தை நான் எவ்வாறு தாக்கல் செய்வது?',
    'q5': '🏛️ IPC vs BNS', 'p5': 'IPC மற்றும் புதிய BNS க்கும் என்ன வித்தியாசம்?',
    'q6': '👩‍⚖️ சட்ட உதவி', 'p6': 'இந்தியாவில் நான் எப்படி இலவச சட்ட உதவியைப் பெறுவது?',
  },
  'Telugu': {
    'hi': 'నమస్కారం, నేను',
    'legal_ai': 'మీ లీగల్ AI',
    'choose_lang': 'భాషను ఎంచుకోండి',
    'popular': 'ప్రసిద్ధ ప్రశ్నలు',
    'fact': 'ఈ రోజు వాస్తవం',
    'voice_mode': 'వాయిస్ మోడ్',
    'hands_free': 'మీ స్థానిక భాషలో హ్యాండ్స్-ఫ్రీ చట్టపరమైన సలహా.',
    'try_now': 'ఇప్పుడే ప్రయత్ండి',
    'listening': 'వింటున్నాను… ఇప్పుడు మాట్లాడండి',
    'type_here': 'లేదా ఇక్కడ టైప్ చేయండి…',
    'ask': 'భారతీయ చట్టం గురించి అడగండి…',
    'thinking': 'ఆలోచిస్తోంది…',
    'q1': '⚖️ ప్రాథమిక హక్కులు', 'p1': 'భారత రాజ్యాంగం ప్రకారం నా ప్రాథమిక హక్కులను వివరించండి',
    'q2': '📜 ఆర్టికల్ 21', 'p2': 'ఆర్టికల్ 21 అంటే ఏమిటి మరియు అది దేనిని రక్షిస్తుంది?',
    'q3': '🚔 పోలీసు అరెస్ట్', 'p3': 'పోలీసులు నన్ను అరెస్టు చేస్తే నా హక్కులు ఏమిటి?',
    'q4': '📋 RTI చట్టం', 'p4': 'నేను RTI దరఖాస్తును ఎలా దాఖలు చేయాలి?',
    'q5': '🏛️ IPC వర్సెస్ BNS', 'p5': 'IPC మరియు కొత్త BNS మధ్య తేడా ఏమిటి?',
    'q6': '👩‍⚖️ ఉచిత చట్టపరమైన సహాయం', 'p6': 'భారతదేశంలో నేను ఉచిత చట్టపరమైన సహాయం ఎలా పొందగలను?',
  },
  'Marathi': {
    'hi': 'नमस्कार, मी आहे',
    'legal_ai': 'तुमचा कायदेशीर AI',
    'choose_lang': 'भाषा निवडा',
    'popular': 'लोकप्रिय प्रश्न',
    'fact': 'आजची माहिती',
    'voice_mode': 'व्हॉइस मोड',
    'hands_free': 'तुमच्या स्थानिक भाषेत हँड्स-फ्री कायदेशीर सल्ला.',
    'try_now': 'आता प्रयत्न करा',
    'listening': 'ऐकत आहे… आता बोला',
    'type_here': 'किंवा येथे टाईप करा…',
    'ask': 'भारतीय कायद्याबद्दल विचारा…',
    'thinking': 'विचार करत आहे…',
    'q1': '⚖️ मूलभूत अधिकार', 'p1': 'भारतीय संविधानांतर्गत माझ्या मूलभूत अधिकारांचे स्पष्टीकरण द्या',
    'q2': '📜 अनुच्छेद २१', 'p2': 'अनुच्छेद २१ म्हणजे काय आणि ते कशाचे संरक्षण करते?',
    'q3': '🚔 पोलीस अटक', 'p3': 'जर पोलिसांनी मला अटक केली तर माझे अधिकार काय आहेत?',
    'q4': '📋 RTI कायदा', 'p4': 'मी RTI अर्ज कसा दाखल करू?',
    'q5': '🏛️ IPC विरुद्ध BNS', 'p5': 'IPC आणि नवीन BNS मध्ये काय फरक आहे?',
    'q6': '👩‍⚖️ कायदेशीर मदत', 'p6': 'मला भारतात मोफत कायदेशीर मदत कशी मिळू शकते?',
  },
  'Malayalam': {
    'hi': 'ഹലോ, ഞാൻ',
    'legal_ai': 'നിങ്ങളുടെ ലീഗൽ AI',
    'choose_lang': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
    'popular': 'പ്രധാന ചോദ്യങ്ങൾ',
    'fact': 'ഇന്നത്തെ വസ്തുത',
    'voice_mode': 'വോയ്സ് മോഡ്',
    'hands_free': 'നിങ്ങളുടെ പ്രാദേശിക ഭാഷയിൽ ഹാൻഡ്‌സ് ഫ്രീ നിയമോപദേശം.',
    'try_now': 'ഇപ്പോൾ ശ്രമിക്കുക',
    'listening': 'ശ്രദ്ധിക്കുന്നു… ഇപ്പോൾ സംസാരിക്കുക',
    'type_here': 'അല്ലെങ്കിൽ ഇവിടെ ടൈപ്പ് ചെയ്യുക…',
    'ask': 'ഇന്ത്യൻ നിയമത്തെക്കുറിച്ച് ചോദിക്കുക…',
    'thinking': 'ചിന്തിക്കുന്നു…',
    'q1': '⚖️ മൗലികാവകാശങ്ങൾ', 'p1': 'ഇന്ത്യൻ ഭരണഘടന പ്രകാരമുള്ള എന്റെ മൗലികാവകാശങ്ങൾ വിശദീകരിക്കുക',
    'q2': '📜 അനുച്ഛേദം 21', 'p2': 'അനുച്ഛേദം 21 എന്നാൽ എന്ത്, അത് എന്താണ് സംരക്ഷിക്കുന്നത്?',
    'q3': '🚔 പോലീസ് അറസ്റ്റ്', 'p3': 'പോലീസ് എന്നെ അറസ്റ്റ് ചെയ്താൽ എന്റെ അവകാശങ്ങൾ എന്തൊക്കെയാണ്?',
    'q4': '📋 വിവരാവകാശ നിയമം', 'p4': 'ഞാൻ എങ്ങനെ ഒരു RTI അപേക്ഷ ഫയൽ ചെയ്യും?',
    'q5': '🏛️ IPC vs BNS', 'p5': 'IPC-യും പുതിയ BNS-ഉം തമ്മിലുള്ള വ്യത്യാസം എന്താണ്?',
    'q6': '👩‍⚖️ നിയമസഹായം', 'p6': 'ഇന്ത്യയിൽ എനിക്ക് എങ്ങനെ സൗജന്യ നിയമസഹായം ലഭിക്കും?',
  },
  'Kannada': {
    'hi': 'ನಮಸ್ಕಾರ, ನಾನು',
    'legal_ai': 'ನಿಮ್ಮ ಕಾನೂನು AI',
    'choose_lang': 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',
    'popular': 'ಜನಪ್ರಿಯ ಪ್ರಶ್ನೆಗಳು',
    'fact': 'ಇಂದಿನ ಸತ್ಯ',
    'voice_mode': 'ವಾಯ್ಸ್ ಮೋಡ್',
    'hands_free': 'ನಿಮ್ಮ ಸ್ಥಳೀಯ ಭಾಷೆಯಲ್ಲಿ ಹ್ಯಾಂಡ್ಸ್-ಫ್ರೀ ಕಾನೂನು ಸಲಹೆ.',
    'try_now': 'ಈಗ ಪ್ರಯತ್ನಿಸಿ',
    'listening': 'ಕೇಳಿಸಿಕೊಳ್ಳುತ್ತಿದ್ದೇನೆ… ಈಗ ಮಾತನಾಡಿ',
    'type_here': 'ಅಥವಾ ಇಲ್ಲಿ ಟೈಪ್ ಮಾಡಿ…',
    'ask': 'ಭಾರತೀಯ ಕಾನೂನಿನ ಬಗ್ಗೆ ಕೇಳಿ…',
    'thinking': 'ಯೋಚಿಸುತ್ತಿದೆ…',
    'q1': '⚖️ ಮೂಲಭೂತ ಹಕ್ಕುಗಳು', 'p1': 'ಭಾರತೀಯ ಸಂವಿಧಾನದ ಅಡಿಯಲ್ಲಿ ನನ್ನ ಮೂಲಭೂತ ಹಕ್ಕುಗಳನ್ನು ವಿವರಿಸಿ',
    'q2': '📜 ವಿಧಿ 21', 'p2': 'ವಿಧಿ 21 ಎಂದರೇನು ಮತ್ತು ಅದು ಏನನ್ನು ರಕ್ಷಿಸುತ್ತದೆ?',
    'q3': '🚔 ಪೊಲೀಸ್ ಬಂಧನ', 'p3': 'ಪೊಲೀಸರು ನನ್ನನ್ನು ಬಂಧಿಸಿದರೆ ನನ್ನ ಹಕ್ಕುಗಳೇನು?',
    'q4': '📋 RTI ಕಾಯ್ದೆ', 'p4': 'ನಾನು RTI ಅರ್ಜಿಯನ್ನು ಹೇಗೆ ಸಲ್ಲಿಸಬೇಕು?',
    'q5': '🏛️ IPC ವಿರುದ್ಧ BNS', 'p5': 'IPC ಮತ್ತು ಹೊಸ BNS ನಡುವಿನ ವ್ಯತ್ಯಾಸವೇನು?',
    'q6': '👩‍⚖️ ಕಾನೂನು ನೆರವು', 'p6': 'ಭಾರತದಲ್ಲಿ ನಾನು ಉಚಿತ ಕಾನೂನು ನೆರವು ಪಡೆಯುವುದು ಹೇಗೆ?',
  },
  'Bengali': {
    'hi': 'হ্যালো, আমি হলাম',
    'legal_ai': 'আপনার আইনি AI',
    'choose_lang': 'ভাষা নির্বাচন করুন',
    'popular': 'জনপ্রিয় প্রশ্ন',
    'fact': 'আজকের তথ্য',
    'voice_mode': 'ভয়েস মোড',
    'hands_free': 'আপনার স্থানীয় ভাষায় হ্যান্ডস-ফ্রি আইনি পরামর্শ।',
    'try_now': 'এখনই চেষ্টা করুন',
    'listening': 'শুনছি… এখন বলুন',
    'type_here': 'অথবা এখানে টাইপ করুন…',
    'ask': 'ভারতীয় আইন সম্পর্কে জিজ্ঞাসা করুন…',
    'thinking': 'চিন্তা করছে…',
    'q1': '⚖️ মৌলিক অধিকার', 'p1': 'ভারতীয় সংবিধানের অধীনে আমার মৌলিক অধিকারগুলি ব্যাখ্যা করুন',
    'q2': '📜 ধারা ২১', 'p2': 'ধারা ২১ কি এবং এটি কি রক্ষা করে?',
    'q3': '🚔 পুলিশ গ্রেফতার', 'p3': 'পুলিশ আমাকে গ্রেফতার করলে আমার অধিকার কি?',
    'q4': '📋 RTI আইন', 'p4': 'আমি কিভাবে RTI আবেদন দাখিল করব?',
    'q5': '🏛️ IPC বনাম BNS', 'p5': 'IPC এবং নতুন BNS এর মধ্যে পার্থক্য কি?',
    'q6': '👩‍⚖️ আইনি সহায়তা', 'p6': 'আমি ভারতে কিভাবে বিনামূল্যে আইনি সহায়তা পেতে পারি?',
  },
};

String l(String key, String lang) => _kLoc[lang]?[key] ?? _kLoc['English']![key]!;

// ─────────────────────────────────────────────────────────────────────────────
// ChatScreen — Beautiful Modern UI
// ─────────────────────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _feedbackCollection = FirebaseFirestore.instance.collection('feedback');

  static const _kGroqKey = 'REPLACE_WITH_YOUR_GROQ_API_KEY'; // Removed for security

  static const _kGroqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  final List<Map<String, dynamic>> _chatHistory = [];
  final List<Map<String, dynamic>> _voiceHistory = [];

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _voiceText = '';

  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _ttsEnabled = true;

  bool _isVoiceMode = false;
  bool _isBotTyping = false;
  bool _chatStarted = false;
  bool _isProcessingVoice = false; // Guard for STT double execution
  String _selectedLanguage = 'English';

  late AnimationController _micPulse;
  late Animation<double> _micScale;
  late AnimationController _orbAnim;
  late AnimationController _floatAnim;
  late Animation<double> _floatOffset;

  final List<_Msg> _messages = [];

  @override
  void initState() {
    super.initState();

    _micPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _micScale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _micPulse, curve: Curves.easeInOut),
    );
    _micPulse.stop();

    _orbAnim = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);

    _floatAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
    _floatOffset = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatAnim, curve: Curves.easeInOut));

    // Sync with global locale
    final langCode = Get.locale?.languageCode;
    if (langCode == 'hi') {
      _selectedLanguage = 'Hindi';
    } else if (langCode == 'ta') {
      _selectedLanguage = 'Tamil';
    } else if (langCode == 'te') {
      _selectedLanguage = 'Telugu';
    } else if (langCode == 'mr') {
      _selectedLanguage = 'Marathi';
    } else if (langCode == 'ml') {
      _selectedLanguage = 'Malayalam';
    } else if (langCode == 'kn') {
      _selectedLanguage = 'Kannada';
    } else if (langCode == 'bn') {
      _selectedLanguage = 'Bengali';
    }

    _initTts();
    _initSpeech();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setStartHandler(() => setState(() => _isSpeaking = true));
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _tts.setCancelHandler(() => setState(() => _isSpeaking = false));
  }

  void _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onError: (e) {
          debugPrint('STT error: $e');
          setState(() => _isListening = false);
        },
        onStatus: (status) {
          debugPrint('STT status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
            _micPulse.stop();
            _micPulse.reset();
            // Process only if not already processing and voiceText is not empty
            if (!_isProcessingVoice && _voiceText.trim().isNotEmpty) {
              _sendVoiceMessage(_voiceText.trim());
              _voiceText = '';
            }
          }
        },
        debugLogging: false,
      );
      if (!_speechAvailable) {
        // Retry once after a short delay (permission may not be granted yet)
        await Future.delayed(const Duration(seconds: 1));
        _speechAvailable = await _speech.initialize();
      }
    } catch (e) {
      debugPrint('STT init failed: $e');
      _speechAvailable = false;
    }
    if (mounted) setState(() {});
  }

  // Strip markdown symbols from AI responses before displaying
  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')   // **bold** -> text
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1')         // *italic* -> text
        .replaceAll(RegExp(r'`(.*?)`'), r'$1')           // `code` -> text
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')  // # headings
        .replaceAll(RegExp(r'^\s*[-•]\s+', multiLine: true), '• ')  // bullet normalize
        .trim();
  }

  void _toggleListening() async {
    // Interruption logic: Stop chatbot from speaking when mic is clicked
    _stopSpeaking();
    
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _micPulse.stop();
      _micPulse.reset();
    } else {
      if (!_speechAvailable) {
        _showSnack('Microphone not available on this device.');
        return;
      }
      setState(() {
        _isListening = true;
        _isVoiceMode = true;
        _voiceText = '';
      });
      _micPulse.repeat(reverse: true);
      final localeMap = {
        'English': 'en-IN',
        'Hindi': 'hi-IN',
        'Tamil': 'ta-IN',
        'Telugu': 'te-IN',
        'Marathi': 'mr-IN',
        'Malayalam': 'ml-IN',
        'Kannada': 'kn-IN',
        'Bengali': 'bn-IN',
      };
      final localeId = localeMap[_selectedLanguage] ?? 'en-IN';
      
      _isProcessingVoice = false; // Reset before listening
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _voiceText = result.recognizedWords;
            // Immediate send on final result if supported, 
            // otherwise onStatus handles it.
            if (result.finalResult && !_isProcessingVoice) {
               _sendVoiceMessage(_voiceText.trim());
               _voiceText = '';
            }
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        localeId: localeId,
      );
    }
  }

  Future<String> _callGemini(String userText, String systemPrompt,
      List<Map<String, dynamic>> history) async {
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
      ...history.map((h) => <String, dynamic>{
        'role': h['role'] == 'model' ? 'assistant' : 'user',
        'content': (h['parts'] as List).first['text'],
      }),
      {'role': 'user', 'content': userText},
    ];

    try {
      final response = await http.post(
        Uri.parse(_kGroqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_kGroqKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'];
        if (text != null && text.toString().trim().isNotEmpty) {
          history.add({'role': 'user', 'parts': [{'text': userText}]});
          history.add({'role': 'model', 'parts': [{'text': text}]});
          return text.toString().trim();
        }
        return 'No response. Please try again.';
      }
      final err = jsonDecode(response.body);
      return 'Error: ${err['error']?['message'] ?? response.statusCode}';
    } catch (e) {
      return 'Network error. Please check your connection.';
    }
  }

  Future<void> _speak(String text) async {
    if (!_ttsEnabled) return;
    final clean = text
        .replaceAll(RegExp(r'\*\*|\*|__|_|#{1,6}\s?|`'), '')
        .replaceAll(RegExp(r'\n{2,}'), '. ')
        .replaceAll('\n', ', ');
    await _tts.stop();
    await _tts.speak(clean);
  }

  Future<void> _stopSpeaking() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  Future<void> _sendVoiceMessage(String text) async {
    if (text.isEmpty || _isProcessingVoice) return;
    _isProcessingVoice = true;
    
    await _stopSpeaking();
    setState(() {
      _messages.add(_Msg(text, isUser: true, isVoice: true));
      _isBotTyping = true;
      _chatStarted = true;
    });
    _scrollToBottom();
    final reply = await _callGemini(text, _getVoicePrompt(_selectedLanguage), _voiceHistory);
    setState(() {
      _messages.add(_Msg(reply, isUser: false, isVoice: true));
      _isBotTyping = false;
      _isProcessingVoice = false;
    });
    _scrollToBottom();
    await _speak(reply);
  }

  Future<void> _sendChatMessage([String? overrideText]) async {
    final text = overrideText ?? _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text, isUser: true));
      _isBotTyping = true;
      _isVoiceMode = false;
      _chatStarted = true;
    });
    _controller.clear();
    _scrollToBottom();
    final reply = await _callGemini(text, _getChatPrompt(_selectedLanguage), _chatHistory);
    setState(() {
      _messages.add(_Msg(reply, isUser: false));
      _isBotTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _micPulse.dispose();
    _orbAnim.dispose();
    _floatAnim.dispose();
    _speech.stop();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Build
  // ───────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F8),
      body: Stack(children: [
        // Subtle falling symbols
        const FallingSymbolsBackground(
          symbols: ['🤖', '💬', '⚖️', '❓', '🧠', '📜'],
          count: 10,
          opacity: 0.15,
        ),
        SafeArea(
          child: Column(children: [
            _buildAppBar(),
            Expanded(
              child: Stack(
                children: [
                  _chatStarted ? _buildChatView() : _buildWelcomeView(),
                  // Gemini-like Orb
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _GeminiOrb(
                        visible: _isListening && _isVoiceMode,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isListening) _buildVoiceListeningBar(),
            _buildInputBar(),
          ]),
        ),
      ]),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    color: Colors.white.withOpacity(0.9),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF6C3AED)),
        ),
      ),
      const SizedBox(width: 10),
      // Animated orb avatar
      AnimatedBuilder(
        animation: _orbAnim,
        builder: (_, __) => Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: const [Color(0xFF7C3AED), Color(0xFF3B82F6), Color(0xFFEC4899), Color(0xFF7C3AED)],
              transform: GradientRotation(_orbAnim.value * 2 * pi),
            ),
            boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.4), blurRadius: 10)],
          ),
          child: const Center(child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18)),
        ),
      ),
      const SizedBox(width: 10),
      // Title — Flexible so it never pushes toggle button off screen
      Flexible(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Rules of India — AI',
            overflow: TextOverflow.visible,
            maxLines: 1,
            style: TextStyle(color: Color(0xFF1E1B4B), fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w900, fontSize: 13)),
          Row(children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Flexible(child: Text(
                _isVoiceMode ? 'VIDDHI · Voice Mode' : 'NEEDHi · Constitution Expert',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(color: Color(0xFF10B981), fontSize: 9, fontFamily: 'Inter', fontWeight: FontWeight.w600))),
          ]),
        ]),
      ),
      const SizedBox(width: 8),
      // Mode toggle — icon-only to save space
      GestureDetector(
        onTap: () => setState(() => _isVoiceMode = !_isVoiceMode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _isVoiceMode ? const Color(0xFF059669) : const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(
              color: (_isVoiceMode ? const Color(0xFF059669) : const Color(0xFF7C3AED)).withOpacity(0.35),
              blurRadius: 8)],
          ),
          child: Icon(
            _isVoiceMode ? Icons.mic_rounded : Icons.chat_rounded,
            color: Colors.white, size: 18,
          ),
        ),
      ),
      const SizedBox(width: 8),
      // Stop Speaking Button
      if (_isSpeaking)
        GestureDetector(
          onTap: _stopSpeaking,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10)],
            ),
            child: const Center(child: Icon(Icons.stop_rounded, color: Colors.white, size: 24)),
          ),
        ),
    ]),
  );

  // ── Welcome / Home View ──────────────────────────────────────────────────
  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // 50/50 Split Layout
        Row(children: [
          // Left: Info
          Expanded(
            flex: 7,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l('hi', _selectedLanguage), style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 18, color: Color(0xFF1E1B4B))),
              const SizedBox(height: 2),
              Text(_isVoiceMode ? 'VIDDHI' : 'NEEDHi', style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED), height: 1.0)),
              Text(l('legal_ai', _selectedLanguage), style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16, color: Color(0xFF1E1B4B))),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.language_rounded, size: 14, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 6),
                  Text(_selectedLanguage, style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
          const SizedBox(width: 10),
          // Right: Floating Orb
          Expanded(
            flex: 3,
            child: AnimatedBuilder(
              animation: _floatOffset,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _floatOffset.value),
                child: AnimatedBuilder(
                  animation: _orbAnim,
                  builder: (_, __) => Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color.lerp(const Color(0xFF7C3AED), const Color(0xFF3B82F6), _orbAnim.value)!,
                          Color.lerp(const Color(0xFFEC4899), const Color(0xFFF59E0B), _orbAnim.value)!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.4), blurRadius: 20),
                      ],
                    ),
                    child: Center(
                      child: Icon(_isVoiceMode ? Icons.waves_rounded : Icons.auto_awesome_rounded, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),

        const SizedBox(height: 30),
        
        // Language Selector
        Text(l('choose_lang', _selectedLanguage), style: const TextStyle(color: Color(0xFF1E1B4B), fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _kLanguages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final lang = _kLanguages[i];
              final sel = _selectedLanguage == lang;
              return GestureDetector(
                onTap: () => setState(() => _selectedLanguage = lang),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF7C3AED) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? const Color(0xFF7C3AED) : const Color(0xFFE5E7EB)),
                    boxShadow: sel ? [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 8)] : [],
                  ),
                  child: Center(
                    child: Text(lang, style: TextStyle(color: sel ? Colors.white : const Color(0xFF6B7280), fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),
        Text(l('popular', _selectedLanguage), style: const TextStyle(color: Color(0xFF1E1B4B), fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 12),

        // Localized Quick suggestion grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: List.generate(6, (index) {
            final qKey = 'q${index + 1}';
            final pKey = 'p${index + 1}';
            return _QuickChip(
              label: l(qKey, _selectedLanguage),
              onTap: () => _sendChatMessage(l(pKey, _selectedLanguage)),
            );
          }),
        ),
        
        const SizedBox(height: 30),
        _buildFactCard(),
        const SizedBox(height: 20),
        _buildVoiceTip(),
        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _buildFactCard() {
    final facts = [
      "The Indian Constitution is the longest written constitution of any sovereign country in the world.",
      "The original Constitution was handwritten by Prem Behari Narain Raizada in flowing italic style.",
      "The Preamble to our Constitution was inspired by the Preamble of the USA's Constitution.",
      "Dr. B.R. Ambedkar is known as the Father of the Indian Constitution.",
      "It took 2 years, 11 months, and 18 days to complete the Constitution of India."
    ];
    final randomFact = facts[Random().nextInt(facts.length)];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 8),
          Text(l('fact', _selectedLanguage), style: const TextStyle(color: Color(0xFF1E1B4B), fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
        const SizedBox(height: 10),
        Text(
          randomFact,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, height: 1.5, fontStyle: FontStyle.italic),
        ),
      ]),
    );
  }

  Widget _buildVoiceTip() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFEDE9FE), Color(0xFFDBEAFE)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(children: [
      const Text('🎤', style: TextStyle(fontSize: 28)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l('voice_mode', _selectedLanguage),
            style: const TextStyle(color: Color(0xFF4C1D95), fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 2),
        Text(l('hands_free', _selectedLanguage),
            style: TextStyle(color: const Color(0xFF4C1D95).withOpacity(0.7), fontSize: 11, fontFamily: 'Inter')),
      ])),
      GestureDetector(
        onTap: () {
          setState(() { _isVoiceMode = true; });
          _toggleListening();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(l('try_now', _selectedLanguage), style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        ),
      ),
    ]),
  );

  // ── Chat View ────────────────────────────────────────────────────────────
  Widget _buildChatView() => ListView.builder(
    controller: _scrollController,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    itemCount: _messages.length + (_isBotTyping ? 1 : 0),
    itemBuilder: (ctx, i) {
      if (i == _messages.length) return _buildTypingIndicator();
      return _buildBubble(_messages[i]);
    },
  );

  // ── Chat Bubble ──────────────────────────────────────────────────────────
  Widget _buildBubble(_Msg msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 32 : 0,
        right: isUser ? 0 : 32,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUser) ...[
                const Icon(Icons.smart_toy_rounded, size: 12, color: Color(0xFF7C3AED)),
                const SizedBox(width: 4),
                Text(msg.isVoice ? 'VIDDHI' : 'NEEDHi',
                    style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              ] else ...[
                const Text('You', style: TextStyle(color: Color(0xFF4B5563), fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.person_rounded, size: 12, color: Color(0xFF4B5563)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF7C3AED) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isUser ? const Color(0xFF7C3AED).withOpacity(0.15) : Colors.black.withOpacity(0.04),
                  blurRadius: 8, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              isUser ? msg.text : _stripMarkdown(msg.text),
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF1E1B4B),
                fontSize: 14, height: 1.4, fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Typing Indicator ─────────────────────────────────────────────────────
  Widget _buildTypingIndicator() => Padding(
    padding: const EdgeInsets.only(left: 46, bottom: 10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _DotWave(color: const Color(0xFF7C3AED), delay: 0),
        const SizedBox(width: 4),
        _DotWave(color: const Color(0xFF3B82F6), delay: 200),
        const SizedBox(width: 4),
        _DotWave(color: const Color(0xFFEC4899), delay: 400),
        const SizedBox(width: 10),
        Text(_isVoiceMode ? 'VIDDHI ${l('thinking', _selectedLanguage)}' : 'NEEDHi ${l('thinking', _selectedLanguage)}',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontFamily: 'Inter')),
      ]),
    ),
  );

  // ── Voice Listening Bar ──────────────────────────────────────────────────
  Widget _buildVoiceListeningBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFD1FAE5),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
    ),
    child: Row(children: [
      AnimatedBuilder(
        animation: _micScale,
        builder: (_, __) => Transform.scale(
          scale: _micScale.value,
          child: const Icon(Icons.mic_rounded, color: Color(0xFF059669), size: 18),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            _voiceText.isEmpty ? l('listening', _selectedLanguage) : _voiceText,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: _voiceText.isEmpty ? const Color(0xFF6B7280) : const Color(0xFF1E1B4B),
              fontSize: 13, fontFamily: 'Inter',
              fontStyle: _voiceText.isEmpty ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ),
    ]),
  );

  // ── Input Bar ────────────────────────────────────────────────────────────
  Widget _buildInputBar() => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
    ),
    child: Row(children: [
      // Mic button
      GestureDetector(
        onTap: _toggleListening,
        child: AnimatedBuilder(
          animation: _micScale,
          builder: (_, __) => Transform.scale(
            scale: _isListening ? _micScale.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _isListening ? const Color(0xFF059669) : const Color(0xFFF0F0F8),
                shape: BoxShape.circle,
                boxShadow: _isListening
                    ? [BoxShadow(color: const Color(0xFF059669).withOpacity(0.4), blurRadius: 12)]
                    : [],
              ),
              child: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: _isListening ? Colors.white : const Color(0xFF6B7280),
                size: 22,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      // Text field
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F8),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: Color(0xFF1E1B4B), fontSize: 14, fontFamily: 'Inter'),
            onSubmitted: (_) => _sendChatMessage(),
            maxLines: null,
            decoration: InputDecoration(
              hintText: _isVoiceMode ? l('type_here', _selectedLanguage) : l('ask', _selectedLanguage),
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      // Send button
      GestureDetector(
        onTap: _sendChatMessage,
        child: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.4), blurRadius: 10)],
          ),
          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        ),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Chip Widget
// ─────────────────────────────────────────────────────────────────────────────
class _QuickChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});
  @override State<_QuickChip> createState() => _QuickChipState();
}
class _QuickChipState extends State<_QuickChip> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _pressed ? const Color(0xFF7C3AED) : const Color(0xFFE5E7EB)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF4C1D95),
                  fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Typing Dot
// ─────────────────────────────────────────────────────────────────────────────
class _DotWave extends StatefulWidget {
  final Color color;
  final int delay;
  const _DotWave({required this.color, required this.delay});
  @override State<_DotWave> createState() => _DotWaveState();
}
class _DotWaveState extends State<_DotWave> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: -6).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Transform.translate(
      offset: Offset(0, _anim.value),
      child: Container(width: 8, height: 8, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Gemini-like Animated Orb
// ─────────────────────────────────────────────────────────────────────────────
class _GeminiOrb extends StatefulWidget {
  final bool visible;
  const _GeminiOrb({required this.visible});

  @override
  State<_GeminiOrb> createState() => _GeminiOrbState();
}

class _GeminiOrbState extends State<_GeminiOrb> with SingleTickerProviderStateMixin {
  late AnimationController _rotationCtrl;

  @override
  void initState() {
    super.initState();
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedScale(
        scale: widget.visible ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        child: Container(
          width: 140,
          height: 140,
          child: AnimatedBuilder(
            animation: _rotationCtrl,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer soft glow
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Animated Gradient Core
                  Transform.rotate(
                    angle: _rotationCtrl.value * 2 * pi,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.8),
                            const Color(0xFF8B5CF6).withOpacity(0.8),
                            const Color(0xFFEC4899).withOpacity(0.8),
                            const Color(0xFF3B82F6).withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Inner "Liquid" Blur effect
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                  // Center highlight
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
