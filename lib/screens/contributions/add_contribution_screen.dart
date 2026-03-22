import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../models/contribution_model.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddContributionScreen extends StatefulWidget {
  const AddContributionScreen({super.key});

  @override
  State<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends State<AddContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final groupProvider = context.read<GroupProvider>();

    if (groupProvider.groups.isEmpty) return;
    final group = groupProvider.groups.first;

    final contribution = ContributionModel(
      id: const Uuid().v4(),
      groupId: group.id,
      userId: auth.user!.id,
      userName: auth.user!.name,
      amount: double.parse(_amountController.text),
      date: DateTime.now(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    final success = await groupProvider.addContribution(contribution);
    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(groupProvider.error ?? 'Failed to add contribution')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Contribution')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Amount (RWF)',
                controller: _amountController,
                validator: Validators.amount,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Note (optional)',
                controller: _noteController,
                prefixIcon: Icons.note_outlined,
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Submit Contribution',
                onPressed: _submit,
                loading: groupProvider.loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
