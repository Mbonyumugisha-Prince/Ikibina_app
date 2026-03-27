import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../models/group_model.dart';
import '../../models/penalty_model.dart';
import '../../services/penalty_service.dart';

const _ink = Color(0xFF1A1A1A);
const _grey = Color(0xFF888888);

/// Embedded as a tab inside GroupInfoScreen.
/// Admin: can toggle rules and edit thresholds, then save.
/// Member: read-only view of current rules + their own penalty history.
class GroupPenaltiesTab extends StatefulWidget {
  final GroupModel group;
  final bool isAdmin;
  final String currentUserId;

  const GroupPenaltiesTab({
    super.key,
    required this.group,
    required this.isAdmin,
    required this.currentUserId,
  });

  @override
  State<GroupPenaltiesTab> createState() => _GroupPenaltiesTabState();
}

class _GroupPenaltiesTabState extends State<GroupPenaltiesTab> {
  late GroupPenaltyRules _rules;
  bool _saving = false;
  bool _runningChecks = false;
  String? _lastCheckResult;

  @override
  void initState() {
    super.initState();
    _rules = widget.group.penaltyRules ?? GroupPenaltyRules.defaults();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await PenaltyService().savePenaltyRules(widget.group.id, _rules);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(_snackBar('Penalty rules saved.'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_snackBar('Failed to save: $e', isError: true));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _runChecks() async {
    setState(() {
      _runningChecks = true;
      _lastCheckResult = null;
    });
    try {
      final log = await PenaltyService().runChecks(widget.group);
      if (mounted) {
        setState(() {
          _lastCheckResult = log.isEmpty
              ? 'No penalties to apply at this time.'
              : log.join('\n');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _lastCheckResult = 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _runningChecks = false);
    }
  }

  SnackBar _snackBar(String msg, {bool isError = false}) => SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        backgroundColor: isError ? Colors.red.shade700 : Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Header ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.gavel, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penalty Rules',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    Text(
                      widget.isAdmin
                          ? 'Configure escalation rules for missed contributions'
                          : 'Penalties set by your group admin',
                      style: GoogleFonts.inter(fontSize: 12, color: _grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Level 1: Gentle Reminder ───────────────────────────────
        _RuleCard(
          level: 1,
          title: 'Gentle Reminder',
          icon: Icons.notifications_outlined,
          enabled: _rules.gentleReminderEnabled,
          onToggle: widget.isAdmin
              ? (v) => setState(() =>
                  _rules = _rules.copyWith(gentleReminderEnabled: v))
              : null,
          description: 'Push notification & email sent to the member',
          fields: [
            _RuleField(
              label: 'Hours after deadline',
              value: _rules.gentleReminderHoursAfterDeadline.toString(),
              editable: widget.isAdmin && _rules.gentleReminderEnabled,
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n > 0) {
                  setState(() => _rules = _rules.copyWith(
                      gentleReminderHoursAfterDeadline: n));
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Level 2: Late Fee ──────────────────────────────────────
        _RuleCard(
          level: 2,
          title: 'Late Fee',
          icon: Icons.percent_outlined,
          enabled: _rules.lateFeeEnabled,
          onToggle: widget.isAdmin
              ? (v) =>
                  setState(() => _rules = _rules.copyWith(lateFeeEnabled: v))
              : null,
          description: 'A fine is charged as a percentage of the contribution',
          fields: [
            _RuleField(
              label: 'Days late before fee',
              value: _rules.lateFeeDaysLate.toString(),
              editable: widget.isAdmin && _rules.lateFeeEnabled,
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n > 0) {
                  setState(() => _rules = _rules.copyWith(lateFeeDaysLate: n));
                }
              },
            ),
            _RuleField(
              label: 'Fee percentage (%)',
              value: _rules.lateFeePercent.toStringAsFixed(1),
              editable: widget.isAdmin && _rules.lateFeeEnabled,
              onChanged: (v) {
                final n = double.tryParse(v);
                if (n != null && n > 0 && n <= 100) {
                  setState(
                      () => _rules = _rules.copyWith(lateFeePercent: n));
                }
              },
              isDecimal: true,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Level 3: Account Freeze ────────────────────────────────
        _RuleCard(
          level: 3,
          title: 'Account Freeze',
          icon: Icons.lock_outline,
          enabled: _rules.accountFreezeEnabled,
          onToggle: widget.isAdmin
              ? (v) => setState(
                  () => _rules = _rules.copyWith(accountFreezeEnabled: v))
              : null,
          description: 'Member cannot take loans or receive payouts',
          fields: [
            _RuleField(
              label: 'Cycles missed to freeze',
              value: _rules.accountFreezeCyclesMissed.toString(),
              editable: widget.isAdmin && _rules.accountFreezeEnabled,
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n > 0) {
                  setState(() =>
                      _rules = _rules.copyWith(accountFreezeCyclesMissed: n));
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Level 4: Expulsion ─────────────────────────────────────
        _RuleCard(
          level: 4,
          title: 'Expulsion',
          icon: Icons.exit_to_app_outlined,
          enabled: _rules.expulsionEnabled,
          onToggle: widget.isAdmin
              ? (v) => setState(
                  () => _rules = _rules.copyWith(expulsionEnabled: v))
              : null,
          description: 'Member is permanently removed from the group',
          isCritical: true,
          fields: [
            _RuleField(
              label: 'Cycles missed to expel',
              value: _rules.expulsionCyclesMissed.toString(),
              editable: widget.isAdmin && _rules.expulsionEnabled,
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n > 0) {
                  setState(() =>
                      _rules = _rules.copyWith(expulsionCyclesMissed: n));
                }
              },
            ),
          ],
        ),

        if (widget.isAdmin) ...[
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Save Policy Changes',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Changes apply from the next billing cycle',
              style: GoogleFonts.inter(fontSize: 12, color: _grey),
            ),
          ),

          const SizedBox(height: 16),

          // Run penalty checks manually
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _runningChecks ? null : _runChecks,
              icon: _runningChecks
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: _ink, strokeWidth: 2))
                  : const Icon(Icons.refresh, color: _ink, size: 18),
              label: Text(
                _runningChecks ? 'Running checks…' : 'Run penalty checks now',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _ink),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_lastCheckResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Text(
                _lastCheckResult!,
                style: GoogleFonts.inter(fontSize: 13, color: _ink),
              ),
            ),
          ],
        ],

        const SizedBox(height: 24),

        // ── Penalty record history ─────────────────────────────────
        Text(
          'Penalty History',
          style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600, color: _ink),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<PenaltyRecordModel>>(
          stream: PenaltyService().getGroupPenaltyRecords(widget.group.id),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: _ink, strokeWidth: 2),
              ));
            }

            final all = snap.data ?? [];
            // Members only see their own records
            final records = widget.isAdmin
                ? all
                : all
                    .where((r) => r.userId == widget.currentUserId)
                    .toList();

            if (records.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Center(
                  child: Text(
                    'No penalty records yet.',
                    style: GoogleFonts.inter(fontSize: 14, color: _grey),
                  ),
                ),
              );
            }

            return Column(
              children: records.map((r) => _HistoryTile(record: r)).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Rule card ──────────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  final int level;
  final String title;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool>? onToggle;
  final String description;
  final List<_RuleField> fields;
  final bool isCritical;

  const _RuleCard({
    required this.level,
    required this.title,
    required this.icon,
    required this.enabled,
    required this.onToggle,
    required this.description,
    required this.fields,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical && enabled
              ? Colors.red.shade200
              : const Color(0xFFE0E0E0),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: enabled ? _ink : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: enabled ? _ink : _grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: enabled ? _ink : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'LEVEL $level',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: enabled ? Colors.black54 : _grey),
                      ),
                    ],
                  ),
                ),
                if (onToggle != null)
                  Switch(
                    value: enabled,
                    onChanged: onToggle,
                    activeThumbColor: _ink,
                    activeTrackColor: Colors.grey.shade300,
                    inactiveThumbColor: Colors.grey.shade400,
                    inactiveTrackColor: Colors.grey.shade200,
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: enabled
                          ? Colors.black.withValues(alpha: 0.08)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      enabled ? 'Active' : 'Off',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: enabled ? _ink : _grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Fields
          if (fields.isNotEmpty) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                children:
                    fields.map((f) => _buildField(f, enabled)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(_RuleField field, bool ruleEnabled) {
    if (!field.editable) {
      // Read-only display
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(field.label,
                style:
                    GoogleFonts.inter(fontSize: 13, color: _grey)),
            Text(
              field.value,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ruleEnabled ? _ink : _grey),
            ),
          ],
        ),
      );
    }

    // Editable field
    final ctrl = TextEditingController(text: field.value);
    ctrl.selection =
        TextSelection.collapsed(offset: ctrl.text.length);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(field.label,
              style: GoogleFonts.inter(fontSize: 13, color: _grey)),
          SizedBox(
            width: 80,
            child: TextField(
              controller: ctrl,
              keyboardType: field.isDecimal
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              inputFormatters: [
                field.isDecimal
                    ? FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'))
                    : FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink),
              onChanged: field.onChanged,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleField {
  final String label;
  final String value;
  final bool editable;
  final ValueChanged<String>? onChanged;
  final bool isDecimal;

  const _RuleField({
    required this.label,
    required this.value,
    required this.editable,
    this.onChanged,
    this.isDecimal = false,
  });
}

// ── History tile ───────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  final PenaltyRecordModel record;
  const _HistoryTile({required this.record});

  static const _labels = {
    AppConstants.penaltyGentleReminder: 'Gentle Reminder',
    AppConstants.penaltyLateFee: 'Late Fee',
    AppConstants.penaltyAccountFreeze: 'Account Freeze',
    AppConstants.penaltyExpulsion: 'Expulsion',
  };

  static const _icons = {
    AppConstants.penaltyGentleReminder: Icons.notifications_outlined,
    AppConstants.penaltyLateFee: Icons.percent_outlined,
    AppConstants.penaltyAccountFreeze: Icons.lock_outline,
    AppConstants.penaltyExpulsion: Icons.exit_to_app_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final label = _labels[record.type] ?? record.type;
    final icon = _icons[record.type] ?? Icons.gavel_outlined;
    final isHigh = record.type == AppConstants.penaltyAccountFreeze ||
        record.type == AppConstants.penaltyExpulsion;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isHigh ? Colors.red.shade50 : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon,
                size: 16,
                color: isHigh ? Colors.red : Colors.black87),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _ink)),
                    if (record.amount > 0)
                      Text(
                        'RWF ${record.amount.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(record.userName,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _grey,
                        fontWeight: FontWeight.w500)),
                Text(record.description,
                    style:
                        GoogleFonts.inter(fontSize: 11, color: _grey)),
                const SizedBox(height: 2),
                Text(_fmtDate(record.appliedAt),
                    style:
                        GoogleFonts.inter(fontSize: 11, color: Colors.black38)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
