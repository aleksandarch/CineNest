import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContentRatingInfo extends StatelessWidget {
  final String contentRating;

  const ContentRatingInfo({super.key, required this.contentRating});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRatingInfoDialog(context, contentRating),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.info, size: 16, color: Colors.deepPurple),
            const SizedBox(width: 6),
            Text(contentRating,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple)),
          ],
        ),
      ),
    );
  }

  void _showRatingInfoDialog(BuildContext context, String rating) {
    final String message = _getExplanation(rating);

    showDialog(
      barrierColor: Colors.deepPurple.withValues(alpha: 0.7),
      context: context,
      builder: (_) => AlertDialog(
        title: Text('What does "$rating" mean?'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it')),
        ],
      ),
    );
  }

  String _getExplanation(String rating) {
    switch (rating) {
      case 'G':
        return 'General Audience – Suitable for all ages.';
      case 'PG':
        return 'Parental Guidance Suggested – Some material may not be suitable for children.';
      case 'PG-13':
        return 'Parents Strongly Cautioned – Some material may be inappropriate for children under 13.';
      case 'R':
        return 'Restricted – Under 17 requires accompanying parent or adult guardian.';
      case 'NC-17':
        return 'Adults Only – No one under 17 admitted.';
      case '7':
        return 'Recommended for viewers 7 years and older.';
      case '11':
        return 'Recommended for viewers 11 years and older.';
      case 'Btl':
        return 'This rating is not standard. It may refer to a platform-specific or regional classification.';
      default:
        return 'No explanation available for this rating.';
    }
  }
}
