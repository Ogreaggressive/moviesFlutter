import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_page.dart';
import 'cubits/login_cubit.dart';
import 'cubits/login_state.dart';
import 'movies_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(context),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          primaryColor: Colors.blue,
          appBarTheme: AppBarTheme(
            color: Colors.blue,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          textTheme: TextTheme(
            displayLarge: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            if (state == LoginState.loggedIn) {
              return PopularMovies();
            } else {
              return LoginForm();
            }
          },
        ),
      ),
    );
  }
}
