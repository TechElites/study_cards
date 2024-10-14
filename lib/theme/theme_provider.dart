import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeType = ThemeMode.system;

  ThemeMode get currentTheme => _themeType;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    _themeType = _themeType == ThemeMode.light ? ThemeMode.dark : (_themeType == ThemeMode.dark ? ThemeMode.system : ThemeMode.light);
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _themeType.toString().split('.').last);
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _themeType = prefs.getString('theme') == 'dark' ? ThemeMode.dark : (prefs.getString('theme') == 'light' ? ThemeMode.light : ThemeMode.system);
    notifyListeners();
  }
}
