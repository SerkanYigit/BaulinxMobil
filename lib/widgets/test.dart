import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bottom Bar Example'),
      ),
      body: Center(
        child: Text('Selected Index: $_selectedIndex'),
      ),
      bottomNavigationBar: Container(
        height: 70.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: Colors.black,
            elevation: 8.0,
            borderRadius: BorderRadius.circular(36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.home_outlined),
                  onPressed: () => _onItemTapped(0),
                  color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
                ),
                IconButton(
                  icon: Icon(Icons.show_chart_outlined),
                  onPressed: () => _onItemTapped(1),
                  color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
                ),
                SizedBox(width: 48.0),
                IconButton(
                  icon: Icon(Icons.calendar_today_outlined),
                  onPressed: () => _onItemTapped(2),
                  color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
                ),
                IconButton(
                  icon: Icon(Icons.person_outline),
                  onPressed: () => _onItemTapped(3),
                  color: _selectedIndex == 3 ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        isExtended: false,
        onPressed: () {
          // Ortadaki butona tıklanınca yapılacak işlemler
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
