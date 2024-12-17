import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobileproject/Screens/Home%20Page.dart';
import 'package:mobileproject/Screens/Login%20Screen.dart';
import 'package:mobileproject/Screens/Main%20Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Cubit/Shop/Shop Cubit.dart';
import 'Cubit/Theme/Theme Cubit.dart';
import 'Cubit/Theme/Theme States.dart';
import 'Screens/OnBoarding Screen.dart';
import 'Services/Dio Package.dart';
import 'Shared/Constants.dart';
import 'Shared/Themes.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = MyBlocObserver();
  DioHelper.init();

  // Check remember me logic
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? rememberMe = prefs.getBool('rememberMe');
  String? email = prefs.getString('email');
  String? password = prefs.getString('password');

  bool isLoggedIn = false;

  if (rememberMe == true && email != null && password != null) {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      isLoggedIn = true;
    } catch (e) {
      print('Auto-login failed: $e');
    }
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ShopCubit>(
          create: (context) => ShopCubit(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: BlocConsumer<ThemeCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeCubit.get(context).themebool
                ? ThemeMode.dark
                : ThemeMode.light,
            home: isLoggedIn
                ? MainScreen()
                : Directionality(
              textDirection: TextDirection.ltr,
              child: OnBoardingScreen(),
            ),
          );
        },
      ),
    );
  }
}