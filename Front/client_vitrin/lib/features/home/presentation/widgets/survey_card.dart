import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/base_card.dart';
import '../../data/models/survey_model.dart';

enum SurveyFeedbackType { dissatisfied, neutral, satisfied }

/// Full-width Survey Bar Card with 3 touchable emoji feedback buttons
class SurveyCard extends StatefulWidget {
  final SurveyModel survey;
  final ValueChanged<SurveyFeedbackType>? onFeedbackSelected;

  const SurveyCard({
    super.key,
    required this.survey,
    this.onFeedbackSelected,
  });

  @override
  State<SurveyCard> createState() => _SurveyCardState();
}

class _SurveyCardState extends State<SurveyCard> {
  SurveyFeedbackType? _selectedFeedback;

  void _handleSelect(SurveyFeedbackType type) {
    setState(() {
      _selectedFeedback = type;
    });
    if (widget.onFeedbackSelected != null) {
      widget.onFeedbackSelected!(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      borderRadius: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right Side: Title + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.survey.title,
                  style: AppTypography.titleSmall.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.survey.subtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Left Side: 3 Touchable Emoji Buttons
          Row(
            children: [
              // Dissatisfied / Red
              _buildEmojiButton(
                type: SurveyFeedbackType.dissatisfied,
                icon: Icons.sentiment_very_dissatisfied_rounded,
                activeColor: AppColors.crimsonRed,
                label: 'ناراضی',
              ),
              const SizedBox(width: 16),
              // Neutral / Gray
              _buildEmojiButton(
                type: SurveyFeedbackType.neutral,
                icon: Icons.sentiment_neutral_rounded,
                activeColor: AppColors.neutralGray,
                label: 'معمولی',
              ),
              const SizedBox(width: 16),
              // Satisfied / Brownish-Orange
              _buildEmojiButton(
                type: SurveyFeedbackType.satisfied,
                icon: Icons.sentiment_very_satisfied_rounded,
                activeColor: AppColors.copperOrange,
                label: 'راضی',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiButton({
    required SurveyFeedbackType type,
    required IconData icon,
    required Color activeColor,
    required String label,
  }) {
    final bool isSelected = _selectedFeedback == type;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSelect(type),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withValues(alpha: 0.25) : AppColors.tagBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? activeColor : AppColors.cardBorder,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                icon,
                size: 34,
                color: isSelected ? activeColor : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
