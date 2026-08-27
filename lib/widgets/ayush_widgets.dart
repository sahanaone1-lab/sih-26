import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/hospital_model.dart';

/// Top header logo widget featuring official AYUSH & MediKiosk emblem styling.
class AyushHeaderLogo extends StatelessWidget {
  final double iconSize;
  final double? fontSize;
  final bool showSubtitle;
  final String titlePrefix;
  final String titleSuffix;

  const AyushHeaderLogo({
    super.key,
    this.iconSize = 24.0,
    this.fontSize,
    this.showSubtitle = false,
    this.titlePrefix = 'AYUSH ',
    this.titleSuffix = 'HOSPITAL PORTAL',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    final effectiveFontSize = fontSize ?? (isSmallMobile ? 15.0 : 18.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: AppColors.saffronLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.saffronPrimary, width: 1.5),
              ),
              child: Icon(
                Icons.spa_rounded,
                color: AppColors.saffronPrimary,
                size: isSmallMobile ? (iconSize * 0.85) : iconSize,
              ),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: titlePrefix,
                      style: TextStyle(
                        color: AppColors.saffronDark,
                        fontSize: effectiveFontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: titleSuffix,
                      style: TextStyle(
                        color: AppColors.navyPrimary,
                        fontSize: effectiveFontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 4.0),
          Text(
            'Ministry of Ayush • MediKiosk Public Health Infrastructure',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isSmallMobile ? 10.0 : 11.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}

/// Status Pill Badge representing verification status.
class StatusBadge extends StatelessWidget {
  final VerificationStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: status.color.withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14.0, color: status.color),
          const SizedBox(width: 6.0),
          Text(
            status.displayName,
            style: TextStyle(
              color: status.color,
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard Card Widget displaying single key metric with trend accent.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.navyPrimary,
    this.iconBgColor = AppColors.surface,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(icon, color: iconColor, size: 20.0),
                ),
                if (subtitle != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AppColors.greenSuccess,
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.navyPrimary,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Dashboard Quick Action Card.
class DashboardActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;
  final String? badgeText;

  const DashboardActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: iconColor, size: 22.0),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.navyPrimary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.saffronLight,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              badgeText!,
                              style: const TextStyle(
                                color: AppColors.saffronDark,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted,
                size: 14.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Document Upload card widget for registration and profile upload fields.
class UploadCard extends StatelessWidget {
  final String title;
  final String? fileName;
  final VoidCallback onTap;
  final String? subtitle;

  const UploadCard({
    super.key,
    required this.title,
    required this.fileName,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isUploaded = fileName != null && fileName!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.greenLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isUploaded
                ? AppColors.greenSuccess
                : AppColors.surfaceBorder,
            width: isUploaded ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isUploaded
                  ? Icons.check_circle_rounded
                  : Icons.cloud_upload_outlined,
              color: isUploaded
                  ? AppColors.greenSuccess
                  : AppColors.saffronPrimary,
              size: 28.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.navyPrimary,
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              isUploaded
                  ? fileName!
                  : (subtitle ?? 'Click to select document (PDF/JPG)'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isUploaded
                    ? AppColors.greenSuccess
                    : AppColors.textSecondary,
                fontSize: 11.0,
                fontWeight: isUploaded ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
