import 'package:flutter/material.dart';
import 'package:saintbook/themes/themedatastyle.dart';


class ThemeProvider extends ChangeNotifier {
  ThemeData _themeDataStyle = ThemeDataStyle.light;

  ThemeData get themeDataStyle => _themeDataStyle;

  void changeTheme() {
    if (_themeDataStyle == ThemeDataStyle.light) {
      _themeDataStyle = ThemeDataStyle.dark;
    } else {
      _themeDataStyle = ThemeDataStyle.light;
    }
    notifyListeners();
  }
}