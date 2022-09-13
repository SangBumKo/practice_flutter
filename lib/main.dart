import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice_flutter/screens/home_page/HomePage.dart';
import 'package:practice_flutter/screens/sign_up_page/SignUpPage.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: myHome(),
    );
  }

  StreamBuilder<User?> myHome(){
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          //이메일 인증이 안끝났다면 email인증 창으로 다시 보내기
          if(snapshot.data!.emailVerified){}
          return const HomePage();
        }
        return const SignUpPage();
      }
    );
  }
}



