import 'package:flutter/material.dart';

Color getCardColor(int priority) {
  switch (priority) {
    case 0:
      return Colors.redAccent; // High
    case 1:
      return Colors.amber; // Medium
    case 2:
      return Colors.lightGreen; // Low
    default:
      return Colors.white;
  }
}