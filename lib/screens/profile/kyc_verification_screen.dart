import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/locale_provider.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String _selectedIdType = 'National ID';
  Uint8List? _idFrontBytes;
  Uint8List? _idBackBytes;
  Uint8List? _selfieBytes;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _idNumberController.dispose();
    _dateOfBirthController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(void Function(Uint8List bytes) setBytes) async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1200,
    );

    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      setBytes(bytes);
    });
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 21, now.month, now.day);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );

    if (selected == null) return;
    _dateOfBirthController.text =
        '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submitKyc() async {
    final localeProvider = context.read<LocaleProvider>();
    final isEnglish = localeProvider.locale.languageCode == 'en';

    if (!_formKey.currentState!.validate()) return;

    if (_idFrontBytes == null || _idBackBytes == null || _selfieBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEnglish
                ? 'Please upload ID front, ID back, and a selfie photo.'
                : 'Shyiraho ifoto yimbere ninyuma ya ID, hamwe na selfie.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEnglish
              ? 'KYC application submitted. We will review it shortly.'
              : 'Ubusabe bwa KYC bwoherejwe. Turabusuzuma vuba.',
        ),
      ),
    );
  }

  Widget _buildUploadTile({
    required String title,
    required Uint8List? imageBytes,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64,
                height: 64,
                color: const Color(0xFFF2F4F7),
                child: imageBytes == null
                    ? const Icon(Icons.add_a_photo_outlined,
                        color: Colors.black54)
                    : Image.memory(imageBytes, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final s = localeProvider.strings;
    final isEnglish = localeProvider.locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          s.kycVerification,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isSubmitted
                            ? const Color(0xFFECFDF3)
                            : const Color(0xFFFFF8E6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _isSubmitted
                            ? (isEnglish ? 'Under Review' : 'Biracyasuzumwa')
                            : (isEnglish
                                ? 'Not Submitted'
                                : 'Ntabwo byoherejwe'),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isSubmitted
                              ? const Color(0xFF027A48)
                              : const Color(0xFFB54708),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEnglish
                            ? 'Submit your details and supporting documents for account verification.'
                            : 'Ohereza amakuru yawe ninyandiko zemeza kugira ngo konti isuzumwe.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isEnglish ? 'Identity Details' : 'Amakuru yumwirondoro',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedIdType,
                items: const [
                  DropdownMenuItem(
                      value: 'National ID', child: Text('National ID')),
                  DropdownMenuItem(value: 'Passport', child: Text('Passport')),
                  DropdownMenuItem(
                      value: 'Driver License', child: Text('Driver License')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedIdType = value);
                },
                decoration: _inputDecoration(
                    isEnglish ? 'Document Type' : 'Ubwoko bwinyandiko'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idNumberController,
                decoration:
                    _inputDecoration(isEnglish ? 'ID Number' : 'Nimero ya ID'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isEnglish
                        ? 'ID number is required'
                        : 'Nimero ya ID irakenewe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateOfBirthController,
                readOnly: true,
                onTap: _selectDateOfBirth,
                decoration: _inputDecoration(
                        isEnglish ? 'Date of Birth' : 'Itariki yamavuko')
                    .copyWith(
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isEnglish
                        ? 'Date of birth is required'
                        : 'Itariki yamavuko irakenewe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _countryController,
                decoration: _inputDecoration(
                    isEnglish ? 'Country of Issue' : 'Igihugu cyatanze ID'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isEnglish
                        ? 'Country is required'
                        : 'Igihugu kirakenewe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                decoration: _inputDecoration(
                    isEnglish ? 'Residential Address' : 'Aho utuye'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isEnglish
                        ? 'Address is required'
                        : 'Aho utuye harakenewe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                isEnglish ? 'Document Upload' : 'Gushyiraho Inyandiko',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildUploadTile(
                title: isEnglish ? 'Upload ID Front' : 'Shyiraho Imbere ya ID',
                imageBytes: _idFrontBytes,
                onTap: () => _pickDocument((bytes) => _idFrontBytes = bytes),
              ),
              const SizedBox(height: 10),
              _buildUploadTile(
                title: isEnglish ? 'Upload ID Back' : 'Shyiraho Inyuma ya ID',
                imageBytes: _idBackBytes,
                onTap: () => _pickDocument((bytes) => _idBackBytes = bytes),
              ),
              const SizedBox(height: 10),
              _buildUploadTile(
                title: isEnglish ? 'Upload Selfie' : 'Shyiraho Selfie',
                imageBytes: _selfieBytes,
                onTap: () => _pickDocument((bytes) => _selfieBytes = bytes),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitKyc,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEnglish
                              ? 'Submit for Verification'
                              : 'Ohereza Kugira ngo Bigenzurwe',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: Colors.black54),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black87),
      ),
    );
  }
}
