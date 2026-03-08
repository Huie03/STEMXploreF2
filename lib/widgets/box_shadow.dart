import 'package:flutter/material.dart';

//BoxShadow for the app cards
final List<BoxShadow> appBoxShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 4,
    offset: const Offset(0, 6),
  ),
];

//Box shadow for Animated Filter in subject chapters page
List<BoxShadow> filterBoxShadow(bool isSelected) {
  return [
    BoxShadow(
      color: isSelected
          ? Colors.black.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),

      blurRadius: isSelected ? 4 : 4,
      spreadRadius: isSelected ? 1 : 0,

      offset: isSelected ? const Offset(0, 3) : const Offset(0, 3),
    ),
  ];
}
