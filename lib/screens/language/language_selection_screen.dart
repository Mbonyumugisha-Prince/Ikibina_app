import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/language_option.dart';
import '../../providers/locale_provider.dart';
import '../auth/login_screen.dart';

const _ink = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

// ─────────────────────────────────────────
//  LANGUAGE SELECTION SCREEN
// ─────────────────────────────────────────
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<LanguageOption> _languages = const [
    LanguageOption(flag: '🇬🇧', name: 'English', country: 'United Kingdom'),
    LanguageOption(flag: '🇷🇼', name: 'Ikinyarwanda', country: 'Rwanda'),
  ];

  late String _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Initialize from whatever language is currently active
    _selected =
        context.read<LocaleProvider>().languageName;
  }

  Future<void> _saveAndContinue() async {
    setState(() => _saving = true);
    // Switch the app locale immediately
    await context.read<LocaleProvider>().setLanguage(_selected);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildContent(s)),
            _buildSaveButton(s),
            _buildBottomBar(s),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(s) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTitle(s),
          ..._languages.map(_buildLanguageTile),
        ],
      ),
    );
  }

  Widget _buildTitle(s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 100, 24, 48),
      child: Column(
        children: [
          Text(
            s.chooseLanguage,
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            s.chooseLanguageSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.sora(
              fontSize: 14,
              color: _grey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(LanguageOption lang) {
    final isSelected = _selected == lang.name;
    return GestureDetector(
      onTap: () => setState(() => _selected = lang.name),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _ink : const Color(0xFFE0E0E0),
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag circle
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(lang.flag,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),

            // Name + country
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.name,
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lang.country,
                    style: GoogleFonts.sora(fontSize: 13, color: _grey),
                  ),
                ],
              ),
            ),

            // Radio / checkmark
            isSelected
                ? Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _ink,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 14),
                  )
                : Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFCCCCCC),
                        width: 1.5,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _saving ? null : _saveAndContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: _ink,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _ink.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  s.savePreference,
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.arrow_back, color: _ink, size: 22),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                s.language,
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}
