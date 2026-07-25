import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:login_signup/theme/app_colors.dart';
import 'package:login_signup/widgets/falling_symbols.dart';
import 'NewsDetailScreen.dart';
import 'package:get/get.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _articles = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isTranslating = false;
  final String _apiKey = 'cc88834d0657444cbcf861e461dbb4f5';
  String _selectedNewsLang = 'en';

  // Cache: original text → translated text
  final Map<String, String> _translationCache = {};

  // UI label translations
  static const Map<String, Map<String, String>> _labels = {
    'en': {
      'screenTitle': 'Rules of India News',
      'subtitle': 'Latest Legal Updates',
      'loading': 'Fetching latest news…',
      'translating': 'Translating articles…',
      'noNews': 'No civic news found today.',
      'error': 'Could not load news',
      'errorSub': 'Check your internet connection',
      'retry': 'Retry',
      'dialogTitle': 'Select Language',
    },
    'hi': {
      'screenTitle': 'भारत के अधिकार समाचार',
      'subtitle': 'नवीनतम कानूनी अपडेट',
      'loading': 'ताज़ा समाचार लाया जा रहा है…',
      'translating': 'अनुवाद हो रहा है…',
      'noNews': 'आज कोई नागरिक समाचार नहीं मिला।',
      'error': 'समाचार लोड नहीं हो सका',
      'errorSub': 'इंटरनेट कनेक्शन जांचें',
      'retry': 'पुनः प्रयास',
      'dialogTitle': 'भाषा चुनें',
    },
    'ta': {
      'screenTitle': 'இந்திய உரிமைகள் செய்திகள்',
      'subtitle': 'சமீபத்திய சட்ட புதுப்பிப்புகள்',
      'loading': 'புதிய செய்திகள் படிக்கப்படுகின்றன…',
      'translating': 'மொழிபெயர்க்கப்படுகிறது…',
      'noNews': 'இன்று குடிமை செய்திகள் இல்லை.',
      'error': 'செய்திகளை ஏற்ற முடியவில்லை',
      'errorSub': 'இணைய இணைப்பை சரிபாருங்கள்',
      'retry': 'மீண்டும் முயற்சி',
      'dialogTitle': 'மொழியை தேர்வு செய்யவும்',
    },
    'te': {
      'screenTitle': 'భారత హక్కుల వార్తలు',
      'subtitle': 'తాజా చట్టపరమైన అప్‌డేట్‌లు',
      'loading': 'తాజా వార్తలు తీసుకుంటున్నారు…',
      'translating': 'అనువదిస్తోంది…',
      'noNews': 'నేడు పౌర వార్తలు కనుగొనబడలేదు.',
      'error': 'వార్తలు లోడ్ కాలేదు',
      'errorSub': 'ఇంటర్నెట్ కనెక్షన్ తనిఖీ చేయండి',
      'retry': 'మళ్ళీ ప్రయత్నించు',
      'dialogTitle': 'భాష ఎంచుకోండి',
    },
    'mr': {
      'screenTitle': 'भारताचे अधिकार बातम्या',
      'subtitle': 'ताज्या कायदेशीर अपडेट्स',
      'loading': 'ताज्या बातम्या आणत आहे…',
      'translating': 'भाषांतर होत आहे…',
      'noNews': 'आज नागरिक बातम्या सापडल्या नाहीत.',
      'error': 'बातम्या लोड होऊ शकल्या नाहीत',
      'errorSub': 'इंटरनेट कनेक्शन तपासा',
      'retry': 'पुन्हा प्रयत्न करा',
      'dialogTitle': 'भाषा निवडा',
    },
    'ml': {
      'screenTitle': 'ഇന്ത്യൻ അവകാശ വാർത്തകൾ',
      'subtitle': 'ഏറ്റവും പുതിയ നിയമ അപ്‌ഡേറ്റുകൾ',
      'loading': 'പുതിയ വാർത്തകൾ ലോഡ് ചെയ്യുന്നു…',
      'translating': 'വിവർത്തനം ചെയ്യുന്നു…',
      'noNews': 'ഇന്ന് പൗര വാർത്തകൾ കണ്ടെത്തിയില്ല.',
      'error': 'വാർത്തകൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല',
      'errorSub': 'ഇന്റർനെറ്റ് കണക്ഷൻ പരിശോധിക്കുക',
      'retry': 'വീണ്ടും ശ്രമിക്കുക',
      'dialogTitle': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
    },
    'kn': {
      'screenTitle': 'ಭಾರತೀಯ ಹಕ್ಕುಗಳ ಸುದ್ದಿ',
      'subtitle': 'ಇತ್ತೀಚಿನ ಕಾನೂನು ನವೀಕರಣಗಳು',
      'loading': 'ತಾಜಾ ಸುದ್ದಿ ತರಲಾಗುತ್ತಿದೆ…',
      'translating': 'ಅನುವಾದಿಸಲಾಗುತ್ತಿದೆ…',
      'noNews': 'ಇಂದು ನಾಗರಿಕ ಸುದ್ದಿ ಕಂಡುಬಂದಿಲ್ಲ.',
      'error': 'ಸುದ್ದಿ ಲೋಡ್ ಮಾಡಲಾಗಲಿಲ್ಲ',
      'errorSub': 'ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ',
      'retry': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
      'dialogTitle': 'ಭಾಷೆ ಆಯ್ಕೆ ಮಾಡಿ',
    },
    'bn': {
      'screenTitle': 'ভারতের অধিকার সংবাদ',
      'subtitle': 'সর্বশেষ আইনি আপডেট',
      'loading': 'সর্বশেষ সংবাদ আনা হচ্ছে…',
      'translating': 'অনুবাদ করা হচ্ছে…',
      'noNews': 'আজ কোনো নাগরিক সংবাদ পাওয়া যায়নি।',
      'error': 'সংবাদ লোড করা যায়নি',
      'errorSub': 'ইন্টারনেট সংযোগ পরীক্ষা করুন',
      'retry': 'আবার চেষ্টা করুন',
      'dialogTitle': 'ভাষা নির্বাচন করুন',
    },
  };

  String _t(String key) => _labels[_selectedNewsLang]?[key] ?? _labels['en']![key]!;

  @override
  void initState() {
    super.initState();
    
    // Sync with global locale
    final langCode = Get.locale?.languageCode;
    if (langCode != null && _labels.containsKey(langCode)) {
      _selectedNewsLang = langCode;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (langCode == null || langCode == 'en') {
        _showLanguageDialog();
      } else {
        fetchNews();
      }
    });
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_t('dialogTitle'), style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangOption('English', 'en'),
            _buildLangOption('हिंदी', 'hi'),
            _buildLangOption('தமிழ்', 'ta'),
            _buildLangOption('తెలుగు', 'te'),
            _buildLangOption('मराठी', 'mr'),
            _buildLangOption('മലയാളം', 'ml'),
            _buildLangOption('ಕನ್ನಡ', 'kn'),
            _buildLangOption('বাংলা', 'bn'),
          ],
        ),
      ),
    );
  }

  Widget _buildLangOption(String label, String code) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 15)),
      onTap: () {
        setState(() => _selectedNewsLang = code);
        Navigator.pop(context);
        fetchNews();
      },
      trailing: _selectedNewsLang == code ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
    );
  }

  /// Translates a single text using MyMemory free API (no key needed, 10k words/day free)
  Future<String> _translateText(String text, String targetLang) async {
    if (targetLang == 'en' || text.trim().isEmpty) return text;
    final cacheKey = '$targetLang:$text';
    if (_translationCache.containsKey(cacheKey)) return _translationCache[cacheKey]!;

    try {
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|$targetLang',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final translated = data['responseData']?['translatedText'] as String? ?? text;
        _translationCache[cacheKey] = translated;
        return translated;
      }
    } catch (_) {}
    return text; // fallback to English on error
  }

  Future<void> fetchNews() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isTranslating = false;
      _translationCache.clear();
      _articles = [];
    });

    // Single national India civic news query — same articles for all languages
    const String finalQuery =
        'India AND (parliament OR "supreme court" OR law OR constitution OR rights OR legal OR government OR bill OR judiciary)';

    final url = Uri.parse(
      'https://newsapi.org/v2/everything?q=${Uri.encodeComponent(finalQuery)}&language=en&sortBy=publishedAt&pageSize=20&apiKey=$_apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final allArticles = (data['articles'] as List<dynamic>? ?? []);
        final filtered = allArticles.where((a) =>
          a['title'] != null &&
          a['title'] != '[Removed]' &&
          a['urlToImage'] != null
        ).toList();

        _articles = filtered; // Assign first so translation has data to work on
        // If regional language selected, wait for at least first 3 articles to translate before showing
        if (_selectedNewsLang != 'en') {
          await _translateArticles(initial: true);
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() { _isLoading = false; _hasError = true; });
      }
    } catch (e) {
      setState(() { _isLoading = false; _hasError = true; });
    }
  }

  /// Translates article titles and descriptions, updating UI progressively
  Future<void> _translateArticles({bool initial = false}) async {
    if (_selectedNewsLang == 'en') return;
    setState(() => _isTranslating = true);

    // If initial, process a local copy and then set _articles to avoid flashing English
    List<dynamic> targetArticles = List.from(_articles);
    
    // If targetArticles is empty (initial fetch), we need to wait for fetchNews to provide them
    // But fetchNews calls this with await, so it should be fine.
    
    for (int i = 0; i < _articles.length; i++) {
      if (!mounted) break;
      final article = _articles[i];
      final title = article['title'] as String? ?? '';
      final desc = article['description'] as String? ?? '';

      final translatedTitle = await _translateText(title, _selectedNewsLang);
      final translatedDesc = desc.isNotEmpty ? await _translateText(desc, _selectedNewsLang) : '';

      if (!mounted) break;
      setState(() {
        _articles[i] = {
          ...Map<String, dynamic>.from(article),
          'title': translatedTitle,
          'description': translatedDesc.isNotEmpty ? translatedDesc : null,
        };
        // If we are in initial loading, once we have 3 translated, we show the list
        if (initial && i == 2) {
          _isLoading = false;
        }
      });
      
      // If we finished all articles and it was less than 3, still show the list
      if (initial && i == _articles.length - 1 && _isLoading) {
        setState(() => _isLoading = false);
      }
    }

    if (mounted) setState(() => _isTranslating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.newspaper_rounded, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(_t('screenTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w800, fontSize: 13)),
              Text(_isLoading ? '...' : _isTranslating ? _t('translating') : _t('subtitle'),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 9, fontFamily: 'Inter')),
            ]),
          ),
        ]),
        actions: [
          if (_isTranslating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
            ),
          IconButton(
            icon: const Icon(Icons.language_rounded, color: AppColors.primary),
            onPressed: _showLanguageDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: fetchNews,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Stack(children: [
        const FallingSymbolsBackground(
          symbols: ['📰', '🗞️', '📢', '🔎', '📝', '🏛️'],
          count: 12,
          opacity: 0.26,
        ),
        _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                  const SizedBox(height: 16),
                  Text(_t('loading'), style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter')),
                ],
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      Text(_t('error'),
                          style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'PlusJakartaSans', fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(_t('errorSub'),
                          style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter', fontSize: 13)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: fetchNews,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(_t('retry')),
                      ),
                    ],
                  ),
                )
              : _articles.isEmpty
                  ? Center(
                      child: Text(_t('noNews'),
                          style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter')),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _articles.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _buildNewsCard(context, _articles[index]);
                      },
                    ),
      ]),
    );
  }

  Widget _buildNewsCard(BuildContext context, dynamic article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewsDetailScreen(
              article: article,
              targetLanguage: _selectedNewsLang == 'en' ? 'English' : 
                _selectedNewsLang == 'ta' ? 'Tamil' :
                _selectedNewsLang == 'hi' ? 'Hindi' :
                _selectedNewsLang == 'te' ? 'Telugu' :
                _selectedNewsLang == 'mr' ? 'Marathi' :
                _selectedNewsLang == 'ml' ? 'Malayalam' :
                _selectedNewsLang == 'kn' ? 'Kannada' : 'Bengali',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article['urlToImage'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                child: Image.network(
                  article['urlToImage'],
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Source badge
                if (article['source']?['name'] != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      article['source']['name'],
                      style: const TextStyle(color: AppColors.primary, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                    ),
                  ),
                // Title
                Text(
                  article['title'] ?? 'No Title',
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14,
                      fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (article['description'] != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    article['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Inter', height: 1.4),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.open_in_new_rounded, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      article['source']?['name'] ?? 'Read more',
                      style: const TextStyle(color: AppColors.primary, fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open article')),
      );
    }
  }
}
