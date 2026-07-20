import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Full-width Emergency Marquee Ticker Footer (#8B0000)
class EmergencyTickerFooter extends StatefulWidget {
  final String marqueeText;

  const EmergencyTickerFooter({
    super.key,
    required this.marqueeText,
  });

  @override
  State<EmergencyTickerFooter> createState() => _EmergencyTickerFooterState();
}

class _EmergencyTickerFooterState extends State<EmergencyTickerFooter>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startContinuousScrolling();
    });
  }

  void _startContinuousScrolling() async {
    while (!_isDisposed && mounted) {
      if (_scrollController.hasClients) {
        final double maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          await _scrollController.animateTo(
            maxScroll,
            duration: const Duration(seconds: 25),
            curve: Curves.linear,
          );
          if (!_isDisposed && mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        } else {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: const BoxDecoration(
        color: AppColors.emergencyRed,
        boxShadow: [
          BoxShadow(
            color: Color(0x668B0000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emergency Icon Indicator on the Right
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: double.infinity,
            color: AppColors.emergencyRedDark,
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'هشدار',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Marquee Scrolling Container
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '${widget.marqueeText}  •  ${widget.marqueeText}  •  ${widget.marqueeText}',
                      style: AppTypography.tickerText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
