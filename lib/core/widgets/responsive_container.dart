import 'package:flutter/material.dart';
import '../../app/theme/app_dimensions.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final bool usePadding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.usePadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth,
        ),
        padding: usePadding
            ? EdgeInsets.symmetric(
                horizontal: width > AppDimensions.mobileBreakPoint ? 32.0 : 16.0,
                vertical: 16.0,
              )
            : EdgeInsets.zero,
        child: child,
      ),
    );
  }
}
