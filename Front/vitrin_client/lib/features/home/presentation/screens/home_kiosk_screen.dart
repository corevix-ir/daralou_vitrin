import 'package:flutter/material.dart';
import '../widgets/redesigned_header.dart';
import '../widgets/leave_registration_card.dart';
import '../widgets/lme_copper_ticker_card.dart';
import '../widgets/sports_reservation_card.dart';
import '../widgets/latest_news_card.dart';
import '../widgets/facility_map_card.dart';
import '../widgets/feedback_card.dart';
import '../widgets/restaurant_menu_card.dart';
import '../../../news/presentation/widgets/hero_news_carousel.dart';

class HomeKioskScreen extends StatelessWidget {
  const HomeKioskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Redesigned Top Header Bar
            const RedesignedHeader(),

            // Main Bento Grid Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  spacing: 16,
                  children: [
                    // Row 1: Hero Carousel (GET /contents/vitrin API integration)
                    SizedBox(
                      height: 460,
                      child: HeroNewsCarousel(),
                    ),

                    // Row 2: Staff Leave Registration (2 units) & Restaurant Menu (1 unit)
                    Expanded(
                      flex: 3,
                      child: Row(
                        spacing: 16,
                        children: [
                          Expanded(flex: 2, child: LeaveRegistrationCard()),
                          Expanded(flex: 1, child: RestaurantMenuCard()),
                        ],
                      ),
                    ),

                    // Row 3: Sports Reservation (2 units) & Latest News (1 unit)
                    Expanded(
                      flex: 3,
                      child: Row(
                        spacing: 16,
                        children: [
                          Expanded(flex: 2, child: SportsReservationCard()),
                          Expanded(flex: 1, child: LatestNewsCard()),
                        ],
                      ),
                    ),

                    // Row 4: Facility Map (1 unit), Feedback (1 unit), LME Copper Ticker (1 unit)
                    Expanded(
                      flex: 2,
                      child: Row(
                        spacing: 16,
                        children: [
                          Expanded(child: FacilityMapCard()),
                          Expanded(child: FeedbackCard()),
                          Expanded(child: LmeCopperTickerCard()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
