import 'package:flutter/material.dart';
import '../../widgets/common/loading_indicator.dart';

class ContributionsScreen extends StatelessWidget {
  const ContributionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contributions')),
      body: const LoadingIndicator(message: 'Loading contributions...'),
    );
  }
}
