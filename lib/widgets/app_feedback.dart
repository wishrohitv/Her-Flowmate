import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  const AppLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPink500),
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTheme.outfit(context: context, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}

class AppErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightError.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppTheme.lightError),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTheme.outfit(
                context: context,
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('RETRY'),
            ),
        ],
      ),
    );
  }
}
