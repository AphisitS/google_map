import 'package:flutter/material.dart';
import 'package:google_map/screens/google_map_screen.dart';

main() {
  runApp(Homepage());
}

class Homepage extends StatelessWidget {
  const Homepage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: GoogleMapScreen(),
    );
  }
}
