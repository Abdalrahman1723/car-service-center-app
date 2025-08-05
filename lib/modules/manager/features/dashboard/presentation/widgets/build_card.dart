import 'package:flutter/material.dart';

Widget buildCard(
  BuildContext context,
  String title,
  IconData icon,
  VoidCallback onTap,
) {
  return InkWell(
    onTap: onTap,
    child: Card(
      color: Theme.of(context).canvasColor,
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
