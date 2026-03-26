import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/group_model.dart';
import '../../providers/group_provider.dart';
import '../../services/cloudinary_service.dart';

const _bg     = Color(0xFFF5F5F5);
const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _hint   = Color(0xFFBBBBBB);
const _border = Color(0xFFE0E0E0);

class EditGroupScreen extends StatefulWidget {
  final GroupModel group;
  const EditGroupScreen({super.key, required this.group});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  // Ikimina
  late final TextEditingController _amountCtrl;
  late String _frequency;
  late String _duration;

  // Goal milestones
  late final List<_MilestoneEntry> _milestones;

  File? _imageFile;
  Uint8List? _imageBytes;
  bool _uploadingImage = false;

  bool get _isGoal => widget.group.groupType == AppConstants.groupTypeGoal;

  @override
  void initState() {
    super.initState();
    final g = widget.group;

    _nameCtrl   = TextEditingController(text: g.name);
    _descCtrl   = TextEditingController(text: g.description);
    _amountCtrl = TextEditingController(
        text: g.contributionAmount > 0 ? g.contributionAmount.toStringAsFixed(0) : '');
    _frequency  = g.contributionFrequency;
    _duration   = g.duration;

    // Pre-fill milestones (keep at least 3)
    _milestones = g.milestones.map((m) => _MilestoneEntry(
          name:   m.name,
          amount: m.targetAmount > 0 ? m.targetAmount.toStringAsFixed(0) : '',
        )).toList();
    while (_milestones.length < 3) {
      _milestones.add(_MilestoneEntry());
    }

    for (final m in _milestones) {
      m.amountCtrl.addListener(_refreshTotal);
    }
  }

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

  void _refreshTotal() => setState(() {});

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
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

  Future<String?> _uploadImage() async {
    if (_imageBytes == null) return widget.group.imageUrl;
    setState(() => _uploadingImage = true);
    try {
      return await CloudinaryService.uploadImage(_imageBytes!, widget.group.id);
    } catch (e) {
      if (mounted) {
        _snack('Photo upload failed: ${e.toString()}');
      }
      return widget.group.imageUrl;
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _addMilestone() {
    if (_milestones.length >= 5) return;
    final entry = _MilestoneEntry();
    entry.amountCtrl.addListener(_refreshTotal);
    setState(() => _milestones.add(entry));
  }

  void _removeMilestone(int i) {
    if (_milestones.length <= 3) return;
    setState(() => _milestones.removeAt(i));
  }

  bool _validateMilestones() {
    for (final m in _milestones) {
      if (m.nameCtrl.text.trim().isEmpty) return false;
      final v = double.tryParse(m.amountCtrl.text.trim());
      if (v == null || v <= 0) return false;
    }
    return true;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { _snack('Please enter a group name.'); return; }

    if (!_isGoal) {
      final amount = double.tryParse(_amountCtrl.text.trim());
      if (amount == null || amount <= 0) {
        _snack('Please enter a valid contribution amount.'); return;
      }
    } else {
      if (!_validateMilestones()) {
        _snack('Please fill in all milestone names and amounts (must be > 0).');
        return;
      }
    }

    final groupProvider = context.read<GroupProvider>();
    final imageUrl = await _uploadImage();

    final milestones = _isGoal
        ? _milestones
            .map((m) => MilestoneModel(
                  name: m.nameCtrl.text.trim(),
                  targetAmount: double.parse(m.amountCtrl.text.trim()),
                ))
            .toList()
        : widget.group.milestones;

    final parsedAmount = !_isGoal
        ? double.parse(_amountCtrl.text.trim())
        : widget.group.contributionAmount;

    final updated = GroupModel(
      id:                   widget.group.id,
      name:                 name,
      description:          _descCtrl.text.trim(),
      createdBy:            widget.group.createdBy,
      adminId:              widget.group.adminId,
      inviteCode:           widget.group.inviteCode,
      groupType:            widget.group.groupType,
      contributionAmount:   parsedAmount,
      contributionFrequency: _isGoal ? '' : _frequency,
      duration:             _duration,
      milestones:           milestones,
      totalSavings:         widget.group.totalSavings,
      memberCount:          widget.group.memberCount,
      members:              widget.group.members,
      suspendedMembers:     widget.group.suspendedMembers,
      imageUrl:             imageUrl,
      createdAt:            widget.group.createdAt,
    );

    final success = await groupProvider.updateGroup(updated);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(updated);
    } else {
      _snack(groupProvider.error ?? 'Failed to save changes.');
    }
  }

  Future<void> _confirmDelete() async {
    final groupProvider = context.read<GroupProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Group',
            style: GoogleFonts.sora(
                fontSize: 18, fontWeight: FontWeight.w700, color: _ink)),
        content: Text(
          'Are you sure you want to delete "${widget.group.name}"? '
          'This cannot be undone and all group data will be lost.',
          style: GoogleFonts.sora(fontSize: 14, color: _grey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.sora(
                    fontWeight: FontWeight.w600, color: _grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete',
                style: GoogleFonts.sora(
                    fontWeight: FontWeight.w700, color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await groupProvider.deleteGroup(widget.group.id);
    if (!mounted) return;
    if (success) {
      // Pop all the way back to the home screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      _snack(groupProvider.error ?? 'Failed to delete group.');
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

  @override
  Widget build(BuildContext context) {
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

              Text('Edit Group',
                  style: GoogleFonts.sora(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: _ink,
                      letterSpacing: -0.3)),
              const SizedBox(height: 6),
              Text('Update your group details',
                  style: GoogleFonts.sora(fontSize: 14, color: _grey)),
              const SizedBox(height: 28),

              // ── Group type badge (read-only) ──────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isGoal ? Icons.flag_outlined : Icons.savings_outlined,
                      color: _grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isGoal ? 'Goal Group' : 'Ikimina',
                      style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _ink),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Cannot change',
                          style: GoogleFonts.sora(
                              fontSize: 11, color: _grey)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Profile Picture ───────────────────────────────
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
                  child: _buildImagePicker(),
                ),
              ),
              const SizedBox(height: 20),

              // ── Common fields ─────────────────────────────────
              _field('Group Name', 'e.g. Weekend Savers',
                  Icons.group_outlined, _nameCtrl),
              const SizedBox(height: 16),
              _field('Description', 'What is this group about?',
                  Icons.description_outlined, _descCtrl,
                  maxLines: 2),
              const SizedBox(height: 24),

              // ── Ikimina fields ────────────────────────────────
              if (!_isGoal) ...[
                _field('Contribution Amount', '0',
                    Icons.payments_outlined, _amountCtrl,
                    isNumber: true),
                const SizedBox(height: 16),

                _SectionLabel('Contribution Frequency'),
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

              // ── Goal milestones ───────────────────────────────
              if (_isGoal) ...[
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
                              decoration: const BoxDecoration(
                                  color: _ink, shape: BoxShape.circle),
                              child: Center(
                                child: Text('${i + 1}',
                                    style: GoogleFonts.sora(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Milestone ${i + 1}',
                                style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _ink)),
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
                          style:
                              GoogleFonts.sora(fontSize: 14, color: _ink),
                          decoration: _inlineDeco(
                              'Milestone name', Icons.label_outline),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: m.amountCtrl,
                          keyboardType: TextInputType.number,
                          style:
                              GoogleFonts.sora(fontSize: 14, color: _ink),
                          decoration: _inlineDeco(
                              'Target amount (RWF)',
                              Icons.payments_outlined),
                        ),
                      ],
                    ),
                  );
                }),

                if (_milestones.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _GoalTotalPreview(milestones: _milestones),
                ],
                const SizedBox(height: 28),
              ],

              // ── Save button ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loading ? null : _save,
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
                      : Text('Save Changes',
                          style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),

              // ── Delete group button ───────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: loading ? null : _confirmDelete,
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  label: Text('Delete Group',
                      style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
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

  Widget _buildImagePicker() {
    // Priority: newly picked file > existing URL > placeholder
    if (_imageFile != null) {
      return ClipRRect(
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
                    color: _ink, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      );
    }
    if (widget.group.imageUrl != null &&
        widget.group.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(widget.group.imageUrl!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder()),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: _ink, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate_outlined, color: _grey, size: 32),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Photo',
                style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink)),
            Text('Tap to choose from gallery',
                style: GoogleFonts.sora(fontSize: 12, color: _grey)),
          ],
        ),
      ],
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
  final TextEditingController nameCtrl;
  final TextEditingController amountCtrl;

  _MilestoneEntry({String name = '', String amount = ''})
      : nameCtrl   = TextEditingController(text: name),
        amountCtrl = TextEditingController(text: amount);

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
          Text('RWF ${total.toStringAsFixed(0)}',
              style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ],
      ),
    );
  }
}
