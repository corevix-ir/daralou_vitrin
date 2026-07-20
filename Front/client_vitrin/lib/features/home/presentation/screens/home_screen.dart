import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/home_dashboard_model.dart';
import '../../data/services/home_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/hero_news_card.dart';
import '../widgets/leave_card.dart';
import '../widgets/lme_copper_card.dart';
import '../widgets/sports_reservation_card.dart';
import '../widgets/secondary_news_card.dart';
import '../widgets/map_card.dart';
import '../widgets/feedback_card.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/emergency_ticker_footer.dart';

/// Updated Home Screen matching the new digital signage layout specifications:
/// - Header: Gray circle logo + Title/Subtitle on right, 2 detail lines on left (Date/Time & Weather)
/// - Row 1: Hero News Banner
/// - Row 2: Leave Registration (2-col) + LME Copper Price (1-col)
/// - Row 3: Sports Reservation (2-col) + News Card (1-col)
/// - Row 4: 3-column cards: Restaurant Menu | Feedback & Suggestions | Map & Navigation (Left to Right)
/// - Row 5 (Survey bar): Removed
/// - Footer: Emergency Marquee Ticker Footer
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();
  HomeDashboardModel? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  late Timer _clockTimer;
  String _currentTimeString = '۱۰:۲۴';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _startClockTimer();
  }

  void _startClockTimer() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final hours = _toPersianDigits(now.hour.toString().padLeft(2, '0'));
      final minutes = _toPersianDigits(now.minute.toString().padLeft(2, '0'));
      if (mounted) {
        setState(() {
          _currentTimeString = '$hours:$minutes';
        });
      }
    });
  }

  String _toPersianDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], persian[i]);
    }
    return input;
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _homeService.fetchHomeDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Main Scrollable Kiosk Content Area
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.copperOrange,
                        ),
                      )
                    : _errorMessage != null
                        ? _buildErrorView()
                        : _buildKioskContent(),
              ),

              // Bottom Marquee Emergency Footer Ticker
              if (_dashboardData != null)
                EmergencyTickerFooter(
                  marqueeText: _dashboardData!.emergencyMarqueeText,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 64,
            color: AppColors.crimsonRed,
          ),
          const SizedBox(height: 16),
          Text(
            'خطا در دریافت اطلاعات دشبورد',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.copperOrange,
            ),
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildKioskContent() {
    final data = _dashboardData!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          // Top Header: Gray circle logo placeholder + Title/Subtitle (Right), 2 detail lines (Left)
          HeaderWidget(
            locationTag: data.locationTag,
            temperature: data.temperature,
            time: _currentTimeString,
            date: 'دوشنبه ۳۰ تیر ۱۴۰۵',
          ),

          const SizedBox(height: 20),

          // Row 1: Hero News Card (Full Width)
          SizedBox(
            height: 360,
            width: double.infinity,
            child: HeroNewsCard(news: data.news),
          ),

          const SizedBox(height: 20),

          // Row 2: Leave Registration (2 col) + LME Copper Card (1 col)
          SizedBox(
            height: 230,
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: LeaveCard(),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: LmeCopperCard(lme: data.lme),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Row 3: Sports Reservation (2 col) + News Card (1 col)
          SizedBox(
            height: 215,
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: SportsReservationCard(),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  flex: 1,
                  child: SecondaryNewsCard(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Row 4: 3x 1-Column Cards (From Left to Right: Map | Feedback | Restaurant Menu)
          // Note: In RTL Row, children[0] is Rightmost, children[2] is Leftmost.
          SizedBox(
            height: 185,
            child: Row(
              children: [
                // Rightmost: Restaurant Menu
                Expanded(
                  child: RestaurantCard(restaurant: data.restaurant),
                ),
                const SizedBox(width: 20),
                // Center: Feedback & Suggestions
                const Expanded(
                  child: FeedbackCard(),
                ),
                const SizedBox(width: 20),
                // Leftmost: Map & Navigation
                const Expanded(
                  child: MapCard(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
