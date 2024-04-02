import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../movies_page.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._context) : super(LoginState.initial) {
    _checkSavedSession();
  }

  final BuildContext _context;
  late SharedPreferences _prefs;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _saveSession(String email, String password) async {
    await _prefs.setString('email', email);
    await _prefs.setString('password', password);
  }

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'debes colocar un email';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'debes colocar tu contrasena';
    }
    if (password.length < 8) {
      return 'la contrasena tiene que ser mas de 8 caracteres';
    }
    return null;
  }

  Future<void> login(BuildContext context, String email, String password) async {
    try {
      await _initPrefs();
      emit(LoginState.loading);
      final emailError = validateEmail(email);
      final passwordError = validatePassword(password);

      if (emailError == null && passwordError == null) {
        if ((email == 'nicolas@gmail.com' && password == '12345678') ||
            (email == 'user@gmail.com' && password == '87654321')) {
          await _saveSession(email, password);
          emit(LoginState.loggedIn);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PopularMovies(),
            ),
          );
        } else {
          emit(LoginState.error);
        }
      } else {
        emit(LoginState.error);
      }
    } catch (e) {
      emit(LoginState.error);
    }
  }

  Future<void> _checkSavedSession() async {
    await _initPrefs();
    final email = _prefs.getString('email');
    final password = _prefs.getString('password');

    if (email != null && password != null) {
      print('Sesión guardada: $email');
      print(LoginState);
      emit(LoginState.loggedIn);
      Navigator.of(_context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PopularMovies(),
        ),
      );
    }
    else {
      print('No hay sesión guardada');
    }
  }
}