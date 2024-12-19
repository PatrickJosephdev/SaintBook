// //

// import 'package:myapp/pages/saintlist.dart';
// import 'package:myapp/pages/settingspage.dart';
// import 'package:flutter/material.dart';
// import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
// import 'package:myapp/pages/homepage.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// // Enum to handle tab navigation
// enum _SelectedTab { home, saintList, settings }

// class PageControl extends StatefulWidget {
//   const PageControl({super.key});

//   @override
//   State<PageControl> createState() => _PageControlState();
// }

// class _PageControlState extends State<PageControl> {
//   _SelectedTab _selectedTab = _SelectedTab.home;

//   @override
//   void initState() {
//     super.initState();
//     _checkInternetConnection();
//   }

//   void _handleIndexChanged(int index) {
//     setState(() {
//       _selectedTab = _SelectedTab.values[index];
//     });
//   }

//   Future<void> _checkInternetConnection() async {
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.none) {
//       _showNoConnectionSnackbar();
//     } else {
//       _showNewConnectionSnackbar();
//     }
//   }

//   void _showNoConnectionSnackbar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('No Internet Connection'),
//         duration: Duration(seconds: 3),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _showNewConnectionSnackbar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Internet Connected'),
//         duration: Duration(seconds: 3),
//         backgroundColor: Color.fromARGB(255, 18, 223, 46),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Check if the current theme is dark or light
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: IndexedStack(
//         index: _SelectedTab.values.indexOf(_selectedTab),
//         children: const [
//           MyHomePage(),
//           SaintList(),
//           SettingsPage(),
//         ],
//       ),
//       extendBody: true, // This makes the body extend to include the navbar
//       bottomNavigationBar: CrystalNavigationBar(
//         currentIndex: _SelectedTab.values.indexOf(_selectedTab),
//         onTap: _handleIndexChanged,
//         margin: const EdgeInsets.all(2),
//         height: 50,
//         paddingR: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
//         marginR: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
//         indicatorColor:
//             isDarkMode ? Colors.white : Colors.black, // Change indicator color
//         backgroundColor: isDarkMode
//             ? Colors.black.withOpacity(0.00000001)
//             : Colors.white.withOpacity(0.0000001), // Change background color
//         items: [
//           CrystalNavigationBarItem(
//             icon: Icons.home,
//             selectedColor: isDarkMode
//                 ? Colors.white
//                 : Colors.black, // Change selected color
//             unselectedColor: isDarkMode
//                 ? Colors.white54
//                 : Colors.black54, // Change unselected color
//           ),
//           CrystalNavigationBarItem(
//             icon: Icons.list,
//             selectedColor: isDarkMode ? Colors.white : Colors.black,
//             unselectedColor: isDarkMode ? Colors.white54 : Colors.black54,
//           ),
//           CrystalNavigationBarItem(
//             icon: Icons.settings,
//             selectedColor: isDarkMode ? Colors.white : Colors.black,
//             unselectedColor: isDarkMode ? Colors.white54 : Colors.black54,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:saintbook/pages/saintlist.dart';
import 'package:saintbook/pages/settingspage.dart';
import 'package:flutter/material.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:saintbook/pages/homepage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Enum to handle tab navigation
enum _SelectedTab { home, saintList, settings }

class PageControl extends StatefulWidget {
  const PageControl({super.key});

  @override
  State<PageControl> createState() => _PageControlState();
}

class _PageControlState extends State<PageControl> {
  _SelectedTab _selectedTab = _SelectedTab.home;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  void _handleIndexChanged(int index) {
    setState(() {
      _selectedTab = _SelectedTab.values[index];
    });
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showNoConnectionSnackbar();
    } else {
      _showNewConnectionSnackbar();
    }
  }

  void _showNoConnectionSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No Internet Connection'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showNewConnectionSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Internet Connected'),
        duration: Duration(seconds: 3),
        backgroundColor: Color.fromARGB(255, 18, 223, 46),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if the current theme is dark or light
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine the current page based on the selected tab
    Widget currentPage;
    switch (_selectedTab) {
      case _SelectedTab.home:
        currentPage = const MyHomePage();
        break;
      case _SelectedTab.saintList:
        currentPage = const SaintList();
        break;
      case _SelectedTab.settings:
        currentPage = const SettingsPage();
        break;
    }

    return Scaffold(
      body: currentPage, // Display the current page directly
      extendBody: true, // This makes the body extend to include the navbar
      bottomNavigationBar: CrystalNavigationBar(
        currentIndex: _SelectedTab.values.indexOf(_selectedTab),
        onTap: _handleIndexChanged,
        marginR: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        paddingR: const EdgeInsets.only(bottom: 5, top: 5),
        indicatorColor:
            isDarkMode ? Colors.white : Colors.black, // Change indicator color
        backgroundColor: isDarkMode
            ? Colors.black.withOpacity(0.00000001)
            : Colors.white.withOpacity(0.0000001), // Change background color
        items: [
          CrystalNavigationBarItem(
            icon: Icons.home,
            selectedColor: isDarkMode
                ? Colors.white
                : Colors.black, // Change selected color
            unselectedColor: isDarkMode
                ? Colors.white54
                : Colors.black54, // Change unselected color
          ),
          CrystalNavigationBarItem(
            icon: Icons.list,
            selectedColor: isDarkMode ? Colors.white : Colors.black,
            unselectedColor: isDarkMode ? Colors.white54 : Colors.black54,
          ),
          CrystalNavigationBarItem(
            icon: Icons.settings,
            selectedColor: isDarkMode ? Colors.white : Colors.black,
            unselectedColor: isDarkMode ? Colors.white54 : Colors.black54,
          ),
        ],
      ),
    );
  }
}