import 'package:flutter/material.dart';

import './widgets/search_field.dart';

class SearchingScreen extends StatelessWidget {
  const SearchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SearchField()
          ],
        ),
      ),
    );
  }
}
