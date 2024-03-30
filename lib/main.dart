import 'package:flutter/material.dart';
import 'package:pcic_mobile_app/screens/_splash.dart';
import 'package:pcic_mobile_app/screens/_starting.dart';
import 'package:pcic_mobile_app/screens/dashboard/_job.dart';
import 'package:pcic_mobile_app/screens/dashboard/_task.dart';
import 'package:pcic_mobile_app/screens/dashboard/_home.dart';
import 'package:pcic_mobile_app/screens/dashboard/_message.dart';
import 'package:pcic_mobile_app/screens/user-control/_login.dart';
import 'package:pcic_mobile_app/screens/user-control/_signup.dart';
import 'package:pcic_mobile_app/screens/user-control/_verify_login.dart';
import 'package:pcic_mobile_app/screens/user-control/_verify_signup.dart';
import 'package:pcic_mobile_app/utils/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "assets/config/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /***************************************************************************
       * Debug Banner, currently set to false so you could not see the debug
       * banner on the top right of the app
       ***************************************************************************/
      debugShowCheckedModeBanner: false,

      /***************************************************************************
       * App Title
       ***************************************************************************/
      title: "PCIC Mobile App",

      /***************************************************************************
       * Routes
       **************************************************************************/
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.starting: (context) => const StartingPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.signup: (context) => const SignupPage(),
        AppRoutes.verifyLogin: (context) =>
            const VerifyLoginPage(isLoginSuccessful: true),
        AppRoutes.verifySignup: (context) =>
            const VerifySignupPage(isSignupSuccessful: true),
        AppRoutes.home: (context) => const DashboardPage(),
        AppRoutes.job: (context) => const JobPage(),
        AppRoutes.message: (context) => const MessagePage(),
        AppRoutes.task: (context) => const TaskPage(),
      },
    );
  }
}
