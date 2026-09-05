import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_config.dart';
import '../theme/app_colors.dart';
import '../utils/global_keys.dart';
import '../../shared/widgets/global_snackbar.dart';

class AppUpdateService {
  AppUpdateService._();

  static bool _isChecking = false;

  /// Compares two version strings (e.g. '1.1.1' vs '1.0.0').
  /// Returns true if [remote] is strictly greater than [local].
  static bool isVersionGreater(String remote, String local) {
    List<int> parseVersion(String v) {
      final mainV = v.split('+').first.trim();
      final parts = mainV.split('.');
      return parts.map((e) => int.tryParse(RegExp(r'\d+').stringMatch(e) ?? '0') ?? 0).toList();
    }

    final rParts = parseVersion(remote);
    final lParts = parseVersion(local);

    final maxLength = rParts.length > lParts.length ? rParts.length : lParts.length;
    for (int i = 0; i < maxLength; i++) {
      final rVal = i < rParts.length ? rParts[i] : 0;
      final lVal = i < lParts.length ? lParts[i] : 0;
      if (rVal > lVal) return true;
      if (rVal < lVal) return false;
    }
    return false;
  }

  /// Extracts clean version string (e.g. '1.1.1') from raw HTML/text content.
  static String extractVersion(String rawContent) {
    final text = rawContent.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
    final match = RegExp(r'\d+\.\d+(\.\d+)?(\+\d+)?').firstMatch(text);
    if (match != null) {
      return match.group(0)!;
    }
    return text.trim();
  }

  /// Checks server for remote version and triggers update dialog if newer version is found.
  static Future<void> checkForUpdate({
    BuildContext? context,
    bool showNoUpdateToast = false,
  }) async {
    if (_isChecking) return;
    _isChecking = true;

    final targetContext = context ?? rootNavigatorKey.currentContext;

    try {
      final checkUrl = AppConfig.current.updateCheckUrl.trim();
      if (checkUrl.isEmpty || checkUrl.contains('example.com')) {
        if (showNoUpdateToast && targetContext != null && targetContext.mounted) {
          _showSnackBar(targetContext, 'آدرس بررسی نسخه (updateCheckUrl) در AppConfig تنظیم نشده است.');
        }
        return;
      }

      // Fetch version index.html content
      final dio = Dio();
      final response = await dio.get<String>(
        checkUrl,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        if (showNoUpdateToast && targetContext != null && targetContext.mounted) {
          _showSnackBar(targetContext, 'خطا در دریافت نسخه از سرور (کد خطا: ${response.statusCode})');
        }
        return;
      }

      final remoteVersion = extractVersion(response.data!);
      if (remoteVersion.isEmpty) {
        if (showNoUpdateToast && targetContext != null && targetContext.mounted) {
          _showSnackBar(targetContext, 'نسخه معتبری از آدرس سرور دریافت نشد.');
        }
        return;
      }

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (isVersionGreater(remoteVersion, currentVersion)) {
        if (targetContext != null && targetContext.mounted) {
          _showUpdatePromptDialog(targetContext, remoteVersion: remoteVersion, currentVersion: currentVersion);
        }
      } else {
        if (showNoUpdateToast && targetContext != null && targetContext.mounted) {
          _showSnackBar(targetContext, 'شما از آخرین نسخه برنامه ($currentVersion) استفاده می‌کنید.');
        }
      }
    } catch (e) {
      debugPrint('Update check error: $e');
      if (showNoUpdateToast && targetContext != null && targetContext.mounted) {
        _showSnackBar(targetContext, 'خطا در ارتباط با سرور برای بررسی نسخه: $e');
      }
    } finally {
      _isChecking = false;
    }
  }

  /// Displays the confirmation dialog asking the user to update.
  static void _showUpdatePromptDialog(
    BuildContext context, {
    required String remoteVersion,
    required String currentVersion,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.system_update_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'بروزرسانی نسخه جدید',
                style: TextStyle(
                  fontFamily: 'Peyda',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نسخه جدیدی از برنامه ($remoteVersion) در دسترس است.',
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'نسخه فعلی شما: $currentVersion\nآیا مایل به دریافت و نصب نسخه جدید هستید؟',
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'بعداً',
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDownloadProgressDialog(context, remoteVersion);
            },
            icon: const Icon(Icons.download_rounded, size: 20),
            label: const Text(
              'دانلود و نصب',
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Displays downloading dialog and triggers APK download/installation stream.
  static void _showDownloadProgressDialog(BuildContext context, String version) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _DownloadProgressWidget(
          apkUrl: AppConfig.current.updateApkUrl.trim(),
          version: version,
        );
      },
    );
  }

  static void _showSnackBar(BuildContext context, String message) {
    // Routed through the shared widget so this always gets a
    // contrast-correct background/foreground pair instead of a hand-picked
    // fixed-dark background that could land text-on-text in dark mode.
    GlobalSnackBar.showInfo(message);
  }
}

class _DownloadProgressWidget extends StatefulWidget {
  final String apkUrl;
  final String version;

  const _DownloadProgressWidget({
    required this.apkUrl,
    required this.version,
  });

  @override
  State<_DownloadProgressWidget> createState() => _DownloadProgressWidgetState();
}

class _DownloadProgressWidgetState extends State<_DownloadProgressWidget> {
  double _progress = 0.0;
  String _statusText = 'در حال آماده‌سازی دانلود...';
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  void _startDownload() {
    if (widget.apkUrl.isEmpty || widget.apkUrl.contains('example.com')) {
      setState(() {
        _isError = true;
        _errorMessage = 'آدرس دانلود APK (updateApkUrl) در AppConfig تنظیم نشده است.';
      });
      return;
    }

    if (!kIsWeb && Platform.isAndroid) {
      try {
        OtaUpdate()
            .execute(
          widget.apkUrl,
          destinationFilename: 'daralou_vitrin_update.apk',
        )
            .listen(
          (OtaEvent event) {
            if (!mounted) return;
            switch (event.status) {
              case OtaStatus.DOWNLOADING:
                final parsed = double.tryParse(event.value ?? '0') ?? 0;
                setState(() {
                  _progress = parsed / 100.0;
                  _statusText = 'در حال دریافت فایل: ${parsed.toInt()}%';
                });
                break;
              case OtaStatus.INSTALLING:
                setState(() {
                  _progress = 1.0;
                  _statusText = 'دانلود کامل شد. در حال باز کردن نصب‌کننده...';
                });
                break;
              case OtaStatus.ALREADY_RUNNING_ERROR:
                setState(() {
                  _isError = true;
                  _errorMessage = 'عملیات دانلود در حال حاضر در حال اجرا است.';
                });
                break;
              case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                setState(() {
                  _isError = true;
                  _errorMessage = 'مجوز دسترسی لازم برای دانلود یا نصب داده نشده است.';
                });
                break;
              case OtaStatus.DOWNLOAD_ERROR:
              case OtaStatus.CHECKSUM_ERROR:
              case OtaStatus.INTERNAL_ERROR:
              default:
                setState(() {
                  _isError = true;
                  _errorMessage = 'خطا در دریافت یا آماده‌سازی برنامه (وضعیت: ${event.status})';
                });
                break;
            }
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _isError = true;
              _errorMessage = 'خطای غیرمنتظره: $error';
            });
          },
        );
      } catch (e) {
        setState(() {
          _isError = true;
          _errorMessage = 'خطا در شروع دانلود: $e';
        });
      }
    } else {
      // Non-Android platforms (e.g. desktop/web during development)
      setState(() {
        _isError = true;
        _errorMessage = 'امکان نصب خودکار نسخه جدید فقط در دستگاه اندروید پشتیبانی می‌شود.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(
            _isError ? Icons.error_outline_rounded : Icons.cloud_download_rounded,
            color: _isError ? AppColors.errorRed : AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _isError ? 'خطا در دانلود' : 'در حال دانلود نسخه ${widget.version}',
            style: TextStyle(
              fontFamily: 'Peyda',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isError) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                minHeight: 10,
                backgroundColor: AppColors.outlineVariant,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ] else ...[
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 14,
                color: AppColors.errorRed,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (_isError)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'بستن',
              style: TextStyle(
                fontFamily: 'Peyda',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
