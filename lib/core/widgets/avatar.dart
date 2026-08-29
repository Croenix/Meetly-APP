import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double size;

  const AppAvatar({
    super.key,
    this.url,
    required this.name,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    String? processedUrl = url;
    if (processedUrl != null && processedUrl.contains('/svg?seed=')) {
      processedUrl = processedUrl.replaceAll('/svg?seed=', '/png?seed=');
    }

    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : 'U';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Theme.of(context).colorScheme.primary).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.0), // Gradient border thickness
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
        ),
        padding: const EdgeInsets.all(1.5), // Separation padding
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size),
          child: processedUrl != null && processedUrl.isNotEmpty
              ? Image.network(
                  processedUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(context, initials);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildPlaceholder(context, initials);
                  },
                )
              : _buildPlaceholder(context, initials),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String initials) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      color: theme.colorScheme.primary.withAlpha(25),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }
}
