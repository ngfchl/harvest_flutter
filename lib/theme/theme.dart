import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///白天模式
ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: Colors.blue,
  splashColor: Colors.white12,
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    elevation: 0,
    backgroundColor: ThemeData.light().scaffoldBackgroundColor,
    iconTheme: const IconThemeData(color: Colors.black),
  ),
  scaffoldBackgroundColor: ThemeData.light().scaffoldBackgroundColor,
  colorScheme: ThemeData.light().copyWith().colorScheme.copyWith(
        background: Colors.white,
      ),
  iconTheme: const IconThemeData(
    color: Colors.red,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.blue, unselectedItemColor: Colors.tealAccent),
);

///夜间模式
ThemeData darkTheme = ThemeData.dark().copyWith(
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle.light,
    elevation: 0,
    backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  scaffoldBackgroundColor: ThemeData.dark().scaffoldBackgroundColor,
  colorScheme: ThemeData.light().copyWith().colorScheme.copyWith(
        background: Colors.black54,
      ),
  iconTheme: const IconThemeData(
    color: Colors.blue,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.tealAccent, unselectedItemColor: Colors.blue),
);
