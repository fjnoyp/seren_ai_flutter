import 'package:flutter/material.dart';

class BaseHomeCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final String title;

  const BaseHomeCard(
      {super.key,
      required this.child,
      required this.color,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.all(2),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,                
              ),
            ],
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}