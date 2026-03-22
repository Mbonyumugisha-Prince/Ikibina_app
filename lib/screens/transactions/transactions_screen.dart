import 'package:flutter/material.dart';
import '../../widgets/common/loading_indicator.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: const LoadingIndicator(message: 'Loading transactions...'),
    );
  }
}
