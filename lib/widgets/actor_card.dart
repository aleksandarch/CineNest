import 'package:cine_nest/constants/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WikipediaSearchButton extends StatelessWidget {
  final String actorName;

  const WikipediaSearchButton({super.key, required this.actorName});

  Future<void> _openWikipediaSearch(context) async {
    final query = Uri.encodeComponent(actorName);
    final url = Uri.parse('${AppConstants.wikipediaSearchUrl}$query');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not launch Wikipedia search for $actorName')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => _openWikipediaSearch(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.deepPurple),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.info, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(actorName, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ));
  }
}
