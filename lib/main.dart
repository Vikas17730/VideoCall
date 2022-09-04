import 'package:flutter/material.dart';
import 'package:videosdk_flutter_example/providers/auth_provider.dart';
import 'package:videosdk_flutter_example/screens/Sign_In.dart';
import 'package:provider/provider.dart';


import 'constants/colors.dart';
import 'navigator_key.dart';
import 'screens/splash_screen.dart';

void main() {
  // Run Flutter App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Material App
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthProvider())
      ],

    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VideoSDK Flutter Example',
      theme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme().copyWith(
          color: primaryColor,
        ),
        primaryColor: primaryColor,
        backgroundColor: secondaryColor,
      ),
      home: const SignInDemo(), //SplashScreen(),
      navigatorKey: navigatorKey,
    ));
  }
}
