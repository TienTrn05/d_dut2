import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final Function()? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) const SizedBox(height: 16),
            if (onRetry != null) ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Thử lại"),
            ),
          ],
        ),
      ),
    );
  }
}
