// ignore_for_file: must_be_immutable, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, unnecessary_string_interpolations, sort_child_properties_last, avoid_print, use_rethrow_when_possible, depend_on_referenced_packages

import 'package:demo_app/inventoryAdd_screen.dart';
import 'package:demo_app/login_screen.dart';
import 'package:demo_app/dbHelper/constant.dart';
import 'package:demo_app/dbHelper/mongodb.dart';
import 'package:demo_app/dbHelper/mongodbDraft.dart';
import 'package:demo_app/returnVendor_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatelessWidget {
  final String userName;
  final String userLastName;
  final String userEmail;

  Dashboard({
    required this.userName,
    required this.userLastName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return SideBarLayout(
      title: "Dashboard",
      mainContent: DateTimeWidget(),
      userName: userName,
      userLastName: userLastName,
      userEmail: userEmail,
    );
  }
}

class Inventory extends StatefulWidget {
  final String userName;
  final String userLastName;
  final String userEmail;

  const Inventory({
    required this.userName,
    required this.userLastName,
    required this.userEmail,
  });

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  late Future<List<InventoryItem>> _futureInventory;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _futureInventory = _fetchInventoryData();
    });
  }

  Future<List<InventoryItem>> _fetchInventoryData() async {
    try {
      final db = await mongo.Db.create(INVENTORY_CONN_URL);
      await db.open();
      final collection = db.collection(USER_INVENTORY);

      // Query only items that match the current user's email
      final List<Map<String, dynamic>> results =
          await collection.find({'userEmail': widget.userEmail}).toList();

      await db.close();

      List<InventoryItem> inventoryItems =
          results.map((data) => InventoryItem.fromJson(data)).toList();
      return inventoryItems;
    } catch (e) {
      print('Error fetching inventory data: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideBarLayout(
        title: "Inventory",
        mainContent: RefreshIndicator(
          onRefresh: () async {
            _fetchData();
          },
          child: FutureBuilder<List<InventoryItem>>(
            future: _futureInventory,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.green, // This sets the color of the spinner
                  backgroundColor: Colors.transparent,
                ));
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<InventoryItem> inventoryItems = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: inventoryItems.length,
                  itemBuilder: (context, index) {
                    InventoryItem item =
                        inventoryItems.reversed.toList()[index];
                    return ListTile(
                      title: Text(
                        item.week,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.date}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Input ID: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.inputId}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Merchandiser: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.name}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Account Name Branch Manning: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.accountNameBranchManning}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Period: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.period}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Month: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.month}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Week: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.week}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Category: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text('${item.category}'),
                            SizedBox(height: 10),
                            Text(
                              'SKU Description: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.skuDescription}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Products: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.products}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'SKU Code: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.skuCode}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Status: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.status}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Beginning: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.beginning}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Delivery: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.delivery}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Ending: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.ending}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Offtake: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.offtake}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Inventory Days Level: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.inventoryDaysLevel}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Number of Days OOS: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.noOfDaysOOS}',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        appBarActions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              // Manually refresh inventory data
              _fetchData();
            },
          ),
        ],
        userName: widget.userName,
        userLastName: widget.userLastName,
        userEmail: widget.userEmail,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddInventory(
                userName: widget.userName,
                userLastName: widget.userLastName,
                userEmail: widget.userEmail,
              ),
            ),
          );
        },
        child: Icon(
          Icons.assignment_add,
          color: Colors.white,
        ),
        backgroundColor: Colors.green, // Customize the background color
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class RTV extends StatefulWidget {
  final String userName;
  final String userLastName;
  final String userEmail;

  RTV({
    required this.userName,
    required this.userLastName,
    required this.userEmail,
  });

  @override
  _RTVState createState() => _RTVState();
}

class _RTVState extends State<RTV> {
  late Future<List<ReturnToVendor>> _futureRTV;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _futureRTV = _fetchRTVData();
    });
  }

  Future<List<ReturnToVendor>> _fetchRTVData() async {
    try {
      final db = await mongo.Db.create(MONGO_CONN_URL);
      await db.open();
      final collection = db.collection(USER_RTV);

      // Query only items that match the current user's email
      final List<Map<String, dynamic>> results =
          await collection.find({'userEmail': widget.userEmail}).toList();

      await db.close();

      List<ReturnToVendor> rtvItems =
          results.map((data) => ReturnToVendor.fromJson(data)).toList();
      return rtvItems;
    } catch (e) {
      print('Error fetching RTV data: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideBarLayout(
        title: "Return To Vendor",
        mainContent: RefreshIndicator(
          onRefresh: () async {
            // Manually refresh RTV data
            _fetchData();
          },
          child: FutureBuilder<List<ReturnToVendor>>(
            future: _futureRTV,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(
                  color: Colors.green, // This sets the color of the spinner
                  backgroundColor: Colors.transparent,
                ));
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<ReturnToVendor> rtvItems = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: rtvItems.length,
                  itemBuilder: (context, index) {
                    ReturnToVendor item = rtvItems.reversed.toList()[index];
                    return ListTile(
                      subtitle: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.0,
                          ),
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.date}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Merchandiser: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.merchandiserName}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Outlet: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.outlet}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Category: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.category}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Item: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.item}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Quantity: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.quantity}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Driver\'s Name: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.driverName}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Plate Number: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.plateNumber}',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Pull Out Reason: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              '${item.pullOutReason}',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        appBarActions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              // Manually refresh RTV data
              _fetchData();
            },
          ),
        ],
        userName: widget.userName,
        userLastName: widget.userLastName,
        userEmail: widget.userEmail,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ReturnVendor(
              userName: widget.userName,
              userLastName: widget.userLastName,
              userEmail: widget.userEmail,
            ),
          ));
        },
        child: Icon(
          Icons.assignment_add,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class Setting extends StatelessWidget {
  final String userName;
  final String userLastName;
  final String userEmail;

  Setting({
    required this.userName,
    required this.userLastName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return SideBarLayout(
      title: "Settings",
      mainContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 650, // Add space between the button and surrounding content
          ),
          Center(
            child: SizedBox(
              height: 50,
              width: 350, // Set width to match the screen width
              child: ElevatedButton(
                onPressed: () {
                  _logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900], // Set button color here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'LOG OUT',
                  style: TextStyle(
                    color: Colors.white, // Set text color here
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      userName: userName,
      userLastName: userLastName,
      userEmail: userEmail,
    );
  }
}

Future<void> _logout(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Navigate back to the login screen after logout
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    print('Error logging out: $e');
    // Handle error
  }
}

class SideBarLayout extends StatefulWidget {
  final String title;
  final Widget mainContent;
  final List<Widget>? appBarActions;
  String userName;
  String userLastName;
  String userEmail;

  SideBarLayout({
    required this.title,
    required this.mainContent,
    this.appBarActions,
    required this.userName,
    required this.userLastName,
    required this.userEmail,
  });

  @override
  _SideBarLayoutState createState() => _SideBarLayoutState();
}

class _SideBarLayoutState extends State<SideBarLayout> {
  String userName = '';
  String userLastName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final userInfo =
          await MongoDatabase.getUserDetailsByUsername('user_id_here');
      if (userInfo != null) {
        print(userInfo); // Print the retrieved user information
        setState(() {
          widget.userName = userInfo['firstName'] ?? '';
          widget.userLastName = userInfo['lastName'] ?? '';
          widget.userEmail = userInfo['emailAddress'] ?? '';
        });
      } else {
        // Handle case where user info is null
      }
    } catch (e) {
      // Handle error
      print('Error fetching user info: $e');
      // Show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserInfo(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green[900]!,
                    Colors.green[800]!,
                    Colors.green[400]!,
                  ],
                ),
              ),
            ),
            title: Text(
              widget.title,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            actions: widget.appBarActions,
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    '${widget.userName} ${widget.userLastName}',
                    style: TextStyle(color: Colors.white),
                  ),
                  accountEmail: Text(
                    widget.userEmail,
                    style: TextStyle(color: Colors.white),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green[900]!,
                        Colors.green[800]!,
                        Colors.green[400]!,
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.home_outlined,
                  ),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => Dashboard(
                                userName: widget.userName,
                                userLastName: widget.userLastName,
                                userEmail: widget.userEmail,
                              )),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Inventory'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => Inventory(
                                userName: widget.userName,
                                userLastName: widget.userLastName,
                                userEmail: widget.userEmail,
                              )),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_return_outlined),
                  title: const Text('Return To Vendor'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => RTV(
                                userName: widget.userName,
                                userLastName: widget.userLastName,
                                userEmail: widget.userEmail,
                              )),
                    );
                  },
                ),
                const Divider(color: Colors.black),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => Setting(
                                userName: widget.userName,
                                userLastName: widget.userLastName,
                                userEmail: widget.userEmail,
                              )),
                    );
                  },
                ),
              ],
            ),
          ),
          body: widget.mainContent,
        );
      },
    );
  }
}

class DateTimeWidget extends StatefulWidget {
  @override
  _DateTimeWidgetState createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    // Initialize the current time and start the timer to update it periodically
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  void _updateTime(Timer timer) {
    // Update the current time every second
    setState(() {
      _currentTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('h:mm a').format(_currentTime);
    String dayOfWeek = DateFormat('EEEE').format(_currentTime);
    String formattedDate = DateFormat.yMMMMd().format(_currentTime);

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '$formattedDate, $dayOfWeek',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
