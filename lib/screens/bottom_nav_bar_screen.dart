// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:leadmanagementsystem/constants.dart';

// import 'worker_history_page.dart';
// import 'worker_home_screen.dart';
// import 'worker_payment_screen.dart';
// import 'worker_profile_screen.dart';

// class BottomNavBarScreen extends StatefulWidget {
//   const BottomNavBarScreen({super.key});

//   @override
//   State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
// }

// class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
//   int currentIndex = 0;

//   final screens = [
//     const WorkerHomeScreen(),
//     const WorkerHistoryPage(),
//     const WorkerPaymentScreen(),
//     const WorkerProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: screens[currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         selectedItemColor: appColor,
//         unselectedItemColor: Colors.black12,
//         showUnselectedLabels: true,
//         unselectedLabelStyle: const TextStyle(color: Colors.black12),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.work_history_outlined), label: 'Tasks'),
//           BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Projects'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.person_pin), label: 'Profile'),
//         ],
//         currentIndex: currentIndex,
//         backgroundColor: appColor,
//         onTap: (val) {
//           currentIndex = val;
//           setState(() {});
//         },
//       ),
//     );
//   }
// }
