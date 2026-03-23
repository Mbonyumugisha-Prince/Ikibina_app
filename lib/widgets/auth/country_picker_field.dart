import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/countries.dart';

const _ink = Color(0xFF1A1A1A);
const _hint = Color(0xFFBBBBBB);
const _border = Color(0xFFE0E0E0);

// ─────────────────────────────────────────
//  COUNTRY PICKER + PHONE INPUT ROW
// ─────────────────────────────────────────
class CountryPickerField extends StatefulWidget {
  final TextEditingController phoneController;
  final ValueChanged<String>? onCountryChanged; // returns full code e.g. "+250"

  const CountryPickerField({
    super.key,
    required this.phoneController,
    this.onCountryChanged,
  });

  @override
  State<CountryPickerField> createState() => _CountryPickerFieldState();
}

class _CountryPickerFieldState extends State<CountryPickerField> {
  String _flag = '🇷🇼';
  String _code = '+250';

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CountrySheet(
        selected: _code,
        onSelect: (flag, code) {
          setState(() {
            _flag = flag;
            _code = code;
          });
          widget.onCountryChanged?.call(code);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Country code button ──
        GestureDetector(
          onTap: _showPicker,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  _code,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down,
                    size: 18, color: Color(0xFF888888)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // ── Phone number input ──
        Expanded(
          child: TextField(
            controller: widget.phoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.sora(fontSize: 15),
            decoration: InputDecoration(
              hintText: '788 123 456',
              hintStyle: GoogleFonts.sora(color: _hint),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _ink, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  COUNTRY BOTTOM SHEET
// ─────────────────────────────────────────
class _CountrySheet extends StatelessWidget {
  final String selected;
  final void Function(String flag, String code) onSelect;

  const _CountrySheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            // ── Handle bar ──
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Country',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ── Scrollable list ──
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  ...kCountries.map((c) {
                    final isSelected = c['code'] == selected;
                    return ListTile(
                      leading: Text(c['flag']!,
                          style: const TextStyle(fontSize: 24)),
                      title: Text(c['name']!,
                          style: GoogleFonts.sora(fontSize: 14)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            c['code']!,
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check, size: 18, color: _ink),
                          ],
                        ],
                      ),
                      onTap: () {
                        onSelect(c['flag']!, c['code']!);
                        Navigator.pop(context);
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
