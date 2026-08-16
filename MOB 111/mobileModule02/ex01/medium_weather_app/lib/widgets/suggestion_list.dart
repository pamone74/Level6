import 'package:flutter/material.dart';
import 'package:weather_app/data/models.dart';

class SuggestionList extends StatelessWidget {
  const SuggestionList({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  final List<LocationResult> suggestions;
  final ValueChanged<LocationResult> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: suggestions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final location = suggestions[index];
        return ListTile(
          title: Text(location.name),
          subtitle: Text(
            [
              if (location.region.isNotEmpty) location.region,
              if (location.country.isNotEmpty) location.country,
            ].join(', '),
          ),
          onTap: () => onTap(location),
        );
      },
    );
  }
}
