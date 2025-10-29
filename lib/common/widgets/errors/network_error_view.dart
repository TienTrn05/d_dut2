import 'package:flutter/material.dart';

class NetworkErrorView extends StatelessWidget {
  final String message;
  final Function()? onRetry;

  const NetworkErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 40, color: Colors.redAccent),
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