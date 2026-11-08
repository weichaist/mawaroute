import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SectionTitleListTile extends StatelessWidget {
  final String title;
  const SectionTitleListTile({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: AutoSizeText(
        title,
        style: const TextStyle(fontSize: 21),
        maxLines: 1,
      ),
    );
  }
}
