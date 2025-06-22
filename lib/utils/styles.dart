

import 'package:flutter/material.dart';

Gradient yellowBlackGradient() {
  return const LinearGradient(
    colors: [
      Color.fromRGBO(255, 199, 44, 2),
      Color.fromRGBO(255, 199, 44, 1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Gradient decorations
BoxDecoration gradientBoxDecoration(Gradient gradient, double radius) {
  return BoxDecoration(
    gradient: gradient,
    borderRadius: BorderRadius.all(Radius.circular(radius) //
    ),
  );
}

//box decoration with border colors only
BoxDecoration myOutlineBoxDecoration(double width, Color color, double radius) {
  return BoxDecoration(
    border: Border.all(width: width, color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius) //
    ),
  );
}

//box decoration with fill box colors
BoxDecoration myFillBoxDecoration(double width, Color color, double radius) {
  return BoxDecoration(
    color: color,
    border: Border.all(width: width, color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius) //
    ),
  );
}

// / box decoration with Box shadow
BoxDecoration shadowDecoration(double radius, double blur) {
  return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: blur,
        ),
      ]);
}

Widget addVerticalSpace(double height) {
  return SizedBox(height: height);
}

Widget addHorizontalySpace(double width, color) {
  return Container(width: width, color:color);
}


// TextStyle


TextStyle bodyText14w600({required Color color}) {
  return TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600);
}

TextStyle bodyText14normal({required Color color}) {
  return TextStyle(
    fontSize: 14,
    color: color,
  );
}

TextStyle bodyText16normal({required Color color}) {
  return TextStyle(
    fontSize: 16,
    color: color,
  );
}

TextStyle bodyText13normal({required Color color}) {
  return TextStyle(
    fontSize: 13,
    color: color,
  );
}

TextStyle bodyText16w600({required Color color}) {
  return TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w700);
}

TextStyle bodyText18w600({required Color color}) {
  return TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w700);
}

// small Size
TextStyle bodyText12Small({required Color color}) {
  return TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w400);
}

TextStyle bodyText11Small({required Color color}) {
  return TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w400);
}

TextStyle bodytext12Bold({required Color color}) {
  return TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600);
}

TextStyle bodyText20w700({required Color color}) {
  return TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold);
}

TextStyle bodyText22w700({required Color color}) {
  return TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.bold);
}

TextStyle bodyText30W600({required Color color}) {
  return TextStyle(fontSize: 30, color: color, fontWeight: FontWeight.w700);
}

TextStyle bodyText30W400({required Color color}) {
  return TextStyle(
    fontSize: 30,
    color: color,
  );
}