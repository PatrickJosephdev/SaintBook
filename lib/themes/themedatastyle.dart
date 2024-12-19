import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeDataStyle {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.green,
    ),
    textTheme: GoogleFonts.latoTextTheme( // Set the default font here
      ThemeData.light().textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blueGrey,
      secondary: Colors.teal,
    ),
    
    
  );
}




// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ThemeDataStyle {
//   static ThemeData light = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.light,
//     colorScheme: const ColorScheme.light(
//       primary: Colors.blue,
//       secondary: Colors.green,
//     ),
//     textTheme: GoogleFonts.latoTextTheme( // Set the default font here
//       ThemeData.light().textTheme.apply(
//         bodyColor: Colors.black,
//         displayColor: Colors.black,
//       ),
//     ),
//   );

//   static ThemeData dark = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.dark,
//     colorScheme: const ColorScheme.dark(
//       primary: Colors.blueGrey,
//       secondary: Colors.teal,
//     ),
//     textTheme: GoogleFonts.latoTextTheme( // Set the default font here
//       ThemeData.dark().textTheme.apply(
//         bodyColor: Colors.white,
//         displayColor: Colors.white,
//       ),
//     ),
//   );
// }