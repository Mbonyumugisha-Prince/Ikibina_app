import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/auth_provider.dart';
import '../../providers/group_provider.dart';
import '../../models/group_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _frequency = 'Monthly';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final groupProvider = context.read<GroupProvider>();

    final group = GroupModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      createdBy: auth.user!.id,
      contributionAmount: double.parse(_amountController.text),
      contributionFrequency: _frequency,
      createdAt: DateTime.now(),
    );

    final success = await groupProvider.createGroup(group, auth.user!.id);
    if (mounted) {
      if (success) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(groupProvider.error ?? 'Failed to create group')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Group Name',
                controller: _nameController,
                validator: (v) =>
                    Validators.required(v, fieldName: 'Group name'),
                prefixIcon: Icons.group_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 3,
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Contribution Amount (RWF)',
                controller: _amountController,
                validator: Validators.amount,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.payments_outlined,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Contribution Frequency',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: AppConstants.contributionFrequencies
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => _frequency = v!),
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Create Group',
                onPressed: _submit,
                loading: groupProvider.loading,
                icon: Icons.group_add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
