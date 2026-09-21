import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class AppPreferences {
  AppPreferences._();

  static final AppPreferences instance = AppPreferences._();

  SharedPreferences? _preferences;
  final Map<String, bool> _fallback = {};
  final Map<String, String> _textFallback = {};
  final Map<String, List<String>> _listFallback = {};

  Future<void> initialize() async {
    if (_preferences != null) return;
    try {
      _preferences = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 2),
      );
    } on MissingPluginException {
      // Allows an old Web hot-reload bundle to start before plugins refresh.
    } on TimeoutException {
      // Continue with the in-memory fallback when local storage is unavailable.
    }
  }

  bool get onboardingCompleted =>
      _preferences?.getBool('onboarding_completed') ??
      _fallback['onboarding_completed'] ??
      false;

  bool get hasSession =>
      _preferences?.getBool('session_active') ??
      _fallback['session_active'] ??
      false;

  String? get currentUserEmail =>
      _preferences?.getString('auth_email') ?? _textFallback['auth_email'];

  Future<void> completeOnboarding() async {
    await _setBool('onboarding_completed', true);
  }

  Future<void> startSession() async {
    await _setBool('session_active', true);
  }

  Future<void> closeSession() async {
    await _setBool('session_active', false);
    _textFallback.remove('auth_email');
    await _preferences?.remove('auth_email');
  }

  Future<void> saveAuthenticatedUser(String email, String name) async {
    await _setText('auth_email', email);
    await _setText('profile_name', name);
  }

  String get profileName =>
      _preferences?.getString('profile_name') ??
      _textFallback['profile_name'] ??
      'Jesús';

  String? get profileImage =>
      _preferences?.getString('profile_image') ??
      _textFallback['profile_image'];

  String get profileGoal =>
      _preferences?.getString('profile_goal') ??
      _textFallback['profile_goal'] ??
      'Ganar músculo';

  String get profileExperience =>
      _preferences?.getString('profile_experience') ??
      _textFallback['profile_experience'] ??
      'Intermedio';

  String get profileUnit =>
      _preferences?.getString('profile_unit') ??
      _textFallback['profile_unit'] ??
      'Métrico';

  String get profileEquipment =>
      _preferences?.getString('profile_equipment') ??
      _textFallback['profile_equipment'] ??
      'Gimnasio completo';

  List<String> get trainingDays =>
      _preferences?.getStringList('training_days') ??
      _listFallback['training_days'] ??
      const ['Lun', 'Mié', 'Vie'];

  List<String> get focusMuscles =>
      _preferences?.getStringList('focus_muscles') ??
      _listFallback['focus_muscles'] ??
      const ['Pecho', 'Espalda', 'Piernas'];

  int get profileAge =>
      int.tryParse(
        _preferences?.getString('profile_age') ??
            _textFallback['profile_age'] ??
            '25',
      ) ??
      25;

  double get profileWeight =>
      double.tryParse(
        _preferences?.getString('profile_weight') ??
            _textFallback['profile_weight'] ??
            '75',
      ) ??
      75;

  double get profileHeight =>
      double.tryParse(
        _preferences?.getString('profile_height') ??
            _textFallback['profile_height'] ??
            '175',
      ) ??
      175;

  Future<void> saveProfile({
    required String name,
    required String goal,
    required String experience,
    required String unit,
    String? equipment,
    List<String>? days,
    List<String>? muscles,
    int? age,
    double? weight,
    double? height,
  }) async {
    await _setText('profile_name', name);
    await _setText('profile_goal', goal);
    await _setText('profile_experience', experience);
    await _setText('profile_unit', unit);
    if (equipment != null) await _setText('profile_equipment', equipment);
    if (days != null) await _setList('training_days', days);
    if (muscles != null) await _setList('focus_muscles', muscles);
    if (age != null) await _setText('profile_age', '$age');
    if (weight != null) await _setText('profile_weight', '$weight');
    if (height != null) await _setText('profile_height', '$height');
  }

  Future<void> saveProfileImage(String? base64Image) async {
    if (base64Image == null) {
      _textFallback.remove('profile_image');
      await _preferences?.remove('profile_image');
    } else {
      await _setText('profile_image', base64Image);
    }
  }

  Future<void> _setBool(String key, bool value) async {
    _fallback[key] = value;
    await _preferences?.setBool(key, value);
  }

  Future<void> _setText(String key, String value) async {
    _textFallback[key] = value;
    await _preferences?.setString(key, value);
  }

  Future<void> _setList(String key, List<String> value) async {
    _listFallback[key] = List<String>.from(value);
    await _preferences?.setStringList(key, value);
  }

  Future<void> clear() async {
    _fallback.clear();
    _textFallback.clear();
    _listFallback.clear();
    await _preferences?.clear();
  }
}
