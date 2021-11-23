import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:penny_pincher/services/preferences_prod_ids.dart';
import 'package:penny_pincher/view/app_navigator.dart';


void main() {

  // Always keep Portrait Orientation:
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
  );

  /*
  //Save the list of ProductCat IDS
  PreferenceIDS ids = PreferenceIDS();
  ids.fillListOfIDsAndSaveIt();

   */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food recipe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.white,
          textTheme: const TextTheme(
            bodyText2: TextStyle(color: Colors.white),
          )
      ),
      home: const AppNavigator(),
    );
  }
}



