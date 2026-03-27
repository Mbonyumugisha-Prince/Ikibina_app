import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<_PaymentMethod> _methods = [
    _PaymentMethod(
      id: 'm1',
      label: 'MTN Mobile Money',
      details: '+250 *** *** 421',
      type: PaymentMethodType.mobileMoney,
      logoUrl: 'https://logo.clearbit.com/mtn.com',
      isDefault: true,
      isVerified: true,
    ),
    _PaymentMethod(
      id: 'm2',
      label: 'Visa Card',
      details: '**** **** **** 1208',
      type: PaymentMethodType.card,
      logoUrl: 'https://logo.clearbit.com/visa.com',
      isDefault: false,
      isVerified: true,
    ),
    _PaymentMethod(
      id: 'm3',
      label: 'Bank of Kigali',
      details: '**** **** 9087',
      type: PaymentMethodType.bank,
      logoUrl: 'https://logo.clearbit.com/bk.rw',
      isDefault: false,
      isVerified: true,
    ),
  ];

  void _setDefault(String id) {
    setState(() {
      for (final method in _methods) {
        method.isDefault = method.id == id;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Default payment method updated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeMethod(String id) {
    setState(() {
      _methods.removeWhere((m) => m.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment method removed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showAddMethodSheet() async {
    final created = await showModalBottomSheet<_PaymentMethod>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddPaymentMethodSheet(),
    );

    if (created == null) return;

    setState(() {
      if (_methods.isEmpty) {
        created.isDefault = true;
      }
      _methods.add(created);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment method added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Payment Methods',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMethodSheet,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Method',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline,
                      color: Colors.blue.shade700, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your payment details are encrypted and used only for transactions in your group.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Saved Methods',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            if (_methods.isEmpty)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.credit_card_off_outlined,
                        color: Colors.grey.shade500, size: 32),
                    const SizedBox(height: 10),
                    Text(
                      'No payment methods yet',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add a method to start making quick contributions and repayments.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._methods.map(
                (method) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PaymentMethodCard(
                    method: method,
                    onSetDefault: () => _setDefault(method.id),
                    onRemove: () => _removeMethod(method.id),
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.onSetDefault,
    required this.onRemove,
  });

  final _PaymentMethod method;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: method.type.badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _PaymentMethodBrandIcon(method: method),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.label,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.details,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (method.isVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Verified',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: method.isDefault ? null : onSetDefault,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    method.isDefault ? 'Default' : 'Set as Default',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onRemove,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'Remove',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddPaymentMethodSheet extends StatefulWidget {
  const _AddPaymentMethodSheet();

  @override
  State<_AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<_AddPaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  PaymentMethodType _type = PaymentMethodType.mobileMoney;
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Payment Method',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<PaymentMethodType>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: PaymentMethodType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _type = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                hintText: 'e.g. Airtel Money, Visa Card',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Label is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: 'Details',
                hintText: 'e.g. +250 *** *** 123 or **** **** **** 3456',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Details are required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  Navigator.pop(
                    context,
                    _PaymentMethod(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      label: _labelController.text.trim(),
                      details: _detailsController.text.trim(),
                      type: _type,
                      logoUrl: null,
                      isDefault: false,
                      isVerified: false,
                    ),
                  );
                },
                child: const Text('Save Method'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PaymentMethodType { mobileMoney, card, bank }

extension PaymentMethodTypeX on PaymentMethodType {
  String get displayName {
    switch (this) {
      case PaymentMethodType.mobileMoney:
        return 'Mobile Money';
      case PaymentMethodType.card:
        return 'Card';
      case PaymentMethodType.bank:
        return 'Bank Account';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethodType.mobileMoney:
        return Icons.phone_android;
      case PaymentMethodType.card:
        return Icons.credit_card;
      case PaymentMethodType.bank:
        return Icons.account_balance;
    }
  }

  Color get badgeColor {
    switch (this) {
      case PaymentMethodType.mobileMoney:
        return const Color(0xFFE5F2FF);
      case PaymentMethodType.card:
        return const Color(0xFFFFF3E6);
      case PaymentMethodType.bank:
        return const Color(0xFFE9F9EF);
    }
  }
}

class _PaymentMethod {
  _PaymentMethod({
    required this.id,
    required this.label,
    required this.details,
    required this.type,
    required this.logoUrl,
    required this.isDefault,
    required this.isVerified,
  });

  final String id;
  final String label;
  final String details;
  final PaymentMethodType type;
  final String? logoUrl;
  bool isDefault;
  final bool isVerified;
}

class _PaymentMethodBrandIcon extends StatelessWidget {
  const _PaymentMethodBrandIcon({required this.method});

  final _PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final logoUrl = method.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return Icon(method.type.icon, color: Colors.black87, size: 20);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Icon(method.type.icon, color: Colors.black87, size: 20);
        },
      ),
    );
  }
}
