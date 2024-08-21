// ignore_for_file: non_constant_identifier_names, unused_import, depend_on_referenced_packages, prefer_const_constructors, use_key_in_widget_constructors, camel_case_types, prefer_final_fields, library_private_types_in_public_api, prefer_const_constructors_in_immutables, avoid_print, use_build_context_synchronously
import 'dart:math';
import 'package:demo_app/dashboard_screen.dart';
import 'package:demo_app/dbHelper/constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class ReturnVendor extends StatefulWidget {
  final String userName;
  final String userLastName;
  final String userEmail;
  final String userMiddleName;
  final String userContactNum;

  ReturnVendor({
    required this.userName,
    required this.userLastName,
    required this.userEmail,
    required this.userContactNum,
    required this.userMiddleName,
  });

  @override
  _ReturnVendorState createState() => _ReturnVendorState();
}

class _ReturnVendorState extends State<ReturnVendor> {
  late String selectedOutlet = ''; // Initialize with an empty string
  late String selectedItem = ''; // Initialize with an empty string
  late String quantity = '';
  late DateTime selectedDate = DateTime.now(); // Initialize with current date
  String merchandiserName = '';
  String driverName = '';
  String plateNumber = '';
  String pullOutReason = '';
  String selectedCategory = '';
  String inputId = '';
  List<String> outletOptions = [];
  List<String> itemOptions = [];
  bool isPending = true;
  bool isSaveEnabled = false; // Ensure this is initialized properly

  // Add fetchOutlets method to fetch outlets from the database
  Future<void> fetchOutlets() async {
    try {
      final db = await mongo.Db.create(INVENTORY_CONN_URL);
      await db.open();

      final collection = db.collection(USER_COLLECTION);
      final Map<String, dynamic>? userDoc = await collection
          .findOne(mongo.where.eq('emailAddress', widget.userEmail));

      if (userDoc != null) {
        print('User document found: $userDoc');
        setState(() {
          outletOptions = userDoc['accountNameBranchManning']
              .cast<String>(); // Convert to List<String>
          selectedOutlet = outletOptions.isNotEmpty ? outletOptions.first : '';
        });
      } else {
        print('No user document found for email: ${widget.userEmail}');
      }

      await db.close();
    } catch (e) {
      print('Error fetching outlets from database: $e');
    }
  }

  void fetchDataFromDatabase(String userEmail) async {
    try {
      final db = await mongo.Db.create(INVENTORY_CONN_URL);
      await db.open();

      final collection = db.collection(USER_COLLECTION);
      final Map<String, dynamic>? userDoc =
          await collection.findOne(mongo.where.eq('emailAddress', userEmail));

      if (userDoc != null) {
        setState(() {
          selectedOutlet = userDoc['accountNameBranchManning'][0] ?? '';
          // Assuming you want to select the first item in the array
          // Modify the index as needed based on your data structure
        });
      }

      await db.close();
    } catch (e) {
      print('Error fetching data from database: $e');
    }
  }

  Map<String, List<String>> _categoryToSkuDescriptions = {
    'V1': [
      'KOPIKO COFFEE CANDY 24X175G',
      // Add more SKU descriptions...
    ],
    'V2': [
      'KOPIKO BLACK 3 IN ONE HANGER 24 X 10 X 30G',
      // Add more SKU descriptions...
    ],
    'V3': [
      'LE MINERALE 24x330ML',
      // Add more SKU descriptions...
    ],
  };

  void initState() {
    super.initState();
    fetchDataFromDatabase(widget.userEmail);
    if (_categoryToSkuDescriptions.isNotEmpty) {
      selectedCategory = _categoryToSkuDescriptions.keys.first;
    }
    updateItemOptions(selectedCategory);
    fetchOutlets(); // Call fetchOutlets when the widget is initialized
    inputId = generateInputID();
  }

  void updateItemOptions(String category) {
    setState(() {
      switch (category) {
        case 'V1':
          itemOptions = [
            'KOPIKO COFFEE CANDY 24X175G',
            'KOPIKO COFFEE CANDY JAR 6X560G',
            'KOPIKO CAPPUCCINO CANDY 24X175G',
            'FRES BARLEY MINT 24X50X3G',
            'FRES MINT BARLEY JAR 12X2003G',
            'FRES MINT BARLEY CANDY BIGPACK 6X1350G',
            'FRES CHERRY CANDY, 24 X 50 X 3G',
            'FRES CHERRY JAR, 12X 200 X 3G',
            'FRES MINT CHERRY CANDY BIGPACK 6X1350G',
            'FRES CANDY CANDY BIGPACK 24 X 50 X 3G',
            'FRES GRAPE JAR, 12 X 200 X 3G',
            'FRES APPLE PEACH 24 X 50 X 3G',
            'FRES APPLEPEACH CANDY BIGPACK 6X1350G',
            'FRES MIXED CANDY JAR 12 X 600G',
            'BENG BENG CHOCOLATE 12 X 10 X 26.5G',
            'BENG BENG SHARE IT 16 X 95G',
            'CAL CHEESE 10X20X8.5G',
            'CAL CHEESE 60X35G',
            'CAL CHEESE 60X53.5G',
            'CAL CHEESE CHEESE CHOCO 60X53.5G',
            'CAL CHEESE CHEESE CHOCO 60X35G',
            'MALKIST CHOCOLATE 30X10X24G',
            'ROMA CREAM CRACKERS',
            'WAFELLO CHOCOLATE WAFER 60X53.5G',
            'WAFELLO CHOCOLATE WAFER 60X35G',
            'WAFELLO BUTTER CARAMEL 60X35G',
            'WAFELLO COCO CREME 60X35G',
            'WAFELLO CREAMY VANILLA 20X10X20.5G PH',
            'VALMER CHOCOLATE 12X10X54G',
            'SUPERSTAR TRIPLE CHOCOLATE 12 X10 X 18G',
            'DANISA BUTTER COOKIES 12X454G',
          ];
          break;
        case 'V2':
          itemOptions = [
            'KOPIKO BLACK 3 IN ONE HANGER 24 X 10 X 30G',
            'KOPIKO BLACK 3 IN ONE POUCH 24 X 10 X 30G',
            'KOPIKO BLACK 3 IN ONE BAG 8 X 30 X 30G',
            'KOPIKO BLACK 3 IN ONE PROMO TWIN 12 X 10 X 2 X 30G',
            'KOPIKO BROWN COFFEE HG 27.5G 24 X 10 X 27.5G',
            'KOPIKO BROWN COFFEE POUCH 24 X 10 X 27.GG',
            'KOPIKO BROWN COFFEE BAG 8 X 30 X 27.5G',
            'KOPIKO BROWN PROMO TWIN 12 X 10 X 53G',
            'KOPIKO CAPPUCCINO HANGER 24 X 10 X 25G',
            'KOPIKO CAPPUCCINO POUCH 24 X 10 X 25G',
            'KOPIKO CAPPUCCINO BAG 8 X 30 X 25G',
            'KOPIKO L.A. COFFEE HANGER 24 X 10 X 25G',
            'KOPIKO L.A. COFFEE POUCH 24 X 10 X 25G',
            'KOPIKO BLANCA HANGER 24 X 10 X 25G',
            'KOPIKO BLANCA POUCH 24 X 10 X 30G',
            'KOPIKO BLANCA BAG 8 X 30 X 30G',
            'KOPIKO BLANCA TWINPACK 12 X 10 X 2 X 26G',
            'TORACAFE WHITE AND CREAMY 12 X (10 X 2) X 25G',
            'KOPIKO CREAMY CARAMELO 12 X (10 X 2) X 25G',
            'ENERGEN CHOCOLATE HANGER 24 X 10 X 40G',
            'ENERGEN CHOCOLATE POUCH 24 X 10 X 40G',
            'ENERGEN CHOCOLATE BAG 8 X 30 X 40G',
            'ENERGEN CHOCOLATE VANILLA HANGER 24 X 10 X 40G',
            'ENERGEN CHOCOLATE VANILLA POUCH 24 X 10 X 40G',
            'ENERGEN CHOCOLATE VANILLA BAG 8 X 30 X 40G',
            'ENERGEN CHAMPION NBA HANGER 24 X 10 X 35G',
            'ENERGEN PADESAL MATE 24 X 10 X 30G',
            'ENERGEN CHAMPION 12 X 10 X 2 X 35G PH',
            'KOPIKO CAFE MOCHA TP 12 X 10 X (2 X 25.5G) PH',
            'ENERGEN CHAMPION NBA TP 15 X 8 X 2 X 30G PH',
            'BLACK 420011 KOPIKO BLACK 3IN1 TWINPACK 12 X 10 X 2 X 28G',
          ];
          break;
        case 'V3':
          itemOptions = [
            'LE MINERALE 24x330ML',
            'LE MINERALE 24x600ML',
            'LE MINERALE 12x1500ML',
            'LE MINERALE 4 X 5000ML',
            'KOPIKO LUCKY DAY 24BTL X 180ML',
          ];
          break;
        default:
          itemOptions = [];
      }
      selectedItem = itemOptions.isNotEmpty ? itemOptions.first : '';
    });
  }

  String generateInputID() {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var random =
        Random().nextInt(10000); // Generate a random number between 0 and 9999
    var paddedRandom =
        random.toString().padLeft(4, '0'); // Ensure it has 4 digits
    return '2000$paddedRandom';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[600],
          elevation: 0,
          title: Text(
            'Return to Vendor Input',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Text(
                  'Input ID',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                TextFormField(
                  initialValue: generateInputID(),
                  enabled: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    hintText: 'Auto-generated Input ID',
                  ),
                ),
                Text(
                  'Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            enabled: false,
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            hintText:
                                DateFormat('yyyy-MM-dd').format(selectedDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Merchandiser',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextFormField(
                  enabled: false,
                  initialValue: '${widget.userName} ${widget.userLastName}',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    labelText: '',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Outlet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedOutlet,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: outletOptions.map((String outlet) {
                    return DropdownMenuItem(
                      value: outlet,
                      child: Text(outlet),
                    );
                  }).toList(),
                  onChanged: outletOptions.length == 1
                      ? null
                      : (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedOutlet = newValue;
                            });
                          }
                        },
                ),
                SizedBox(height: 16),
                Text(
                  'Pending or Not Pending',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: isPending ? 'Pending' : 'Not Pending',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: ['Pending', 'Not Pending'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        isPending = newValue == 'Pending';
                      });
                    }
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      _categoryToSkuDescriptions.keys.map((String category) {
                    return OutlinedButton(
                      onPressed: () => _toggleDropdown(category),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          width: 2.0,
                          color: selectedCategory == category
                              ? Colors.green
                              : Colors.blueGrey.shade200,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedItem,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: itemOptions.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: SizedBox(
                        width: 350,
                        child: Tooltip(
                          message: item,
                          child: Text(
                            item,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedItem = newValue;
                      });
                    }
                  },
                ),
                if (!isPending)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Quantity',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Input Quantity',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            quantity = value;
                            checkSaveEnabled();
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Driver\'s Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Input Driver\'s Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            driverName = value;
                            checkSaveEnabled();
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Plate Number',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Input Plate Number',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            plateNumber = value;
                            checkSaveEnabled();
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Pull Out Reason',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Input Pull Out Reason',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            pullOutReason = value;
                            checkSaveEnabled();
                          });
                        },
                      ),
                    ],
                  ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => RTV(
                              userName: widget.userName,
                              userLastName: widget.userLastName,
                              userEmail: widget.userEmail,
                              userContactNum: widget.userContactNum,
                              userMiddleName: widget.userMiddleName,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.green,
                        minimumSize: Size(150, 50),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isPending
                          ? _confirmSaveReturnToVendor
                          : (isSaveEnabled ? _confirmSaveReturnToVendor : null),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: (isSaveEnabled || isPending)
                            ? Colors.green
                            : Colors.grey,
                        minimumSize: Size(150, 50),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleDropdown(String value) {
    setState(() {
      selectedCategory = value;
      updateItemOptions(selectedCategory);
    });
  }

  void checkSaveEnabled() {
    setState(() {
      isSaveEnabled = quantity.isNotEmpty &&
          driverName.isNotEmpty &&
          plateNumber.isNotEmpty &&
          pullOutReason.isNotEmpty;
    });
  }

  void _confirmSaveReturnToVendor() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save Confirmation'),
          content: Text('Do you want to save this Return to Vendor?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if cancelled
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if confirmed
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      _saveReturnToVendor();
      // Navigate back to ReturnToVendor screen
      Navigator.of(context).pop();
    }
  }

  void _saveReturnToVendor() async {
    try {
      // Connect to the MongoDB database
      final db = await mongo.Db.create(INVENTORY_CONN_URL);
      await db.open();

      // Get the collection for return to vendor data
      final collection = db.collection(USER_RTV);

      // Generate a new ObjectId
      final objectId = ObjectId();

      // Construct the document to be inserted
      final document = {
        '_id': objectId,
        'userEmail': widget.userEmail,
        'inputId': inputId,
        'date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'merchandiserName': '${widget.userName} ${widget.userLastName}',
        'outlet': selectedOutlet,
        'category': selectedCategory,
        'item': selectedItem,
        'quantity': isPending ? 'Pending' : quantity,
        'driverName': isPending ? 'Pending' : driverName.toString(),
        'plateNumber': isPending ? 'Pending' : plateNumber.toString(),
        'pullOutReason': isPending ? 'Pending' : pullOutReason.toString(),
      };

      // Insert the document into the collection
      await collection.insert(document);

      // Close the database connection
      await db.close();

      print('Return to Vendor data saved successfully!');
    } catch (e) {
      print('Error saving Return to Vendor data: $e');
      // Handle errors here
    }
  }
}
