import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/group_model.dart';
import '../../models/loan_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

const _bg     = Color(0xFFF5F5F5);
const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _border = Color(0xFFE0E0E0);
const _green  = Color(0xFF2E7D32);

class RequestLoanScreen extends StatefulWidget {
  final GroupModel group;
  const RequestLoanScreen({super.key, required this.group});

  @override
  State<RequestLoanScreen> createState() => _RequestLoanScreenState();
}

class _RequestLoanScreenState extends State<RequestLoanScreen> {
  final _amountCtrl = TextEditingController();
  int _durationWeeks = 1;
  double _availableLimit = 0;
  bool _loadingLimit = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl.addListener(() => setState(() {}));
    _loadLimit();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLimit() async {
    final limit =
        await FirestoreService().getAvailableLoanLimit(widget.group.id);
    if (mounted) setState(() { _availableLimit = limit; _loadingLimit = false; });
  }

  double get _principal => double.tryParse(_amountCtrl.text.trim()) ?? 0;
  double get _interest  => _principal * LoanModel.normalRate;
  double get _total     => _principal + _interest + LoanModel.processingFee;
  DateTime get _dueDate =>
      DateTime.now().add(Duration(days: _durationWeeks * 7));

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (_principal <= 0) {
      _snack('Please enter an amount.'); return;
    }
    if (_principal > _availableLimit) {
      _snack('Amount exceeds available limit of RWF ${_availableLimit.toStringAsFixed(0)}.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final now  = DateTime.now();
      final loan = LoanModel(
        id:            const Uuid().v4(),
        groupId:       widget.group.id,
        userId:        auth.user!.id,
        userName:      auth.user!.name,
        amount:        _principal,
        durationWeeks: _durationWeeks,
        requestedAt:   now,
        dueDate:       now.add(Duration(days: _durationWeeks * 7)),
      );
      await FirestoreService().requestLoan(loan);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Loan request submitted. Waiting for group approval.',
            style: GoogleFonts.sora()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    } catch (e) {
      if (mounted) _snack('Failed to submit: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text('Request a Loan',
            style: GoogleFonts.sora(
                fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: GoogleFonts.sora(fontSize: 14, color: _grey)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),

            // ── Amount input ──────────────────────────────────
            Text('How much do you need?',
                style: GoogleFonts.sora(fontSize: 13, color: _grey)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: _border, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    child: Text('RWF',
                        style: GoogleFonts.sora(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _grey)),
                  ),
                  Container(width: 1.5, height: 56, color: _border),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.sora(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _ink),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        hintText: '0',
                        hintStyle: GoogleFonts.sora(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _loadingLimit
                ? Text('Loading available limit…',
                    style: GoogleFonts.sora(fontSize: 12, color: _grey))
                : Text(
                    'Available limit: RWF ${_availableLimit.toStringAsFixed(0)}',
                    style: GoogleFonts.sora(
                        fontSize: 12,
                        color: _grey,
                        fontWeight: FontWeight.w500)),

            const SizedBox(height: 32),

            // ── Duration ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Repayment Duration',
                    style: GoogleFonts.sora(
                        fontSize: 13,
                        color: _grey,
                        fontWeight: FontWeight.w500)),
                Text('$_durationWeeks ${_durationWeeks == 1 ? 'Week' : 'Weeks'}',
                    style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _ink)),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _ink,
                inactiveTrackColor: _border,
                thumbColor: _ink,
                overlayColor: _ink.withValues(alpha: 0.1),
                trackHeight: 3,
              ),
              child: Slider(
                value: _durationWeeks.toDouble(),
                min: 1,
                max: 4,
                divisions: 3,
                onChanged: (v) =>
                    setState(() => _durationWeeks = v.round()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1 Week',
                      style: GoogleFonts.sora(fontSize: 11, color: _grey)),
                  Text('4 Weeks',
                      style: GoogleFonts.sora(fontSize: 11, color: _grey)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Breakdown ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 18, color: _ink),
                      const SizedBox(width: 8),
                      Text('BREAKDOWN',
                          style: GoogleFonts.sora(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                              letterSpacing: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _row('Principal Amount',
                      'RWF ${_principal.toStringAsFixed(0)}'),
                  const SizedBox(height: 10),
                  _row('Interest Rate (7%)',
                      'RWF ${_interest.toStringAsFixed(0)}'),
                  const SizedBox(height: 10),
                  _row('Processing Fee',
                      'RWF ${LoanModel.processingFee.toStringAsFixed(0)}'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: _border, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total to Repay',
                              style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _ink)),
                          const SizedBox(height: 2),
                          Text(
                            'Due by ${_fmtDate(_dueDate)}',
                            style:
                                GoogleFonts.sora(fontSize: 11, color: _grey),
                          ),
                        ],
                      ),
                      Text(
                        'RWF ${_total.toStringAsFixed(0)}',
                        style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _ink),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Note ─────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined,
                    size: 16, color: _green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This request will be sent to all group members for approval. '
                    'Funds are typically released within 24 hours of approval.',
                    style: GoogleFonts.sora(
                        fontSize: 12, color: _grey, height: 1.5),
                  ),
                ),
              ],
            ),

            // ── Overdue note ─────────────────────────────────
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'If not repaid within the repayment period, interest increases '
                    'from 7% to 15% of the principal.',
                    style: GoogleFonts.sora(
                        fontSize: 12, color: _grey, height: 1.5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_submitting || _loadingLimit || _principal <= 0)
                    ? null
                    : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _ink.withValues(alpha: 0.4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Submit Request',
                              style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text('SECURE TRANSACTION  •  END-TO-END ENCRYPTED',
                  style: GoogleFonts.sora(
                      fontSize: 10,
                      color: _grey,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.sora(fontSize: 13, color: _grey)),
          Text(value,
              style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink)),
        ],
      );

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
