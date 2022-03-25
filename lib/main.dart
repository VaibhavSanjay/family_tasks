import 'package:family_tasks/Services/database.dart';
import 'package:family_tasks/pages/Helpers/hero_dialogue_route.dart';
import 'package:flutter/material.dart';
import 'package:family_tasks/pages/account.dart';
import 'package:family_tasks/pages/task_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initializeFirebase();
  runApp(const FamilyTasks());
}

class FamilyTasks extends StatelessWidget {
  const FamilyTasks({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  final GlobalKey<TaskViewPageState> _keyTaskView = GlobalKey(), _keyAccount = GlobalKey();
  late final List<Widget> _screens = [TaskViewPage(key: _keyTaskView), AccountPage(key: _keyAccount)];
  int _pageIndex = 0;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializePreference().whenComplete(() {
      prefs.setString('famID', '100');
      TaskViewPageState.setFamID(prefs.getString('famID'));
      AccountPageState.setFamID(prefs.getString('famID'));
      setState((){});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializePreference() async{
    prefs = await SharedPreferences.getInstance();
  }

  void _onPageChanged(int index) {
    setState(() {
    _pageIndex = index;
    });
  }

  void _onItemTap(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Hero(
            tag: 'archive',
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.inbox),
                onPressed: () {
                  Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                    if (_keyTaskView.currentState != null) {
                      return _keyTaskView.currentState!.createArchiveCardList(
                          EdgeInsets.only(top: MediaQuery.of(context).size.height/6,
                              left: 30,
                              right: 30,
                              bottom: MediaQuery.of(context).size.height/6
                          )
                      );
                    }
                    return const Text('yep');
                  }));
                }
              ),
            ),
          )
        ]
      ),
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: _onPageChanged,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_keyTaskView.currentState != null) {
            _keyTaskView.currentState!.addTask();
          }
        },
        child: const Icon(Icons.add)
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTap,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.purple
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
              backgroundColor: Colors.black
          )
        ],
        currentIndex: _pageIndex,
        selectedItemColor: Colors.blue
      ),
    );
  }
}
