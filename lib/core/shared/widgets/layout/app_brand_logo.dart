import 'package:flutter/material.dart';

import '../../../../l10n/app_strings.dart';

/// MYM house-and-hammer mark used on splash, login, and desktop chrome.
class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({super.key, this.height = 128, this.fit = BoxFit.contain});

  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppStrings.logoAsset,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      semanticLabel: AppStrings.appName,
    );
  }
}
