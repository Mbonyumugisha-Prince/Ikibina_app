import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/locale_provider.dart';
import '../../models/group_model.dart';
import '../../core/constants/app_constants.dart';
import '../home/admin_home_screen.dart';

const _bg     = Color(0xFFF5F5F5);
const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _hint   = Color(0xFFBBBBBB);
const _border = Color(0xFFE0E0E0);

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController        = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController      = TextEditingController();
  String _frequency = 'Monthly';
  late String _inviteCode;

  @override
  void initState() {
    super.initState();
    _inviteCode = _generateCode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand  = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _submit() async {
    final s = context.read<LocaleProvider>().strings;
    final name   = _nameController.text.trim();
    final amount = _amountController.text.trim();
    if (name.isEmpty || amount.isEmpty) {
      _snack(s.fillAllRequiredFields);
      return;
    }
    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      _snack(s.invalidContributionAmount);
      return;
    }

    final auth  = context.read<AuthProvider>();
    final group = context.read<GroupProvider>();

    final newGroup = GroupModel(
      id: const Uuid().v4(),
      name: name,
      description: _descriptionController.text.trim(),
      createdBy: auth.user!.id,
      adminId: auth.user!.id,
      inviteCode: _inviteCode,
      contributionAmount: parsedAmount,
      contributionFrequency: _frequency,
      createdAt: DateTime.now(),
    );

    final success = await group.createGroup(newGroup, auth.user!.id);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        (_) => false,
      );
    } else {
      _snack(group.error ?? s.failedToCreateGroup);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.sora()),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final loading = context.watch<GroupProvider>().loading;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: _ink),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              Text(
                s.createGroupTitle,
                style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.createGroupSubtitle,
                style: GoogleFonts.sora(fontSize: 14, color: _grey),
              ),
              const SizedBox(height: 36),

              // Invite code display
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.groupInviteCode,
                            style: GoogleFonts.sora(
                              fontSize: 11,
                              color: _grey,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _inviteCode,
                            style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _inviteCode));
                        _snack(s.codeCopiedMessage);
                      },
                      icon: const Icon(Icons.copy_outlined,
                          color: _ink, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.shareCodeWithMembers,
                style: GoogleFonts.sora(fontSize: 12, color: _grey),
              ),
              const SizedBox(height: 24),

              _field(s.groupNameLabel, s.groupNameHint,
                  Icons.group_outlined, _nameController),
              const SizedBox(height: 16),
              _field(s.descriptionLabel, s.descriptionHint,
                  Icons.description_outlined, _descriptionController,
                  maxLines: 2),
              const SizedBox(height: 16),
              _field(s.contributionAmountLabel, '0',
                  Icons.payments_outlined, _amountController,
                  isNumber: true),
              const SizedBox(height: 16),

              Text(
                s.frequencyLabel,
                style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _frequency,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: BorderRadius.circular(12),
                    style: GoogleFonts.sora(fontSize: 15, color: _ink),
                    items: AppConstants.contributionFrequencies
                        .map((f) => DropdownMenuItem(
                            value: f, child: Text(f)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _frequency = v!),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ink,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _ink.withValues(alpha: 0.45),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          s.createGroupButton,
                          style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    String hint,
    IconData icon,
    TextEditingController ctrl, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sora(
              fontSize: 13, fontWeight: FontWeight.w600, color: _ink),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType:
              isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.sora(fontSize: 15, color: _ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.sora(color: _hint, fontSize: 14),
            prefixIcon: Icon(icon, color: _hint, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
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
      ],
    );
  }
}
