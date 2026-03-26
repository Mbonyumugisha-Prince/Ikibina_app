import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/loan_model.dart';
import '../../services/firestore_service.dart';

const _ink    = Color(0xFF1A1A1A);
const _grey   = Color(0xFF888888);
const _border = Color(0xFFE0E0E0);

class PayLoanScreen extends StatefulWidget {
  final LoanModel loan;
  const PayLoanScreen({super.key, required this.loan});

  @override
  State<PayLoanScreen> createState() => _PayLoanScreenState();
}

class _PayLoanScreenState extends State<PayLoanScreen> {
  final _amountCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _payment => double.tryParse(_amountCtrl.text.trim()) ?? 0;

  Future<void> _pay() async {
    final loan = widget.loan;
    if (_payment <= 0) { _snack('Enter a payment amount.'); return; }
    if (_payment > loan.remaining) {
      _snack('Amount exceeds remaining balance of RWF ${loan.remaining.toStringAsFixed(0)}.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await FirestoreService().payLoan(
        loanId: loan.id,
        paymentAmount: _payment,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) _snack('Payment failed: $e');
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
    final loan = widget.loan;
    final progress = loan.progress;
    final isOverdue = loan.isOverdue;

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
        title: Text('Pay Loan',
            style: GoogleFonts.sora(
                fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // ── Overdue banner ────────────────────────────────
            if (isOverdue) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This loan is overdue. Interest has increased to 15%.',
                        style: GoogleFonts.sora(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Progress card ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Repayment Progress',
                      style: GoogleFonts.sora(
                          fontSize: 11,
                          color: Colors.white60,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isOverdue ? Colors.red.shade300 : Colors.white),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}% paid',
                        style: GoogleFonts.sora(
                            fontSize: 12, color: Colors.white60),
                      ),
                      Text(
                        'RWF ${loan.amountPaid.toStringAsFixed(0)} / ${loan.totalToRepay.toStringAsFixed(0)}',
                        style: GoogleFonts.sora(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statChip('Principal',
                          'RWF ${loan.amount.toStringAsFixed(0)}'),
                      _statChip('Interest (${(loan.interestRate * 100).toInt()}%)',
                          'RWF ${loan.interest.toStringAsFixed(0)}'),
                      _statChip('Remaining',
                          'RWF ${loan.remaining.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Payment input ─────────────────────────────────
            Text('Payment Amount',
                style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink)),
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
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _grey)),
                  ),
                  Container(width: 1.5, height: 56, color: _border),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.sora(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _ink),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        hintText: '0',
                        hintStyle: GoogleFonts.sora(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _border),
                      ),
                    ),
                  ),
                  // Pay full button
                  GestureDetector(
                    onTap: () {
                      _amountCtrl.text =
                          loan.remaining.toStringAsFixed(0);
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _ink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Full',
                          style: GoogleFonts.sora(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Remaining balance: RWF ${loan.remaining.toStringAsFixed(0)}',
              style: GoogleFonts.sora(fontSize: 12, color: _grey),
            ),

            const SizedBox(height: 32),

            // ── Pay button ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    (_submitting || _payment <= 0) ? null : _pay,
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
                    : Text('Confirm Payment',
                        style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(value,
                  style: GoogleFonts.sora(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(label,
                  style: GoogleFonts.sora(
                      fontSize: 9, color: Colors.white60),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
}
