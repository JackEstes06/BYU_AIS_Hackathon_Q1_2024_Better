import 'package:ais_hackathon_better/widgets/user_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_page.dart';
import 'calendar_events_page.dart';
import 'user_events_attended_page.dart';

class NavigationBarApp extends StatelessWidget {
  final String uid;
  const NavigationBarApp({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: NavigationExample(uid: uid),
    );
  }
}

class NavigationExample extends StatefulWidget {
  final String uid;
  const NavigationExample({super.key, required this.uid});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  final dbRef = FirebaseDatabase.instance.ref();
  int _currentIndex = 0;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance
        .ref()
        .child("users/${widget.uid}")
        .child('isAdmin')
        .onValue
        .listen((event) {
      if (mounted) {
        setState(() {
          (event.snapshot.value.toString() == 'false')
              ? isAdmin = false
              : isAdmin = true;
        });
      }
    });
    debugPrint("setting current index to $_currentIndex");
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      debugPrint("setting current index to $_currentIndex");
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Card(
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(8.0),
        child: SizedBox.expand(
          child: Center(
            child: Text(
              'Home page',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ),
      UserEventsAttendedPage(
        dbRef: dbRef,
        userId: FirebaseAuth.instance.currentUser!.uid,
      ),
      Consumer(builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return CalendarEventsPage(
          dbRef: dbRef,
          userId: FirebaseAuth.instance.currentUser!.uid,
          ref: ref,
        );
      }),
      Consumer(builder: (context, ref, _) {
        return UserInfoPage(ref: ref);
      }),
      // TODO reinstate isAdmin
      // if (isAdmin)
      // removed to allow non-admin testers the functionality that admins will have
      // end TODO
      Consumer(builder: (context, ref, _) {
        return AdminPage(
          ref: ref,
          dbRef: dbRef,
          userId: FirebaseAuth.instance.currentUser!.uid,
        );
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("AIS Punchcard"),
        backgroundColor: const Color.fromRGBO(0, 87, 184, 1),
      ),
      body: pages[_currentIndex],
      // For some reason, this padding needs to surround the bottom nav bar
      // to work properly on small iOS devices (i.e. iPhone SE)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(.0001, 0, .0001, 0),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromRGBO(0, 46, 93, 1),
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.white,
          onTap: _onTabTapped,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.event),
              icon: Icon(Icons.event_outlined),
              label: 'My Events',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.calendar_month),
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
            // TODO reinstate isAdmin
            // if (isAdmin)
            // removed to allow non-admin testers the functionality that admins will have
            // end TODO
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.admin_panel_settings),
              icon: Icon(Icons.admin_panel_settings_outlined),
              label: 'Admin',
            ),
          ],
        ),
      ),
    );
  }
}
