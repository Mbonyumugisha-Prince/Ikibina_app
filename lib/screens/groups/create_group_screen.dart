import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/locale_provider.dart';
import '../../models/group_model.dart';
import '../../core/constants/app_constants.dart';
import '../../services/cloudinary_service.dart';
import '../home/admin_home_screen.dart';

const _bg     = Color(0xFFF5F5F5);
const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _hint   = Color(0xFFBBBBBB);
const _border = Color(0xFFE0E0E0);
const _accent = Color(0xFF1A1A1A);

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  // ── Common fields ──────────────────────────────────────────────
  final _nameCtrl        = TextEditingController();
  final _descCtrl        = TextEditingController();
  late String _inviteCode;
  String _groupType      = AppConstants.groupTypeIkimina;
  File? _imageFile;
  Uint8List? _imageBytes;
  bool _uploadingImage   = false;

  // ── Ikimina fields ─────────────────────────────────────────────
  final _amountCtrl = TextEditingController();
  String _frequency = 'Monthly';
  String _duration  = '3 months';

  // ── Goal / milestone fields ────────────────────────────────────
  final List<_MilestoneEntry> _milestones = [
    _MilestoneEntry(),
    _MilestoneEntry(),
    _MilestoneEntry(),
  ];

  @override
  void initState() {
    super.initState();
    _inviteCode = _generateCode();
    // Attach listeners to the initial milestone amount controllers
    for (final m in _milestones) {
      m.amountCtrl.addListener(_refreshTotal);
    }
  }

  void _refreshTotal() => setState(() {});

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    for (final m in _milestones) {
      m.dispose();
    }
    super.dispose();
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand  = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  // ── Image picker ───────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageFile  = File(picked.path);
        _imageBytes = bytes;
      });
    }
  }

  Future<String?> _uploadImage(String groupId) async {
    if (_imageBytes == null) return null;
    setState(() => _uploadingImage = true);
    try {
      return await CloudinaryService.uploadImage(_imageBytes!, groupId);
    } catch (e) {
      if (mounted) {
        _snack('Photo upload failed: ${e.toString()}. Group will be created without a photo.');
      }
      return null;
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  // ── Milestone helpers ──────────────────────────────────────────
  void _addMilestone() {
    if (_milestones.length >= 5) return;
    final entry = _MilestoneEntry();
    entry.amountCtrl.addListener(_refreshTotal);
    setState(() => _milestones.add(entry));
  }

  void _removeMilestone(int index) {
    if (_milestones.length <= 3) return;
    setState(() => _milestones.removeAt(index));
  }

  bool _validateMilestones() {
    for (final m in _milestones) {
      if (m.nameCtrl.text.trim().isEmpty) return false;
      final v = double.tryParse(m.amountCtrl.text.trim());
      if (v == null || v <= 0) return false;
    }
    return true;
  }

  List<MilestoneModel> _buildMilestones() => _milestones
      .map((m) => MilestoneModel(
            name: m.nameCtrl.text.trim(),
            targetAmount: double.parse(m.amountCtrl.text.trim()),
          ))
      .toList();

  // ── Submit ─────────────────────────────────────────────────────
  Future<void> _submit() async {
    final s    = context.read<LocaleProvider>().strings;
    final name = _nameCtrl.text.trim();

    if (name.isEmpty) {
      _snack('Please enter a group name.');
      return;
    }

    if (_groupType == AppConstants.groupTypeIkimina) {
      final amount = double.tryParse(_amountCtrl.text.trim());
      if (amount == null || amount <= 0) {
        _snack(s.invalidContributionAmount);
        return;
      }
    } else {
      if (!_validateMilestones()) {
        _snack('Please fill in all milestone names and amounts (must be > 0).');
        return;
      }
    }

    final auth  = context.read<AuthProvider>();
    final group = context.read<GroupProvider>();
    final id    = const Uuid().v4();

    // Upload image first if selected
    final imageUrl = _imageBytes != null ? await _uploadImage(id) : null;

    final milestones = _groupType == AppConstants.groupTypeGoal
        ? _buildMilestones()
        : <MilestoneModel>[];

    final parsedAmount = _groupType == AppConstants.groupTypeIkimina
        ? double.parse(_amountCtrl.text.trim())
        : 0.0;

    final newGroup = GroupModel(
      id: id,
      name: name,
      description: _descCtrl.text.trim(),
      createdBy: auth.user!.id,
      adminId: auth.user!.id,
      inviteCode: _inviteCode,
      groupType: _groupType,
      contributionAmount: parsedAmount,
      contributionFrequency:
          _groupType == AppConstants.groupTypeGoal ? '' : _frequency,
      duration: _duration,
      milestones: milestones,
      imageUrl: imageUrl,
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.sora()),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s       = context.watch<LocaleProvider>().strings;
    final loading = context.watch<GroupProvider>().loading || _uploadingImage;

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
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 6),
              Text(s.createGroupSubtitle,
                  style: GoogleFonts.sora(fontSize: 14, color: _grey)),
              const SizedBox(height: 28),

              // ── Group Type Selector ──────────────────────────
              _SectionLabel('Group Type'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TypeCard(
                      title: 'Ikimina',
                      subtitle: 'Fixed contributions\n& loans',
                      icon: Icons.savings_outlined,
                      selected: _groupType == AppConstants.groupTypeIkimina,
                      onTap: () => setState(
                          () => _groupType = AppConstants.groupTypeIkimina),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeCard(
                      title: 'Goal Group',
                      subtitle: 'Save towards\na shared goal',
                      icon: Icons.flag_outlined,
                      selected: _groupType == AppConstants.groupTypeGoal,
                      onTap: () => setState(
                          () => _groupType = AppConstants.groupTypeGoal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Profile Picture ──────────────────────────────
              _SectionLabel('Group Profile Picture'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border, width: 1.5),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(_imageFile!, fit: BoxFit.cover),
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _ink,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined,
                                color: _grey, size: 32),
                            const SizedBox(width: 12),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upload Photo',
                                    style: GoogleFonts.sora(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _ink)),
                                Text('Tap to choose from gallery',
                                    style: GoogleFonts.sora(
                                        fontSize: 12, color: _grey)),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Invite Code ──────────────────────────────────
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
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _inviteCode,
                            style: GoogleFonts.sora(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                                letterSpacing: 4),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _inviteCode));
                        _snack(s.codeCopiedMessage);
                      },
                      icon: const Icon(Icons.copy_outlined,
                          color: _ink, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(s.shareCodeWithMembers,
                  style: GoogleFonts.sora(fontSize: 12, color: _grey)),
              const SizedBox(height: 24),

              // ── Common fields ────────────────────────────────
              _field(s.groupNameLabel, s.groupNameHint,
                  Icons.group_outlined, _nameCtrl),
              const SizedBox(height: 16),
              _field(s.descriptionLabel, s.descriptionHint,
                  Icons.description_outlined, _descCtrl,
                  maxLines: 2),
              const SizedBox(height: 24),

              // ── Ikimina-specific fields ──────────────────────
              if (_groupType == AppConstants.groupTypeIkimina) ...[
                _field(s.contributionAmountLabel, '0',
                    Icons.payments_outlined, _amountCtrl,
                    isNumber: true),
                const SizedBox(height: 16),

                _SectionLabel(s.frequencyLabel),
                const SizedBox(height: 8),
                _dropdown(
                  value: _frequency,
                  items: AppConstants.contributionFrequencies,
                  onChanged: (v) => setState(() => _frequency = v!),
                ),
                const SizedBox(height: 16),

                _SectionLabel('Group Duration'),
                const SizedBox(height: 8),
                _dropdown(
                  value: _duration,
                  items: AppConstants.groupDurations,
                  onChanged: (v) => setState(() => _duration = v!),
                ),
                const SizedBox(height: 36),
              ],

              // ── Goal / Milestone fields ──────────────────────
              if (_groupType == AppConstants.groupTypeGoal) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionLabel('Milestones (${_milestones.length}/5)'),
                    if (_milestones.length < 5)
                      GestureDetector(
                        onTap: _addMilestone,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _ink,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text('Add',
                                  style: GoogleFonts.sora(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Add 3–5 milestones. The goal total is the sum of all milestone amounts.',
                  style: GoogleFonts.sora(fontSize: 12, color: _grey),
                ),
                const SizedBox(height: 14),

                ...List.generate(_milestones.length, (i) {
                  final m = _milestones[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _ink,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: GoogleFonts.sora(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Milestone ${i + 1}',
                              style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _ink),
                            ),
                            const Spacer(),
                            if (_milestones.length > 3)
                              GestureDetector(
                                onTap: () => _removeMilestone(i),
                                child: const Icon(Icons.close,
                                    color: _grey, size: 20),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: m.nameCtrl,
                          style: GoogleFonts.sora(
                              fontSize: 14, color: _ink),
                          decoration: _inlineDeco(
                              'Milestone name (e.g. Venue Booking)',
                              Icons.label_outline),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: m.amountCtrl,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.sora(
                              fontSize: 14, color: _ink),
                          decoration: _inlineDeco(
                              'Target amount (RWF)',
                              Icons.payments_outlined),
                        ),
                      ],
                    ),
                  );
                }),

                // Total goal preview
                if (_milestones.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _GoalTotalPreview(milestones: _milestones),
                ],
                const SizedBox(height: 28),
              ],

              // ── Create button ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _accent.withValues(alpha: 0.45),
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
                      : Text(s.createGroupButton,
                          style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
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
        _SectionLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.sora(fontSize: 15, color: _ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.sora(color: _hint, fontSize: 14),
            prefixIcon: Icon(icon, color: _hint, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border, width: 1.5)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _ink, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          style: GoogleFonts.sora(fontSize: 15, color: _ink),
          items: items
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _inlineDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.sora(color: _hint, fontSize: 13),
      prefixIcon: Icon(icon, color: _hint, size: 18),
      filled: true,
      fillColor: _bg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border, width: 1.5)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border, width: 1.5)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _ink, width: 1.5)),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────

class _MilestoneEntry {
  final nameCtrl   = TextEditingController();
  final amountCtrl = TextEditingController();
  void dispose() {
    nameCtrl.dispose();
    amountCtrl.dispose();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.sora(
            fontSize: 13, fontWeight: FontWeight.w600, color: _ink),
      );
}

class _TypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _ink : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? _ink : _border, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: selected ? Colors.white : _grey, size: 28),
            const SizedBox(height: 10),
            Text(title,
                style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : _ink)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: GoogleFonts.sora(
                    fontSize: 11,
                    color: selected
                        ? Colors.white.withValues(alpha: 0.7)
                        : _grey)),
          ],
        ),
      ),
    );
  }
}

class _GoalTotalPreview extends StatelessWidget {
  final List<_MilestoneEntry> milestones;
  const _GoalTotalPreview({required this.milestones});

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (final m in milestones) {
      final v = double.tryParse(m.amountCtrl.text.trim());
      if (v != null) total += v;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Goal',
              style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          Text(
            'RWF ${total.toStringAsFixed(0)}',
            style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
