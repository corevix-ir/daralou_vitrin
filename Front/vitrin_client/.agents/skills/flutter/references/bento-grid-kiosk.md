# Bento Grid Layout Engine & Reusable Containers

## Overview
This reference describes how to build the redesigned 3-column, 4-row Bento Grid on a 1080x1920 portrait kiosk screen in Flutter.

---

## 1. Redesigned Header Component (`RedesignedHeader`)

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class RedesignedHeader extends StatelessWidget {
  final String companyTitle;
  final String timeText;
  final String weatherText;
  final String dateText;

  const RedesignedHeader({
    super.key,
    this.companyTitle = 'شرکت مس درآلو',
    required this.timeText,
    required this.weatherText,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: AppColors.surfaceContainerLow,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right Side: Gray Circle Logo Placeholder & Company Title
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.logoCircleBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business_rounded, color: Colors.white70, size: 32),
              ),
              const SizedBox(width: 20),
              Text(
                companyTitle,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          // Left Side: 2-Line Time, Weather & Date
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAlignment.end,
            children: [
              // Line 1: Time & Weather
              Row(
                children: [
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('•', style: TextStyle(color: Colors.white38)),
                  const SizedBox(width: 12),
                  Text(
                    weatherText,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 18,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Line 2: Date
              Text(
                dateText,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 2. Bento Grid Assembly on Home Kiosk Screen (1080x1920)

```dart
import 'package:flutter/material.dart';

class RedesignedHomeKioskLayout extends StatelessWidget {
  final Widget header;
  final Widget heroCarousel;
  final Widget leaveRegistrationCard;
  final Widget lmeCopperTicker;
  final Widget sportsReservationCard;
  final Widget latestNewsCard;
  final Widget facilityMapCard;
  final Widget feedbackCard;
  final Widget restaurantMenuCard;
  final Widget emergencyFooter;

  const RedesignedHomeKioskLayout({
    super.key,
    required this.header,
    required this.heroCarousel,
    required this.leaveRegistrationCard,
    required this.lmeCopperTicker,
    required this.sportsReservationCard,
    required this.latestNewsCard,
    required this.facilityMapCard,
    required this.feedbackCard,
    required this.restaurantMenuCard,
    required this.emergencyFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header, // Redesigned Header: 120px
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              spacing: 16,
              children: [
                // Row 1: Hero Carousel (420px)
                SizedBox(height: 420, child: heroCarousel),
                
                // Row 2: Leave Registration (2 units) & LME Copper Ticker (1 unit)
                Expanded(
                  flex: 3,
                  child: Row(
                    spacing: 16,
                    children: [
                      Expanded(flex: 2, child: leaveRegistrationCard),
                      Expanded(flex: 1, child: lmeCopperTicker),
                    ],
                  ),
                ),
                
                // Row 3: Sports Reservation (2 units) & Latest News (1 unit)
                Expanded(
                  flex: 3,
                  child: Row(
                    spacing: 16,
                    children: [
                      Expanded(flex: 2, child: sportsReservationCard),
                      Expanded(flex: 1, child: latestNewsCard),
                    ],
                  ),
                ),
                
                // Row 4: Facility Map (1 unit), Feedback (1 unit), Restaurant Menu (1 unit)
                Expanded(
                  flex: 4,
                  child: Row(
                    spacing: 16,
                    children: [
                      Expanded(child: facilityMapCard),
                      Expanded(child: feedbackCard),
                      Expanded(child: restaurantMenuCard),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        emergencyFooter, // Emergency Footer Bar: 120px
      ],
    );
  }
}
```
