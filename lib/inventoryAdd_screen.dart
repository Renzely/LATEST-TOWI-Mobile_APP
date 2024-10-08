// ignore_for_file: prefer_final_fields, avoid_print, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, depend_on_referenced_packages, non_constant_identifier_names, unused_local_variable, use_build_context_synchronously, unused_element, avoid_unnecessary_containers, must_be_immutable

import 'dart:math';
import 'package:demo_app/dbHelper/constant.dart';
import 'package:demo_app/dbHelper/mongodb.dart';
import 'package:demo_app/dbHelper/mongodbDraft.dart';
import 'package:flutter/services.dart';
import 'package:demo_app/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bson/bson.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class AddInventory extends StatefulWidget {
  final String userName;
  final String userLastName;
  final String userEmail;
  String userContactNum;
  String userMiddleName;

  AddInventory({
    required this.userName,
    required this.userLastName,
    required this.userEmail,
    required this.userContactNum,
    required this.userMiddleName,
  });

  @override
  _AddInventoryState createState() => _AddInventoryState();
}

class _AddInventoryState extends State<AddInventory> {
  late TextEditingController _dateController;
  late DateTime _selectedDate;
  String? _selectedAccount;
  String? _selectedPeriod;
  late GlobalKey<FormState> _formKey;
  bool _isSaveEnabled = false;
  bool _showAdditionalInfo = false;
  TextEditingController _monthController = TextEditingController();
  TextEditingController _weekController = TextEditingController();
  String _selectedWeek = '';
  String _selectedMonth = '';

  List<String> _branchList = [];

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _selectedDate =
        DateTime.now(); // Initialize _selectedDate to the current date
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd')
          .format(_selectedDate), // Set initial text of controller
    );
    _weekController.addListener(() {
      setState(() {
        _selectedWeek = _weekController.text;
      });
    });
    _monthController.addListener(() {
      setState(() {
        _selectedMonth = _monthController.text;
      });
    });
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    try {
      final db = await mongo.Db.create(INVENTORY_CONN_URL);
      await db.open();
      final collection = db.collection(USER_COLLECTION);
      final List<Map<String, dynamic>> branchDocs = await collection
          .find(mongo.where.eq('emailAddress', widget.userEmail))
          .toList();
      setState(() {
        // Extract accountNameBranchManning from branchDocs and handle both single string and list cases
        _branchList = branchDocs
            .map((doc) => doc['accountNameBranchManning'])
            .where((branch) => branch != null)
            .expand((branch) => branch is List ? branch : [branch])
            .map((branch) => branch.toString())
            .toList();
        _selectedAccount = _branchList.isNotEmpty ? _branchList.first : '';
      });
      await db.close();
    } catch (e) {
      print('Error fetching branch data: $e');
    }
  }

  Future<void> fetchBranchForUser(String userEmail) async {
    try {
      final db = await mongo.Db.create(INVENTORY_CONN_URL);
      await db.open();
      final collection = db.collection(USER_COLLECTION);
      final Map<String, dynamic>? userData =
          await collection.findOne(mongo.where.eq('emailAddress', userEmail));
      if (userData != null) {
        final branchData = userData['accountNameBranchManning'];
        setState(() {
          _selectedAccount = branchData is List
              ? branchData.first.toString()
              : branchData.toString();
          _branchList = branchData is List
              ? branchData.map((branch) => branch.toString()).toList()
              : [branchData.toString()];
        });
      }
      await db.close();
    } catch (e) {
      print('Error fetching branch data for user: $e');
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _monthController.dispose();
    _weekController.dispose();
    super.dispose();
  }

  // String generateInputID() {
  //   var timestamp = DateTime.now().millisecondsSinceEpoch;
  //   var random =
  //       Random().nextInt(10000); // Generate a random number between 0 and 9999
  //   var paddedRandom =
  //       random.toString().padLeft(4, '0'); // Ensure it has 4 digits
  //   return '2000$paddedRandom';
  // }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: new MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.green[600],
                elevation: 0,
                title: Text(
                  'Inventory Input',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              body: SingleChildScrollView(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    width: MediaQuery.of(context).size.width * 1.0,
                    child: Form(
                      key: _formKey,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _dateController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: 16),
                            // Text(
                            //   'Input ID',
                            //   style: TextStyle(
                            //       fontWeight: FontWeight.bold, fontSize: 16),
                            // ),
                            // SizedBox(height: 8),
                            // TextFormField(
                            //   initialValue: generateInputID(),
                            //   readOnly: true,
                            //   decoration: InputDecoration(
                            //     border: OutlineInputBorder(),
                            //     contentPadding:
                            //         EdgeInsets.symmetric(horizontal: 12),
                            //     hintText: 'Auto-generated Input ID',
                            //   ),
                            // ),
                            SizedBox(height: 16),
                            Text(
                              'Merchandiser',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              initialValue:
                                  '${widget.userName} ${widget.userLastName}',
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Branch/Outlet',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.centerRight,
                                      children: [
                                        DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          value: _selectedAccount,
                                          items: _branchList.map((branch) {
                                            return DropdownMenuItem<String>(
                                              value: branch,
                                              child: Text(branch),
                                            );
                                          }).toList(),
                                          onChanged: _branchList.length > 1
                                              ? (value) {
                                                  setState(() {
                                                    _selectedAccount = value;
                                                    _isSaveEnabled =
                                                        _selectedAccount !=
                                                                null &&
                                                            _selectedPeriod !=
                                                                null;
                                                  });
                                                }
                                              : null, // Disable onChange when there is only one branch
                                          decoration: InputDecoration(
                                            hintText: 'Select',
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 12),
                                          ),
                                        ),
                                        // Conditionally show clear button
                                        if (_selectedAccount != null)
                                          Positioned(
                                            right: 8.0,
                                            child: IconButton(
                                              icon: Icon(Icons.clear),
                                              onPressed: () {
                                                setState(() {
                                                  _selectedAccount = null;
                                                  _selectedPeriod = null;
                                                  _showAdditionalInfo = false;
                                                  _isSaveEnabled = false;
                                                });
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedAccount != null) ...[
                              SizedBox(height: 16),
                              Text(
                                'Additional Information',
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Weeks Covered',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        alignment: Alignment.centerRight,
                                        children: [
                                          DropdownButtonFormField<String>(
                                            value: _selectedPeriod,
                                            items: [
                                              DropdownMenuItem(
                                                child: Text('Dec23-Dec29'),
                                                value: 'Dec23-Dec29',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Dec30-Jan05'),
                                                value: 'Dec30-Jan05',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jan06-Jan12'),
                                                value: 'Jan06-Jan12',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jan13-Jan19'),
                                                value: 'Jan13-Jan19',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jan20-Jan26'),
                                                value: 'Jan20-Jan26',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jan27-Feb02'),
                                                value: 'Jan27-Feb02',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Feb03-Feb09'),
                                                value: 'Feb03-Feb09',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Feb10-Feb16'),
                                                value: 'Feb10-Feb16',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Feb17-Feb23'),
                                                value: 'Feb17-Feb23',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Feb24-Mar01'),
                                                value: 'Feb24-Mar01',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Mar02-Mar08'),
                                                value: 'Mar02-Mar08',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Mar09-Mar15'),
                                                value: 'Mar09-Mar15',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Mar16-Mar22'),
                                                value: 'Mar16-Mar22',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Mar23-Mar29'),
                                                value: 'Mar23-Mar29',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Mar30-Apr05'),
                                                value: 'Mar30-Apr05',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Apr06-Apr12'),
                                                value: 'Apr06-Apr12',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Apr13-Apr19'),
                                                value: 'Apr13-Apr19',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Apr20-Apr26'),
                                                value: 'Apr20-Apr26',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Apr27-May03'),
                                                value: 'Apr27-May03',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('May04-May10'),
                                                value: 'May04-May10',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('May11-May17'),
                                                value: 'May11-May17',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('May18-May24'),
                                                value: 'May18-May24',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('May25-May31'),
                                                value: 'May25-May31',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jun01-Jun07'),
                                                value: 'Jun01-Jun07',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jun08-Jun14'),
                                                value: 'Jun08-Jun14',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jun15-Jun21'),
                                                value: 'Jun15-Jun21',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jun22-Jun28'),
                                                value: 'Jun22-Jun28',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jul06-Jul12'),
                                                value: 'Jul06-Jul12',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jul13-Jul19'),
                                                value: 'Jul13-Jul19',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jul20-Jul26'),
                                                value: 'Jul20-Jul26',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Jul27-Aug02'),
                                                value: 'Jul27-Aug02',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Aug03-Aug09'),
                                                value: 'Aug03-Aug09',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Aug10-Aug16'),
                                                value: 'Aug10-Aug16',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Aug24-Aug30'),
                                                value: 'Aug24-Aug30',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Aug31-Sep06'),
                                                value: 'Aug31-Sep06',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Sep07-Sep13'),
                                                value: 'Sep07-Sep13',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Sep14-Sep20'),
                                                value: 'Sep14-Sep20',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Sep21-Sep27'),
                                                value: 'Sep21-Sep27',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Sep28-Oct04'),
                                                value: 'Sep28-Oct04',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Oct05-Oct11'),
                                                value: 'Oct05-Oct11',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Oct12-Oct18'),
                                                value: 'Oct12-Oct18',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Oct19-Oct25'),
                                                value: 'Oct19-Oct25',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Oct26-Nov01'),
                                                value: 'Oct26-Nov01',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Nov02-Nov08'),
                                                value: 'Nov02-Nov08',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Nov09-Nov15'),
                                                value: 'Nov09-Nov15',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Nov16-Nov22'),
                                                value: 'Nov16-Nov22',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Nov23-Nov29'),
                                                value: 'Nov23-Nov29',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Nov30-Dec06'),
                                                value: 'Nov30-Dec06',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Dec07-Dec13'),
                                                value: 'Dec07-Dec13',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Dec14-Dec20'),
                                                value: 'Dec14-Dec20',
                                              ),
                                              DropdownMenuItem(
                                                child: Text('Dec21-Dec27'),
                                                value: 'Dec21-Dec27',
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedPeriod = value;
                                                _isSaveEnabled =
                                                    _selectedAccount != null &&
                                                        _selectedPeriod != null;
                                                switch (value) {
                                                  case 'Dec23-Dec29':
                                                    _monthController.text =
                                                        'December';
                                                    _weekController.text =
                                                        'Week 52';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Dec30-Jan05':
                                                    _monthController.text =
                                                        'January';
                                                    _weekController.text =
                                                        'Week 1';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jan06-Jan12':
                                                    _monthController.text =
                                                        'January';
                                                    _weekController.text =
                                                        'Week 2';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jan13-Jan19':
                                                    _monthController.text =
                                                        'January';
                                                    _weekController.text =
                                                        'Week 3';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jan20-Jan26':
                                                    _monthController.text =
                                                        'January';
                                                    _weekController.text =
                                                        'Week 4';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jan27-Feb02':
                                                    _monthController.text =
                                                        'February';
                                                    _weekController.text =
                                                        'Week 5';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Feb03-Feb09':
                                                    _monthController.text =
                                                        'February';
                                                    _weekController.text =
                                                        'Week 6';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Feb10-Feb16':
                                                    _monthController.text =
                                                        'February';
                                                    _weekController.text =
                                                        'Week 7';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Feb17-Feb23':
                                                    _monthController.text =
                                                        'February';
                                                    _weekController.text =
                                                        'Week 8';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Feb24-Mar01':
                                                    _monthController.text =
                                                        'March';
                                                    _weekController.text =
                                                        'Week 9';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Mar02-Mar08':
                                                    _monthController.text =
                                                        'March';
                                                    _weekController.text =
                                                        'Week 10';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Mar09-Mar15':
                                                    _monthController.text =
                                                        'March';
                                                    _weekController.text =
                                                        'Week 11';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Mar16-Mar22':
                                                    _monthController.text =
                                                        'March';
                                                    _weekController.text =
                                                        'Week 12';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Mar23-Mar29':
                                                    _monthController.text =
                                                        'March';
                                                    _weekController.text =
                                                        'Week 13';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Mar30-Apr05':
                                                    _monthController.text =
                                                        'April';
                                                    _weekController.text =
                                                        'Week 14';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Apr06-Apr12':
                                                    _monthController.text =
                                                        'April';
                                                    _weekController.text =
                                                        'Week 15';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Apr13-Apr19':
                                                    _monthController.text =
                                                        'April';
                                                    _weekController.text =
                                                        'Week 16';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Apr20-Apr26':
                                                    _monthController.text =
                                                        'April';
                                                    _weekController.text =
                                                        'Week 17';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Apr27-May03':
                                                    _monthController.text =
                                                        'May';
                                                    _weekController.text =
                                                        'Week 18';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'May04-May10':
                                                    _monthController.text =
                                                        'May';
                                                    _weekController.text =
                                                        'Week 19';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'May11-May17':
                                                    _monthController.text =
                                                        'May';
                                                    _weekController.text =
                                                        'Week 20';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'May18-May24':
                                                    _monthController.text =
                                                        'May';
                                                    _weekController.text =
                                                        'Week 21';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'May25-May31':
                                                    _monthController.text =
                                                        'May';
                                                    _weekController.text =
                                                        'Week 22';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jun01-Jun07':
                                                    _monthController.text =
                                                        'June';
                                                    _weekController.text =
                                                        'Week 23';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jun08-Jun14':
                                                    _monthController.text =
                                                        'June';
                                                    _weekController.text =
                                                        'Week 24';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jun15-Jun21':
                                                    _monthController.text =
                                                        'June';
                                                    _weekController.text =
                                                        'Week 25';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jun22-Jun28':
                                                    _monthController.text =
                                                        'June';
                                                    _weekController.text =
                                                        'Week 26';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jun29-Jul05':
                                                    _monthController.text =
                                                        'July';
                                                    _weekController.text =
                                                        'Week 27';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jul06-Jul12':
                                                    _monthController.text =
                                                        'July';
                                                    _weekController.text =
                                                        'Week 28';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jul13-Jul19':
                                                    _monthController.text =
                                                        'July';
                                                    _weekController.text =
                                                        'Week 29';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jul20-Jul26':
                                                    _monthController.text =
                                                        'July';
                                                    _weekController.text =
                                                        'Week 30';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Jul27-Aug02':
                                                    _monthController.text =
                                                        'August';
                                                    _weekController.text =
                                                        'Week 31';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Aug03-Aug09':
                                                    _monthController.text =
                                                        'August';
                                                    _weekController.text =
                                                        'Week 32';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Aug10-Aug16':
                                                    _monthController.text =
                                                        'August';
                                                    _weekController.text =
                                                        'Week 33';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Aug17-Aug23':
                                                    _monthController.text =
                                                        'August';
                                                    _weekController.text =
                                                        'Week 34';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Aug24-Aug30':
                                                    _monthController.text =
                                                        'August';
                                                    _weekController.text =
                                                        'Week 35';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Aug31-Sep06':
                                                    _monthController.text =
                                                        'September';
                                                    _weekController.text =
                                                        'Week 36';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Sep07-Sep13':
                                                    _monthController.text =
                                                        'September';
                                                    _weekController.text =
                                                        'Week 37';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Sep14-Sep20':
                                                    _monthController.text =
                                                        'September';
                                                    _weekController.text =
                                                        'Week 38';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Sep21-Sep27':
                                                    _monthController.text =
                                                        'September';
                                                    _weekController.text =
                                                        'Week 39';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Sep28-Oct04':
                                                    _monthController.text =
                                                        'October';
                                                    _weekController.text =
                                                        'Week 40';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Oct05-Oct11':
                                                    _monthController.text =
                                                        'October';
                                                    _weekController.text =
                                                        'Week 41';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Oct12-Oct18':
                                                    _monthController.text =
                                                        'October';
                                                    _weekController.text =
                                                        'Week 42';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Oct19-Oct25':
                                                    _monthController.text =
                                                        'October';
                                                    _weekController.text =
                                                        'Week 43';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Oct26-Nov01':
                                                    _monthController.text =
                                                        'November';
                                                    _weekController.text =
                                                        'Week 44';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Nov02-Nov08':
                                                    _monthController.text =
                                                        'November';
                                                    _weekController.text =
                                                        'Week 45';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Nov09-Nov15':
                                                    _monthController.text =
                                                        'November';
                                                    _weekController.text =
                                                        'Week 46';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Nov16-Nov22':
                                                    _monthController.text =
                                                        'November';
                                                    _weekController.text =
                                                        'Week 47';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Nov23-Nov29':
                                                    _monthController.text =
                                                        'November';
                                                    _weekController.text =
                                                        'Week 48';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Nov30-Dec06':
                                                    _monthController.text =
                                                        'December';
                                                    _weekController.text =
                                                        'Week 49';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Dec07-Dec13':
                                                    _monthController.text =
                                                        'December';
                                                    _weekController.text =
                                                        'Week 50';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Dec14-Dec20':
                                                    _monthController.text =
                                                        'December';
                                                    _weekController.text =
                                                        'Week 51';
                                                    _showAdditionalInfo = true;
                                                    break;
                                                  case 'Dec21-Dec27':
                                                    _monthController.text =
                                                        'December';
                                                    _weekController.text =
                                                        'Week 52';
                                                    _showAdditionalInfo = true;
                                                    break;

                                                  default:
                                                    _monthController.clear();
                                                    _weekController.clear();
                                                    _showAdditionalInfo = false;
                                                    break;
                                                }
                                              });
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Select Period',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 12),
                                            ),
                                          ),
                                          if (_selectedPeriod != null)
                                            Positioned(
                                              right: 8.0,
                                              child: IconButton(
                                                icon: Icon(Icons.clear),
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedPeriod = null;
                                                    _showAdditionalInfo = false;
                                                    _isSaveEnabled = false;
                                                  });
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_showAdditionalInfo) ...[
                                SizedBox(height: 16),
                                Text('Month',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                                SizedBox(height: 8),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Select Period',
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  controller: _monthController,
                                  readOnly: true,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Week',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Select Period',
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  controller: _weekController,
                                  readOnly: true,
                                ),
                              ],
                            ],
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Perform cancel action

                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => Inventory(
                                          userName: widget.userName,
                                          userLastName: widget.userLastName,
                                          userEmail: widget.userEmail,
                                          userContactNum: widget.userContactNum,
                                          userMiddleName: widget.userMiddleName,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                          EdgeInsetsGeometry>(
                                        const EdgeInsets.symmetric(
                                            vertical: 15),
                                      ),
                                      minimumSize:
                                          MaterialStateProperty.all<Size>(
                                        const Size(150, 50),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.green)),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _isSaveEnabled
                                      ? () {
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SKUInventory(
                                                        userName:
                                                            widget.userName,
                                                        userLastName:
                                                            widget.userLastName,
                                                        userEmail:
                                                            widget.userEmail,
                                                        userContactNum: widget
                                                            .userContactNum,
                                                        userMiddleName: widget
                                                            .userMiddleName,
                                                        selectedAccount:
                                                            _selectedAccount ??
                                                                '',
                                                        SelectedPeriod:
                                                            _selectedPeriod!,
                                                        selectedWeek:
                                                            _selectedWeek,
                                                        selectedMonth:
                                                            _selectedMonth,
                                                        // inputid: generateInputID(),
                                                      )));
                                        }
                                      : null,
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all<
                                        EdgeInsetsGeometry>(
                                      const EdgeInsets.symmetric(vertical: 15),
                                    ),
                                    minimumSize:
                                        MaterialStateProperty.all<Size>(
                                      const Size(150, 50),
                                    ),
                                    backgroundColor: _isSaveEnabled
                                        ? MaterialStateProperty.all<Color>(
                                            Colors.green)
                                        : MaterialStateProperty.all<Color>(
                                            Colors.grey),
                                  ),
                                  child: const Text(
                                    'Next',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
            )));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }
}

class SKUInventory extends StatefulWidget {
  final String userName;
  final String userLastName;
  final String userEmail;
  final String selectedAccount;
  final String SelectedPeriod;
  final String selectedWeek;
  final String selectedMonth;
  //final String inputid;
  String userContactNum;
  String userMiddleName;

  SKUInventory({
    required this.userName,
    required this.userLastName,
    required this.userEmail,
    required this.selectedAccount,
    required this.SelectedPeriod,
    required this.selectedWeek,
    required this.selectedMonth,
    // required this.inputid,
    required this.userContactNum,
    required this.userMiddleName,
  });

  @override
  _SKUInventoryState createState() => _SKUInventoryState();
}

class _SKUInventoryState extends State<SKUInventory> {
  bool _isDropdownVisible = false;
  String? _selectedaccountname;
  String? _selectedDropdownValue;
  String? _productDetails;
  String? _skuCode;
  String? _versionSelected;
  String? _statusSelected;
  String? _selectedPeriod;
  String? _remarksOOS;
  String? _reasonOOS;
  String? _selectedNoDeliveryOption;
  String _inputid = '';
  int? _selectedNumberOfDaysOOS;
  bool _showCarriedTextField = false;
  bool _showNotCarriedTextField = false;
  bool _showDelistedTextField = false;
  bool _isSaveEnabled = false;
  bool _isEditing = true;
  TextEditingController _beginningSAController = TextEditingController();
  TextEditingController _beginningWAController = TextEditingController();
  TextEditingController _endingSAController = TextEditingController();
  TextEditingController _endingWAController = TextEditingController();
  TextEditingController _beginningController = TextEditingController();
  TextEditingController _deliveryController = TextEditingController();
  TextEditingController _endingController = TextEditingController();
  TextEditingController _offtakeController = TextEditingController();
  TextEditingController _inventoryDaysLevelController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _productsController = TextEditingController();
  TextEditingController _skuCodeController = TextEditingController();
  TextEditingController _noPOController = TextEditingController();
  TextEditingController _unservedController = TextEditingController();
  TextEditingController _nodeliveryController = TextEditingController();
  List<Widget> _expiryFields = [];
  List<Map<String, dynamic>> _expiryFieldsValues = [];
  bool _showNoPOTextField = false;
  bool _showUnservedTextField = false;
  bool _showNoDeliveryDropdown = false;
  String selectedBranch = 'BranchName'; // Get this from user input or selection
  List<String> _availableSkuDescriptions = [];

  String generateInputID() {
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var random =
        Random().nextInt(10000); // Generate a random number between 0 and 9999
    var paddedRandom =
        random.toString().padLeft(4, '0'); // Ensure it has 4 digits
    return '2000$paddedRandom';
  }

  Future<void> _updateEditingStatus(
      String inputId, String userEmail, bool isEditing) async {
    try {
      final db = await mongo.Db.create(
          INVENTORY_CONN_URL); // Ensure 'mongo' is imported correctly
      await db.open();
      final collection = db.collection(USER_INVENTORY);

      // Update the document where 'inputId' and 'userEmail' match, setting 'isEditing' to the provided value
      await collection.update(
        mongo.where.eq('inputId', inputId).eq('userEmail', userEmail),
        mongo.modify.set('isEditing', isEditing),
      );

      await db.close();
    } catch (e) {
      print('Error updating editing status: $e');
    }
  }

  void _saveInventoryItem() async {
    String inputid = _inputid;
    String AccountManning = _selectedaccountname ?? '';
    String period = _selectedPeriod ?? '';
    String Version = _versionSelected ?? '';
    String status = _statusSelected ?? '';
    String SKUDescription = _selectedDropdownValue ?? '';
    String product = _productDetails ?? '';
    String skucode = _skuCode ?? '';
    String remarksOOS = _remarksOOS ?? '';
    String reasonOOS = _reasonOOS ?? '';
    bool edit = _isEditing;
    int numberOfDaysOOS = _selectedNumberOfDaysOOS ?? 0;

    int beginningSA = int.tryParse(_beginningSAController.text) ?? 0;
    int beginningWA = int.tryParse(_beginningWAController.text) ?? 0;

    int newBeginning = beginningSA + beginningWA;

    int endingSA = int.tryParse(_endingSAController.text) ?? 0;
    int endingWA = int.tryParse(_endingWAController.text) ?? 0;

    int newEnding = endingSA + endingWA;

    int beginning = int.tryParse(_beginningController.text) ?? 0;
    int delivery = int.tryParse(_deliveryController.text) ?? 0;
    int ending = int.tryParse(_endingController.text) ?? 0;

    int offtake = beginning + delivery - ending;
    double inventoryDaysLevel = 0;

    if (status != "Not Carried" && status != "Delisted") {
      if (offtake != 0 && ending != double.infinity && !ending.isNaN) {
        inventoryDaysLevel = ending / (offtake / 7);
      }
    }

    dynamic ncValue = 'NC';
    dynamic delistedValue = 'Delisted';
    dynamic beginningValue = beginning;
    dynamic beginningSAValue = beginningSA;
    dynamic beginningWAValue = beginningWA;
    dynamic deliveryValue = delivery;
    dynamic endingValue = ending;
    dynamic endingSAValue = endingSA;
    dynamic endingWAValue = endingWA;
    dynamic offtakeValue = offtake;
    dynamic noOfDaysOOSValue = numberOfDaysOOS;

    if (status == 'Delisted') {
      beginningValue = delistedValue;
      beginningSAValue = deliveryValue;
      beginningWAValue = delistedValue;
      deliveryValue = delistedValue;
      endingValue = delistedValue;
      endingSAValue = delistedValue;
      endingWAValue = deliveryValue;
      offtakeValue = delistedValue;
      noOfDaysOOSValue = delistedValue;
      _expiryFieldsValues = [
        {'expiryMonth': delistedValue, 'expiryPcs': delistedValue}
      ];
    } else if (status == 'Not Carried') {
      beginningValue = ncValue;
      beginningSAValue = ncValue;
      beginningWAValue = ncValue;
      deliveryValue = ncValue;
      endingValue = ncValue;
      endingSAValue = ncValue;
      endingWAValue = ncValue;
      offtakeValue = ncValue;
      noOfDaysOOSValue = ncValue;
      _expiryFieldsValues = [
        {'expiryMonth': ncValue, 'expiryPcs': ncValue}
      ];
    }

    InventoryItem newItem = InventoryItem(
      id: ObjectId(), // Generate this as needed
      userEmail: widget.userEmail,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()), // Current date
      inputId: inputid,
      name: '${widget.userName} ${widget.userLastName}',
      accountNameBranchManning: widget.selectedAccount,
      period: widget.SelectedPeriod,
      month: widget.selectedMonth,
      week: widget.selectedWeek,
      category: Version,
      skuDescription: SKUDescription,
      products: product,
      skuCode: skucode,
      status: status,
      beginning: beginningValue,
      beginningSA: beginningSAValue,
      beginningWA: beginningWAValue,
      delivery: deliveryValue,
      ending: endingValue,
      endingSA: endingSAValue,
      endingWA: endingWAValue,
      offtake: offtakeValue,
      inventoryDaysLevel: inventoryDaysLevel.toDouble(),
      noOfDaysOOS: noOfDaysOOSValue,
      expiryFields: _expiryFieldsValues,
      remarksOOS: remarksOOS,
      reasonOOS: reasonOOS,
      isEditing: true, // Set to false when saving new item
    );

    await _saveToDatabase(newItem);

    // Update status of the original item if editing
    if (_isEditing) {
      await _updateEditingStatus(inputid, widget.userEmail, false);
    }
  }

  Future<void> _saveToDatabase(InventoryItem item) async {
    try {
      final db = await mongo.Db.create(INVENTORY_CONN_URL);
      await db.open();
      final collection = db.collection(USER_INVENTORY);
      final Map<String, dynamic> itemMap = item.toJson();
      await collection.insert(itemMap);
      await db.close();
      print('Inventory item saved to database');
    } catch (e) {
      print('Error saving inventory item: $e');
    }
  }

  Future<List<InventoryItem>> getUserInventoryItems(String userEmail) async {
    List<InventoryItem> items = [];
    try {
      final db = await mongo.Db.create(INVENTORY_CONN_URL);
      await db.open();
      final collection = db.collection(USER_INVENTORY);
      final result = await collection.find({'userEmail': userEmail}).toList();

      for (var doc in result) {
        items.add(InventoryItem.fromJson(doc));
      }

      await db.close();
    } catch (e) {
      print('Error fetching inventory items: $e');
    }
    return items;
  }

  void _addExpiryField() {
    setState(() {
      if (_expiryFields.length < 6) {
        int index = _expiryFields.length;
        _expiryFields.add(
          ExpiryField(
            index: index,
            onExpiryFieldChanged: (month, pcs, index) {
              _updateExpiryField(
                  index, {'expiryMonth': month, 'expiryPcs': pcs});
            },
            onDeletePressed: () {
              _removeExpiryField(index);
            },
          ),
        );
        _expiryFieldsValues.add({'expiryMonth': '', 'expiryPcs': 0});
      }
    });
  }

  void _removeExpiryField(int index) {
    setState(() {
      _expiryFields.removeAt(index);
      _expiryFieldsValues.removeAt(index);

      // Update the index of remaining fields
      for (int i = index; i < _expiryFields.length; i++) {
        _expiryFields[i] = ExpiryField(
          index: i,
          onExpiryFieldChanged: (month, pcs, index) {
            _updateExpiryField(index, {'expiryMonth': month, 'expiryPcs': pcs});
          },
          onDeletePressed: () {
            _removeExpiryField(i);
          },
        );
      }
    });
  }

  void _updateExpiryField(int index, Map<String, dynamic> newValue) {
    setState(() {
      _expiryFieldsValues[index] = newValue;
    });
  }

  Map<String, List<String>> _categoryToSkuDescriptions = {
    'V1': [
      "KOPIKO COFFEE CANDY 24X175G",
      "KOPIKO COFFEE CANDY JAR 6X560G",
      "KOPIKO CAPPUCCINO CANDY 24X175G",
      "FRES BARLEY MINT 24X50X3G",
      "FRES MINT BARLEY JAR 12X200X3G",
      "FRES CHERRY CANDY, 24 X 50 X 3G",
      "FRES CHERRY JAR, 12X 200 X 3G",
      "FRES GRAPE CANDY, 24 X 50 X 3G",
      "FRES GRAPE JAR, 12 X 200 X 3G",
      "FRES APPLE PEACH 24 X 50 X 3G",
      "BENG BENG CHOCOLATE 12 X 10 X 26.5G",
      "BENG BENG SHARE IT 16 X 95G",
      "CAL CHEESE 10X20X8.5G",
      "CAL CHEESE 60X35G",
      "CAL CHEESE 60X53.5G",
      "CAL CHEESE CHEESE CHOCO 60X53.5G",
      "CAL CHEESE CHEESE CHOCO 60X35G",
      "MALKIST CHOCOLATE 30X10X18G",
      "WAFELLO CHOCOLATE WAFER 60X53.5G",
      "WAFELLO CHOCOLATE WAFER 60X35G",
      "WAFELLO BUTTER CARAMEL 60X35G",
      "WAFELLO COCO CREME 60X35G",
      "WAFELLO CREAMY VANILLA 20X10X20.5G PH",
      "VALMER CHOCOLATE 12X10X54G",
      "SUPERSTAR TRIPLE CHOCOLATE 12 X10 X 18G",
      "DANISA BUTTER COOKIES 12X454G",
      "WAFELLO BUTTER CARAMEL 60X53.5G",
      "WAFELLO COCO CREME 60X53.5G",
      "WAFELLO CHOCOLATE 48G X 60",
      "WAFELLO CHOCOLATE 21G X 10 X 20",
      "WAFELLO BUTTER CARAMEL 48G X 60",
      "WAFELLO BUTTER CARAMEL 20.5G X 10 X 20",
      "WAFELLO COCO CRÈME 48G X 60",
      "WAFELLO COCONUT CRÈME 20.5G X 10 X 20",
      "CAL CHEESE 60 X 48G",
      "CAL CHEESE 20 X 10 X 20G",
      "CAL CHEESE 20 X 20 X 8.5G",
      "CAL CHEESE CHOCO 60 X 48G",
      "CAL CHEESE CHOCO 20 X 10 X 20.5G",
      "VALMER SANDWICH CHOCOLATE 12X10X36G",
      "MALKIST CAPPUCCINO 30X10X18G PH",
      "FRES CHERRY JAR PROMO",
      "FRES BARLEY JAR PROMO",
      "FRES GRAPE JAR PROMO",
      "FRES MIX CANDY JAR PROMO",
      "CAL CHEESE 20G (9+1 PROMO)",
      "WAFELLO CHOCOLATE 21G (9+1 PROMO)",
      "WAFELLO COCO CREME 20.5G (9+1 PROMO)",
      "WAFELLO BUTTER CARAMEL 20.5G (9+1 PROMO)",
      "FRES MIXED CANDY JAR 12 X 600G",
      "WAFELLO CREAMY VANILLA 60X48G PH",
      "MALKIST SWEET GLAZED 12X10X28G PH",
      "MALKIST BARBECUE 12X10X28G PH"
    ],
    'V2': [
      "Kopiko Black 3 in One Hanger 24 x 10 x 30g",
      "KOPIKO BLACK 3-IN-1 BAG 8 X 30 X 30G",
      "Kopiko Black 3 in One Promo Twin 12 x 10 x 2 x 30g",
      "Kopiko Brown Coffee hg 27.5g 24x10x27.5g",
      "Kopiko Brown Coffee Pouch 24x10x27.5g",
      "Kopiko Brown Coffee Bag 8x30x27.5g",
      "Kopiko Brown Promo Twin 12 x 10 x 53g",
      "Kopiko Cappuccino Hanger 24 x 10 x 25g",
      "Kopiko Cappuccino Pouch 24x10x25g",
      "Kopiko Cappuccino Bag 8x30x25g",
      "Kopiko L.A. Coffee hanger 24x10x25g",
      "Kopiko LA Coffee Pouch 24x10x25g",
      "Kopiko Blanca hanger 24x10x30g",
      "KOPIKO BLANCA, POUCH 24 X 10 X 30G",
      "KOPIKO BLANCA, BAG 8 X 30 X 30G",
      "Kopiko Blanca Twinpack 12 X 10 X 2 X 29G",
      "Toracafe White and Creamy 12 X (10 X 2) X 26G",
      "Kopiko Creamy Caramelo 12 x (10 x 2) x 25g",
      "Kopiko Double Cups 24 x 10 x 36g",
      "ENERGEN CHOCOLATE HANGER 24 X 10 X 40G",
      "Energen Chocolate Pouch 24x10x40g",
      "Energen Chocolate Bag 8x30x40g",
      "ENERGEN VANILLA HANGER 24 X 10 X 40G",
      "Energen Vanilla Pouch 24x10x40g",
      "Energen Vanilla Bag 8x30x40g",
      "Energen Champion NBA Hanger 24 x 10 x 35g",
      "Energen Pandesal Mate 24 x 10 x 30g",
      "ENERGEN CHAMPION 12X10X2X35G PH",
      "Kopiko Cafe Mocha TP 12X10X(2X25.5G) PH",
      "Energen Champion NBA TP 15 x 8 x 2 x30g ph",
      "KOPIKO BLACK 3IN1 TWINPACK 12X10X2X28G",
      "KOPIKO BLACK 3IN1 HANGER 24X10X30G UNLI",
      "KOPIKO BLACK 3IN1 TP 12X10X2X28G UNLI",
      "KOPIKO BROWN HANGER 24X10X27.5G UNLI",
      "KOPIKO BROWN TP 12X10X2X26.5G UNLI",
      "CHAMPION HANGER 17+3",
      "Champion Twin Pack 13+3",
      "Kopiko Blanca TP Banded 6 x (18 + 2) x 2 x 29g",
      "KOPIKO BROWN COFFEE TWINPACK BUY 12 SAVE 13 PROMO",
      "KOPIKO BLACK TWIN BUY 10 SAVE 13",
      "KOPIKO BLANCA HANGER GSK 12 X 2 X 10 X 30G",
      "BLANCA TP 10+1",
      "Champion Hanger 20x(10+2) x 35g/30g",
      "ENERGEN CHAMPION 40X345G",
      "KOPIKO BLACK 3-IN-1 POUCH 24 X 10 X 30G"
    ],
    'V3': [
      "Le Minerale 24x330ml",
      "Le Minerale 24x600ml",
      "Le Minerale 12x1500ml",
      "LE MINERALE 4 X 5000ML",
      "KOPIKO LUCKY DAY 24BTL X 180ML",
      "KLD 5+1 Bundling"
    ],
  };

  Map<String, Map<String, String>> _skuToProductSkuCode = {
    //CATEGORY V1

    'KOPIKO COFFEE CANDY 24X175G': {'Product': ' ', 'SKU Code': '326924'},
    'KOPIKO COFFEE CANDY JAR 6X560G': {'Product': ' ', 'SKU Code': '329106'},
    'KOPIKO CAPPUCCINO CANDY 24X175G': {'Product': ' ', 'SKU Code': '326925'},
    'FRES BARLEY MINT 24X50X3G': {'Product': ' ', 'SKU Code': '326446'},
    'FRES MINT BARLEY JAR 12X200X3G': {'Product': ' ', 'SKU Code': '329136'},
    'FRES CHERRY CANDY, 24 X 50 X 3G': {'Product': ' ', 'SKU Code': '326447'},
    'FRES CHERRY JAR, 12X 200 X 3G': {'Product': ' ', 'SKU Code': '329135'},
    'FRES GRAPE CANDY, 24 X 50 X 3G': {'Product': ' ', 'SKU Code': '326448'},
    'FRES GRAPE JAR, 12 X 200 X 3G': {'Product': ' ', 'SKU Code': '329137'},
    'FRES APPLE PEACH 24 X 50 X 3G': {'Product': ' ', 'SKU Code': '329545'},
    'BENG BENG CHOCOLATE 12 X 10 X 26.5G': {
      'Product': ' ',
      'SKU Code': '329067'
    },
    'BENG BENG SHARE IT 16 X 95G': {'Product': ' ', 'SKU Code': '322583'},
    'CAL CHEESE 10X20X8.5G': {'Product': ' ', 'SKU Code': '330071'},
    'CAL CHEESE 60X35G': {'Product': ' ', 'SKU Code': '322571'},
    'CAL CHEESE 60X53.5G': {'Product': ' ', 'SKU Code': '329808'},
    'CAL CHEESE CHEESE CHOCO 60X53.5G': {'Product': ' ', 'SKU Code': '322866'},
    'CAL CHEESE CHEESE CHOCO 60X35G': {'Product': ' ', 'SKU Code': '322867'},
    'MALKIST CHOCOLATE 30X10X18G': {'Product': ' ', 'SKU Code': '321036'},
    'WAFELLO CHOCOLATE WAFER 60X53.5G': {'Product': ' ', 'SKU Code': '330016'},
    'WAFELLO CHOCOLATE WAFER 60X35G': {'Product': ' ', 'SKU Code': '330025'},
    'WAFELLO BUTTER CARAMEL 60X35G': {'Product': ' ', 'SKU Code': '322871'},
    'WAFELLO COCO CREME 60X35G': {'Product': ' ', 'SKU Code': '322868'},
    'WAFELLO CREAMY VANILLA 20X10X20.5G PH': {
      'Product': ' ',
      'SKU Code': '330073'
    },
    'VALMER CHOCOLATE 12X10X54G': {'Product': ' ', 'SKU Code': '321038'},
    'SUPERSTAR TRIPLE CHOCOLATE 12 X10 X 18G': {
      'Product': ' ',
      'SKU Code': '322894'
    },
    'DANISA BUTTER COOKIES 12X454G': {'Product': ' ', 'SKU Code': '329650'},
    'WAFELLO BUTTER CARAMEL 60X53.5G': {'Product': ' ', 'SKU Code': '322870'},
    'WAFELLO COCO CREME 60X53.5G': {'Product': ' ', 'SKU Code': '322869'},
    'WAFELLO CHOCOLATE 48G X 60': {'Product': ' ', 'SKU Code': '330050'},
    'WAFELLO CHOCOLATE 21G X 10 X 20': {'Product': ' ', 'SKU Code': '330051'},
    'WAFELLO BUTTER CARAMEL 48G X 60': {'Product': ' ', 'SKU Code': '330056'},
    'WAFELLO BUTTER CARAMEL 20.5G X 10 X 20': {
      'Product': ' ',
      'SKU Code': '330057'
    },
    'WAFELLO COCO CRÈME 48G X 60': {'Product': ' ', 'SKU Code': '330058'},
    'WAFELLO COCONUT CRÈME 20.5G X 10 X 20': {
      'Product': ' ',
      'SKU Code': '330059'
    },
    'CAL CHEESE 60 X 48G': {'Product': ' ', 'SKU Code': '330052'},
    'CAL CHEESE 20 X 10 X 20G': {'Product': ' ', 'SKU Code': '330053'},
    'CAL CHEESE 20 X 20 X 8.5G': {'Product': ' ', 'SKU Code': '330071'},
    'CAL CHEESE CHOCO 60 X 48G': {'Product': ' ', 'SKU Code': '330054'},
    'CAL CHEESE CHOCO 20 X 10 X 20.5G': {'Product': ' ', 'SKU Code': '330055'},
    'VALMER SANDWICH CHOCOLATE 12X10X36G': {
      'Product': ' ',
      'SKU Code': '321475'
    },
    'MALKIST CAPPUCCINO 30X10X18G PH': {'Product': ' ', 'SKU Code': '31446'},
    'FRES CHERRY JAR PROMO': {'Product': ' ', 'SKU Code': 'P-2023-07-329135'},
    'FRES BARLEY JAR PROMO': {'Product': ' ', 'SKU Code': 'P-2023-07-329106'},
    'FRES GRAPE JAR PROMO': {'Product': ' ', 'SKU Code': 'P-2023-07-329137'},
    'FRES MIX CANDY JAR PROMO': {
      'Product': ' ',
      'SKU Code': 'P-2023-07-320015'
    },
    'CAL CHEESE 20G (9+1 PROMO)': {
      'Product': ' ',
      'SKU Code': 'P-2022-12-322571'
    },
    'WAFELLO CHOCOLATE 21G (9+1 PROMO)': {
      'Product': ' ',
      'SKU Code': 'P-2022-12-330051'
    },
    'WAFELLO COCO CREME 20.5G (9+1 PROMO)': {
      'Product': ' ',
      'SKU Code': 'P-2022-12-330059'
    },
    'WAFELLO BUTTER CARAMEL 20.5G (9+1 PROMO)': {
      'Product': ' ',
      'SKU Code': 'P-2022-12-330057'
    },
    'FRES MIXED CANDY JAR 12 X 600G': {'Product': ' ', 'SKU Code': '320015'},
    'WAFELLO CREAMY VANILLA 60X48G PH': {'Product': ' ', 'SKU Code': '330060'},
    'MALKIST SWEET GLAZED 12X10X28G PH': {'Product': ' ', 'SKU Code': '420559'},
    'MALKIST BARBECUE 12X10X28G PH': {'Product': ' ', 'SKU Code': '420558'},

    //CATEGORY V2

    'Kopiko Black 3 in One Hanger 24 x 10 x 30g': {
      'Product': ' ',
      'SKU Code': '322628'
    },
    'KOPIKO BLACK 3-IN-1 BAG 8 X 30 X 30G': {
      'Product': ' ',
      'SKU Code': '322629'
    },
    'Kopiko Black 3 in One Promo Twin 12 x 10 x 2 x 30g': {
      'Product': ' ',
      'SKU Code': '322627'
    },
    'Kopiko Brown Coffee hg 27.5g 24x10x27.5g': {
      'Product': ' ',
      'SKU Code': '328890'
    },
    'Kopiko Brown Coffee Pouch 24x10x27.5g': {
      'Product': ' ',
      'SKU Code': '328883'
    },
    'Kopiko Brown Coffee Bag 8x30x27.5g': {
      'Product': ' ',
      'SKU Code': '328882'
    },
    'Kopiko Brown Promo Twin 12 x 10 x 53g': {
      'Product': ' ',
      'SKU Code': '329479'
    },
    'Kopiko Cappuccino Hanger 24 x 10 x 25g': {
      'Product': ' ',
      'SKU Code': '329701'
    },
    'Kopiko Cappuccino Pouch 24x10x25g': {'Product': ' ', 'SKU Code': '329703'},
    'Kopiko Cappuccino Bag 8x30x25g': {'Product': ' ', 'SKU Code': '329704'},
    'Kopiko L.A. Coffee hanger 24x10x25g': {
      'Product': ' ',
      'SKU Code': '325666'
    },
    'Kopiko LA Coffee Pouch 24x10x25g': {'Product': ' ', 'SKU Code': '325667'},
    'Kopiko Blanca hanger 24x10x30g': {'Product': ' ', 'SKU Code': '328888'},
    'KOPIKO BLANCA, POUCH 24 X 10 X 30G': {
      'Product': ' ',
      'SKU Code': '328887'
    },
    'KOPIKO BLANCA, BAG 8 X 30 X 30G': {'Product': ' ', 'SKU Code': '328889'},
    'Kopiko Blanca Twinpack 12 X 10 X 2 X 29G': {
      'Product': ' ',
      'SKU Code': '322711'
    },
    'Toracafe White and Creamy 12 X (10 X 2) X 26G': {
      'Product': ' ',
      'SKU Code': '322731'
    },
    'Kopiko Creamy Caramelo 12 x (10 x 2) x 25g': {
      'Product': ' ',
      'SKU Code': '322725'
    },
    'Kopiko Double Cups 24 x 10 x 36g': {'Product': ' ', 'SKU Code': '329744'},
    'ENERGEN CHOCOLATE HANGER 24 X 10 X 40G': {
      'Product': ' ',
      'SKU Code': '328497'
    },
    'Energen Chocolate Pouch 24x10x40g': {'Product': ' ', 'SKU Code': '328492'},
    'Energen Chocolate Bag 8x30x40g': {'Product': ' ', 'SKU Code': '328493'},
    'ENERGEN VANILLA HANGER 24 X 10 X 40G': {
      'Product': ' ',
      'SKU Code': '328494'
    },
    'Energen Vanilla Pouch 24x10x40g': {'Product': ' ', 'SKU Code': '328495'},
    'Energen Vanilla Bag 8x30x40g': {'Product': ' ', 'SKU Code': '328496'},
    'Energen Champion NBA Hanger 24 x 10 x 35g': {
      'Product': ' ',
      'SKU Code': '325945'
    },
    'Energen Pandesal Mate 24 x 10 x 30g': {
      'Product': ' ',
      'SKU Code': '325899'
    },
    'ENERGEN CHAMPION 12X10X2X35G PH': {'Product': ' ', 'SKU Code': '325934'},
    'Kopiko Cafe Mocha TP 12X10X(2X25.5G) PH': {
      'Product': ' ',
      'SKU Code': '324149'
    },
    'Energen Champion NBA TP 15 x 8 x 2 x30g ph': {
      'Product': ' ',
      'SKU Code': '325965'
    },
    'KOPIKO BLACK 3IN1 TWINPACK 12X10X2X28G': {
      'Product': ' ',
      'SKU Code': '420011'
    },
    'KOPIKO BLACK 3IN1 HANGER 24X10X30G UNLI': {
      'Product': ' ',
      'SKU Code': '420203'
    },
    'KOPIKO BLACK 3IN1 TP 12X10X2X28G UNLI': {
      'Product': ' ',
      'SKU Code': '420202'
    },
    'KOPIKO BROWN HANGER 24X10X27.5G UNLI': {
      'Product': ' ',
      'SKU Code': '420205'
    },
    'KOPIKO BROWN TP 12X10X2X26.5G UNLI': {
      'Product': ' ',
      'SKU Code': '420204'
    },
    'CHAMPION HANGER 17+3': {'Product': ' ', 'SKU Code': '900082'},
    'Champion Twin Pack 13+3': {'Product': ' ', 'SKU Code': '900083'},
    'Kopiko Blanca TP Banded 6 x (18 + 2) x 2 x 29g': {
      'Product': ' ',
      'SKU Code': '322789'
    },
    'KOPIKO BROWN COFFEE TWINPACK BUY 12 SAVE 13 PROMO': {
      'Product': ' ',
      'SKU Code': 'P-2022-09-329479'
    },
    'KOPIKO BLACK TWIN BUY 10 SAVE 13': {
      'Product': ' ',
      'SKU Code': 'P-2022-09-322627'
    },
    'KOPIKO BLANCA HANGER GSK 12 X 2 X 10 X 30G': {
      'Product': ' ',
      'SKU Code': 'P-2022-11-328888'
    },
    'BLANCA TP 10+1': {'Product': ' ', 'SKU Code': 'PROMO-2023-08-322711'},
    'Champion Hanger 20x(10+2) x 35g/30g': {
      'Product': ' ',
      'SKU Code': 'P-2023-09-900084'
    },
    'ENERGEN CHAMPION 40X345G': {'Product': ' ', 'SKU Code': '420373'},
    'KOPIKO BLACK 3-IN-1 POUCH 24 X 10 X 30G': {
      'Product': ' ',
      'SKU Code': '322630'
    },

    //CATEGORY V3

    'Le Minerale 24x330ml': {'Product': ' ', 'SKU Code': '328566'},
    'Le Minerale 24x600ml': {'Product': ' ', 'SKU Code': '328565'},
    'Le Minerale 12x1500ml': {'Product': ' ', 'SKU Code': '326770'},
    'LE MINERALE 4 X 5000ML': {'Product': ' ', 'SKU Code': '324045'},
    'KOPIKO LUCKY DAY 24BTL X 180ML': {'Product': ' ', 'SKU Code': '324046'},
    'KLD 5+1 Bundling': {'Product': ' ', 'SKU Code': 'P-2022-10-324046'}
  };

  // List<String> getSkuDescriptions(List<String> savedSkus) {
  //   List<String> matchedDescriptions = [];
  //   for (String sku in savedSkus) {
  //     _categoryToSkuDescriptions.forEach((category, SKUDescription) {
  //       if (SKUDescription.contains(sku)) {
  //         matchedDescriptions.add(sku);
  //       }
  //     });
  //   }
  //   return matchedDescriptions;
  // }

  // List<String> getFilteredSkuDescriptions(List<String> savedSkus) {
  //   List<String> matchedDescriptions = [];
  //   _categoryToSkuDescriptions.forEach((category, SKUDescription) {
  //     matchedDescriptions.addAll(SKUDescription.where(
  //         (SKUDescription) => savedSkus.contains(SKUDescription)));
  //   });
  //   return matchedDescriptions;
  // }

  // void loadSkuDescriptions(String branchName, String category) async {
  //   List<Map<String, dynamic>> skus =
  //       await MongoDatabase.getSkusByBranchAndCategory(branchName, category);

  //   print('SKUs by Branch and Category: $skus');

  //   if (skus.isNotEmpty) {
  //     List<String> savedSkus =
  //         skus.map((sku) => sku['SKUs'] as String).toList();
  //     print('Saved SKUs: $savedSkus');

  //     List<String> skuDescriptions = getSkuDescriptions(savedSkus);
  //     print('SKU Descriptions: $skuDescriptions');

  //     setState(() {
  //       _availableSkuDescriptions = skuDescriptions;
  //       _selectedDropdownValue =
  //           skuDescriptions.isNotEmpty ? skuDescriptions.first : null;
  //     });
  //   } else {
  //     setState(() {
  //       _availableSkuDescriptions = [];
  //       _selectedDropdownValue = null;
  //     });
  //     print('No SKUs found for this branch and category.');
  //   }
  // }

  void _toggleDropdown(String version) {
    setState(() {
      if (_versionSelected == version) {
        // If the same dropdown is clicked again, hide it
        _versionSelected = null;
        _isDropdownVisible = false; // Hide the dropdown
      } else {
        // Otherwise, show the clicked dropdown
        _versionSelected = version;
        _isDropdownVisible = true; // Show the dropdown
      }

      // Reset remarks, reason, and their dropdown visibility
      _remarksOOS = null; // Hide the Remarks dropdown
      _selectedNoDeliveryOption = null; // Reset No Delivery option
      _reasonOOS = null; // Reset Reason for OOS
      _showNoDeliveryDropdown = false; // Hide No Delivery reason dropdown

      // Reset No. of Days OOS
      _selectedNumberOfDaysOOS = 0; // Reset Number of Days OOS to 0

      // Reset other fields and visibility states
      _selectedDropdownValue = null;
      _productDetails = null; // Clear product details
      _skuCode = null; // Clear SKU code
      _expiryFields.clear(); // Clear expiry fields when switching categories

      // Hide buttons and text fields when a category is deselected
      _showCarriedTextField = false;
      _showNotCarriedTextField = false;
      _showDelistedTextField = false;

      // Reset text controllers (optional)
      _beginningController.clear();
      _deliveryController.clear();
      _endingController.clear();
      _offtakeController.clear();
    });
  }

  void _selectSKU(String? newValue) {
    if (newValue != null && _skuToProductSkuCode.containsKey(newValue)) {
      setState(() {
        _selectedDropdownValue = newValue;
        _productDetails = _skuToProductSkuCode[newValue]!['Product'];
        _skuCode = _skuToProductSkuCode[newValue]!['SKU Code'];
      });
    }
  }

  void _toggleCarriedTextField(String status) {
    setState(() {
      _statusSelected = status;
      _showCarriedTextField = true;
      _showNotCarriedTextField = false;
      _showDelistedTextField = false;
      _beginningController.clear();
      _deliveryController.clear();
      _endingController.clear();
      _offtakeController.clear();
      _expiryFields.clear(); // Clear expiry fields when switching categories
    });
  }

  void _toggleNotCarriedTextField(String status) {
    setState(() {
      _statusSelected = status;
      _showCarriedTextField = false;
      _showNotCarriedTextField = true;
      _showDelistedTextField = false;
      _showNoDeliveryDropdown = false;
      _showNoPOTextField = false;
      _showUnservedTextField = false;
      _beginningController.clear();
      _beginningSAController.clear();
      _beginningWAController.clear();
      _deliveryController.clear();
      _endingController.clear();
      _endingSAController.clear();
      _endingWAController.clear();
      _offtakeController.clear();
      _expiryFields.clear(); // Clear expiry fields when switching categories

      if (status == 'Not Carried' || status == 'Delisted') {
        _selectedNumberOfDaysOOS = 0;
      }
    });
  }

  void _toggleDelistedTextField(String status) {
    setState(() {
      _statusSelected = status;
      _showCarriedTextField = false;
      _showNotCarriedTextField = false;
      _showDelistedTextField = true;
      _showNoDeliveryDropdown = false;
      _showNoPOTextField = false;
      _showUnservedTextField = false;
      _beginningSAController.clear();
      _beginningWAController.clear();
      _beginningController.clear();
      _deliveryController.clear();
      _endingController.clear();
      _endingSAController.clear();
      _endingWAController.clear();
      _offtakeController.clear();
      _expiryFields.clear(); // Clear expiry fields when switching categories
      if (status == 'Not Carried' || status == 'Delisted') {
        _selectedNumberOfDaysOOS = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _inputid = generateInputID();
    // loadSkuDescriptions(selectedBranch);
    _beginningController.addListener(_calculateBeginning);

    _beginningController.addListener(_calculateOfftake);
    _deliveryController.addListener(_calculateOfftake);
    _endingController.addListener(_calculateOfftake);
    _offtakeController.addListener(_calculateInventoryDaysLevel);
    checkSaveEnabled();
  }

  @override
  void dispose() {
    _beginningController.dispose();
    _beginningController.dispose();
    _deliveryController.dispose();
    _endingController.dispose();
    _offtakeController.dispose();
    _inventoryDaysLevelController.dispose();
    _noPOController.dispose();
    _unservedController.dispose();
    _nodeliveryController.dispose();
    super.dispose();
  }

  void _calculateBeginning() {
    try {
      // Parse input values, default to 0 if empty
      int beginningSA = int.tryParse(_beginningSAController.text) ?? 0;
      int beginningWA = int.tryParse(_beginningWAController.text) ?? 0;

      // Calculate new beginning value
      int newBeginning = beginningSA + beginningWA;

      // Update the beginning controller with formatted integer value
      _beginningController.text = newBeginning.toString();
    } catch (e) {
      print('Error calculating beginning: $e');
      // Handle error appropriately (e.g., show an error message to the user)
    }
  }

  void _calculateEnding() {
    try {
      // Parse input values, default to 0 if empty
      int endingSA = int.tryParse(_endingSAController.text) ?? 0;
      int endingWA = int.tryParse(_endingWAController.text) ?? 0;

      // Calculate new beginning value
      int newEnding = endingSA + endingWA;

      // Update the beginning controller with formatted integer value
      _endingController.text = newEnding.toString();
    } catch (e) {
      print('Error calculating beginning: $e');
      // Handle error appropriately (e.g., show an error message to the user)
    }
  }

  void _calculateOfftake() {
    double beginning = double.tryParse(_beginningController.text) ?? 0;
    double delivery = double.tryParse(_deliveryController.text) ?? 0;
    double ending = double.tryParse(_endingController.text) ?? 0;
    double offtake = beginning + delivery - ending;
    _offtakeController.text = offtake.toStringAsFixed(2);
  }

  void _calculateInventoryDaysLevel() {
    double ending = double.tryParse(_endingController.text) ?? 0;
    double offtake = double.tryParse(_offtakeController.text) ?? 0;

    double inventoryDaysLevel = 0; // Default to 0

    if (offtake != 0 && ending != double.infinity && !ending.isNaN) {
      inventoryDaysLevel = ending / (offtake / 7);
    }

    if (inventoryDaysLevel.isNaN || inventoryDaysLevel.isInfinite) {
      inventoryDaysLevel = 0; // Assign 0 if the result is NaN or infinite
    }

    _inventoryDaysLevelController.text = inventoryDaysLevel == 0
        ? '' // Leave it empty if the value is 0
        : inventoryDaysLevel.toStringAsFixed(2);
  }

  void checkSaveEnabled() {
    setState(() {
      if (_statusSelected == 'Carried') {
        if (_selectedNumberOfDaysOOS == 0) {
          // Enable Save button when "0" is selected, but only if other fields are filled
          _isSaveEnabled = _endingController.text.isNotEmpty &&
              _deliveryController.text.isNotEmpty &&
              _beginningSAController.text.isNotEmpty &&
              _beginningWAController.text.isNotEmpty &&
              _endingSAController.text.isNotEmpty &&
              _endingWAController.text.isNotEmpty;
        } else {
          // Existing logic for when _selectedNumberOfDaysOOS is not 0
          _isSaveEnabled = _endingController.text.isNotEmpty &&
              _deliveryController.text.isNotEmpty &&
              _beginningSAController.text.isNotEmpty &&
              _beginningWAController.text.isNotEmpty &&
              _endingSAController.text.isNotEmpty &&
              _endingWAController.text.isNotEmpty;
          (_remarksOOS == "No P.O" ||
              _remarksOOS == "Unserved" ||
              (_remarksOOS == "No Delivery" &&
                  _selectedNoDeliveryOption != null));
        }
      } else {
        // Enable Save button for "Not Carried" and "Delisted" categories
        _isSaveEnabled = true;
      }
    });
  }

  void RemarkSaveEnable() {
    setState(() {
      // Enable the Save button only if a reason is selected when No Delivery dropdown is shown
      if (_showNoDeliveryDropdown) {
        _isSaveEnabled = _selectedNoDeliveryOption != null;
      } else {
        _isSaveEnabled = true; // or other conditions based on your app logic
      }
    });
  }

  bool isSaveEnabled = false;

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: new MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                  backgroundColor: Colors.green[600],
                  elevation: 0,
                  title: Text(
                    'Inventory Input',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddInventory(
                                  userName: widget.userName,
                                  userLastName: widget.userLastName,
                                  userEmail: widget.userEmail,
                                  userContactNum: widget.userContactNum,
                                  userMiddleName: widget.userMiddleName,
                                )),
                      );
                    },
                  )),
              body: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  // Wrap with SingleChildScrollView
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        'Input ID',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        initialValue: generateInputID(),
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          hintText: 'Auto-generated Input ID',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Week Number',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextField(
                        controller: _accountNameController,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          hintText: widget.selectedWeek,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Month',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextField(
                        controller: _accountNameController,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          hintText: widget.selectedMonth,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Branch/Outlet',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      TextField(
                        controller: _accountNameController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: widget.selectedAccount,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Category',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _versionSelected == 'V1' ||
                                      _versionSelected == null
                                  ? () => _toggleDropdown('V1')
                                  : null,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    width: 2.0,
                                    color: _versionSelected == 'V1'
                                        ? Colors.green
                                        : Colors.blueGrey.shade200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'V1',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                              width:
                                  8), // Add spacing between buttons if needed
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _versionSelected == 'V2' ||
                                      _versionSelected == null
                                  ? () => _toggleDropdown('V2')
                                  : null,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    width: 2.0,
                                    color: _versionSelected == 'V2'
                                        ? Colors.green
                                        : Colors.blueGrey.shade200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'V2',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                              width:
                                  8), // Add spacing between buttons if needed
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _versionSelected == 'V3' ||
                                      _versionSelected == null
                                  ? () => _toggleDropdown('V3')
                                  : null,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    width: 2.0,
                                    color: _versionSelected == 'V3'
                                        ? Colors.green
                                        : Colors.blueGrey.shade200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'V3',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Add text fields where user input is expected, and assign controllers
                      if (_isDropdownVisible && _versionSelected != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                'SKU Description',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16, // Adjust as needed
                                ),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              onChanged:
                                  _selectSKU, // Pass the method reference here
                              items:
                                  _categoryToSkuDescriptions[_versionSelected]!
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Container(
                                    width:
                                        315, // Set a max width for the dropdown items
                                    child: Text(
                                      value,
                                      overflow: TextOverflow
                                          .ellipsis, // Handle long text with ellipsis
                                      softWrap:
                                          false, // Prevent wrapping of long text
                                    ),
                                  ),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                labelText:
                                    'Select SKU Description', // Label for the dropdown
                                border:
                                    OutlineInputBorder(), // Apply border to the TextField
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                            if (_productDetails != null) ...[
                              SizedBox(height: 10),
                              Text(
                                'Products',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              TextField(
                                controller:
                                    _productsController, // Assigning controller
                                readOnly: true,
                                decoration: InputDecoration(
                                  border:
                                      OutlineInputBorder(), // Apply border to the TextField
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          12), // Padding inside the TextField
                                  hintText: _productDetails,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'SKU Code',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              TextField(
                                readOnly: true,
                                controller:
                                    _skuCodeController, // Assigning controller
                                decoration: InputDecoration(
                                  border:
                                      OutlineInputBorder(), // Apply border to the TextField
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal:
                                          12), // Padding inside the TextField
                                  hintText: _skuCode,
                                ),
                              ),
                            ],
                          ],
                        ),

                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (_productDetails != null)
                            SizedBox(
                              width: 115, // Same fixed width
                              child: OutlinedButton(
                                onPressed: () {
                                  _toggleCarriedTextField('Carried');
                                  checkSaveEnabled(); // Call checkSaveEnabled when category changes
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    width: 2.0,
                                    color: _statusSelected == 'Carried'
                                        ? Colors.green
                                        : Colors.blueGrey.shade200,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'Carried',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          if (_productDetails != null)
                            SizedBox(
                              width: 130, // Same fixed width
                              child: OutlinedButton(
                                onPressed: () {
                                  _toggleNotCarriedTextField('Not Carried');
                                  checkSaveEnabled(); // Call checkSaveEnabled when category changes
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    width: 2.0,
                                    color: _statusSelected == 'Not Carried'
                                        ? Colors.green
                                        : Colors.blueGrey.shade200,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'Not Carried',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          if (_productDetails != null)
                            SizedBox(
                              width: 115, // Same fixed width
                              child: OutlinedButton(
                                onPressed: () {
                                  _toggleDelistedTextField('Delisted');
                                  checkSaveEnabled(); // Call checkSaveEnabled when category changes
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    width: 2.0,
                                    color: _statusSelected == 'Delisted'
                                        ? Colors.green
                                        : Colors.blueGrey.shade200,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  'Delisted',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 15),
                      // Conditionally showing the 'Beginning' field with its label
                      if (_showCarriedTextField) ...[
                        Text(
                          'Beginning PCS (Selling Area)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _beginningSAController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onChanged: (_) {
                            _calculateBeginning(); // Calculate on change
                            checkSaveEnabled();
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                      SizedBox(height: 15),
                      // Conditionally showing the 'BeginningWA' field with its label
                      if (_showCarriedTextField) ...[
                        Text(
                          'Beginning PCS (Warehouse Area)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _beginningWAController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onChanged: (_) {
                            _calculateBeginning(); // Calculate on change
                            checkSaveEnabled();
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                      SizedBox(height: 15),
                      if (_showCarriedTextField) ...[
                        Text(
                          'Ending PCS (Selling Area)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _endingSAController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onChanged: (_) {
                            _calculateEnding(); // Calculate on change
                            checkSaveEnabled();
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                      SizedBox(height: 15),
                      // Conditionally showing the 'BeginningWA' field with its label
                      if (_showCarriedTextField) ...[
                        Text(
                          'Ending PCS (Warehouse Area)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _endingWAController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onChanged: (_) {
                            _calculateEnding(); // Calculate on change
                            checkSaveEnabled();
                          },
                        ),
                        SizedBox(height: 10),
                      ],
                      SizedBox(height: 15),
                      // Conditionally showing the 'Beginning' field with its label
                      if (_showCarriedTextField) ...[
                        Text(
                          'Beginning',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          readOnly: true,
                          controller: _beginningController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onChanged: (_) => checkSaveEnabled(),
                        ),
                        SizedBox(height: 10),
                      ],

// Conditionally showing the 'Delivery' field with its label
                      if (_showCarriedTextField) ...[
                        Text(
                          'Delivery PCS',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _deliveryController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onChanged: (_) => checkSaveEnabled(),
                        ),
                        SizedBox(height: 10),
                      ],
// Conditionally showing the 'Ending' field with its label
                      if (_showCarriedTextField) ...[
                        Text(
                          'Ending',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          readOnly: true,
                          controller: _endingController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onChanged: (_) => checkSaveEnabled(),
                        ),
                        SizedBox(height: 10),
                      ],
                      SizedBox(height: 20),
                      if (_showCarriedTextField) ...[
                        Center(
                          child: SizedBox(
                            width: 450, // Set the width of the button
                            child: OutlinedButton(
                              onPressed: _addExpiryField,
                              style: OutlinedButton.styleFrom(
                                side:
                                    BorderSide(width: 2.0, color: Colors.green),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
                                'Add Expiry',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        if (_expiryFields.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (int i = 0; i < _expiryFields.length; i++)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Align rows to center
                                  children: [
                                    Expanded(child: _expiryFields[i]),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        _removeExpiryField(i);
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                      ],

                      SizedBox(height: 16),
                      if (_showCarriedTextField) ...[
                        Text(
                          'Offtake',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _offtakeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
// Conditionally showing the 'Inventory Days Level' field with its label
                      if (_showCarriedTextField) ...[
                        Text(
                          'Inventory Days Level',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _inventoryDaysLevelController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],

                      SizedBox(height: 10),
// Conditionally display 'No. of Days OOS' and the DropdownButtonFormField
                      if (_showCarriedTextField) ...[
                        Text(
                          'No. of Days OOS',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          value: _selectedNumberOfDaysOOS,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedNumberOfDaysOOS = newValue;

                              // Reset the remarks and reason when OOS changes
                              _remarksOOS = null;
                              _selectedNoDeliveryOption = null;
                              _reasonOOS = null;

                              // Hide the No Delivery dropdown if OOS Days is 0
                              if (_selectedNumberOfDaysOOS == 0) {
                                _showNoDeliveryDropdown = false;
                              }

                              // Check if Save button should be enabled
                              checkSaveEnabled();
                            });
                          },
                          items: List.generate(8, (index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text(index.toString()),
                            );
                          }),
                        ),
                        SizedBox(height: 10),
                      ],
                      SizedBox(height: 10),
                      if (_selectedNumberOfDaysOOS != null &&
                          _selectedNumberOfDaysOOS! > 0) ...[
                        Text(
                          'Remarks',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          decoration: _statusSelected == 'Carried'
                              ? InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )
                              : null, // No border or padding when status is not 'Carried'
                          value: _remarksOOS, // Ensure the value is not null
                          onChanged: (newValue) {
                            setState(() {
                              _remarksOOS = newValue;

                              // Show or hide the Select Reason dropdown based on the Remarks selection
                              if (_remarksOOS == 'No Delivery' &&
                                  _selectedNumberOfDaysOOS! > 0) {
                                _showNoDeliveryDropdown = true;
                              } else {
                                _showNoDeliveryDropdown = false;
                                _selectedNoDeliveryOption = null;
                                _reasonOOS = null;
                              }

                              // Check if Save button should be enabled
                              checkSaveEnabled();
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'No P.O',
                              child: Text('No P.O'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'Unserved',
                              child: Text('Unserved'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'No Delivery',
                              child: Text('No Delivery'),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 10),
// Conditionally display the Reason dropdown if OOS days is greater than 0 and No Delivery is selected
                      if (_showNoDeliveryDropdown &&
                          _selectedNumberOfDaysOOS! > 0) ...[
                        Text(
                          'Reason',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          decoration: _statusSelected == 'Carried'
                              ? InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )
                              : null, // No border or padding when status is not 'Carried'
                          value: _selectedNoDeliveryOption,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedNoDeliveryOption = newValue;
                              _reasonOOS =
                                  newValue; // Set the ReasonOOS value based on selection
                              checkSaveEnabled(); // Check if Save button should be enabled
                            });
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: 'With S.O but without P.O',
                              child: Text('With S.O but without P.O'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'With P.O but without Delivery',
                              child: Text('With P.O but without Delivery'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'AR ISSUES',
                              child: Text('AR ISSUES'),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 20),
                      if (_showCarriedTextField ||
                          _showNotCarriedTextField ||
                          _showDelistedTextField)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _isSaveEnabled
                                  ? () async {
                                      // Show confirmation dialog with preview
                                      bool confirmed = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Save Confirmation'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                      'Preview Inventory Item:'),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Date: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text: DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(DateTime
                                                                  .now()),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Input ID: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text: _inputid),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Name: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${widget.userName} ${widget.userLastName}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Account Name Branch ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text: widget
                                                                .selectedAccount),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Period: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text: widget
                                                                .SelectedPeriod),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Month: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text: widget
                                                                .selectedMonth),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Week: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text: widget
                                                                .selectedWeek),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Category: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                _versionSelected),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'SKU Description: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                _selectedDropdownValue),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Products: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                _productDetails),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'SKU Code: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text: _skuCode),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Status: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                _statusSelected),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Beginning (Selling Area): ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${int.tryParse(_beginningSAController.text) ?? 0}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Beginning (Warehouse Area): ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${int.tryParse(_beginningWAController.text) ?? 0}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Ending (Selling Area): ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${int.tryParse(_endingSAController.text) ?? 0}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Ending (WAREHOUSE AREA): ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${int.tryParse(_endingWAController.text) ?? 0}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Beginning Value: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${int.tryParse(_beginningController.text) ?? 0}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Delivery Value: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${int.tryParse(_deliveryController.text) ?? 0}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Ending Value: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${int.tryParse(_endingController.text) ?? 0}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Offtake Value: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${double.tryParse(_offtakeController.text)?.toStringAsFixed(2) ?? '0.00'}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Inventory Days Level: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              '${double.tryParse(_inventoryDaysLevelController.text)?.toStringAsFixed(2) ?? '0.00'}',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'No of Days OOS: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                '$_selectedNumberOfDaysOOS'),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              'Expiry Fields: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                '$_expiryFieldsValues'),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Remarks OOS: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                '$_remarksOOS'),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: 'Reason OOS: ',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                '$_reasonOOS'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      false); // Close dialog without saving
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(
                                                      true); // Confirm saving
                                                },
                                                child: Text('Confirm'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      // Save the inventory item if confirmed
                                      if (confirmed ?? false) {
                                        _saveInventoryItem(); // Call your save function here
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Inventory item saved'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => AddInventory(
                                              userName: widget.userName,
                                              userLastName: widget.userLastName,
                                              userEmail: widget.userEmail,
                                              userContactNum:
                                                  widget.userContactNum,
                                              userMiddleName:
                                                  widget.userMiddleName,
                                            ),
                                          ),
                                        ); // Close the current screen after saving
                                      }
                                    }
                                  : null, // Disable button if !_isSaveEnabled
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(
                                  const EdgeInsets.symmetric(vertical: 15),
                                ),
                                minimumSize: MaterialStateProperty.all<Size>(
                                  const Size(150, 50),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        _isSaveEnabled
                                            ? Colors.green
                                            : Colors.grey),
                              ),
                              child: const Text(
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
            )));
  }

  Widget _buildDropdown(
    String title,
    ValueChanged<String?> onSelect,
    List<String> options,
    InputDecoration Decoration,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DropdownButton<String>(
          value: _selectedDropdownValue,
          isExpanded: true,
          onChanged: onSelect,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ExpiryField extends StatefulWidget {
  final int index;
  final Function(String, int, int) onExpiryFieldChanged;
  final VoidCallback onDeletePressed;
  final String? initialMonth; // Initial value for the dropdown
  final int? initialPcs; // Nullable initial value for the TextField

  ExpiryField({
    required this.index,
    required this.onExpiryFieldChanged,
    required this.onDeletePressed,
    this.initialMonth,
    this.initialPcs, // Make this nullable to allow an empty state
  });

  @override
  _ExpiryFieldState createState() => _ExpiryFieldState();
}

class _ExpiryFieldState extends State<ExpiryField> {
  String? _selectedMonth;
  final TextEditingController _expiryController = TextEditingController();
  bool _isMonthSelected = false; // New flag to track dropdown selection

  @override
  void initState() {
    super.initState();

    _selectedMonth = widget.initialMonth;
    if (widget.initialPcs != null) {
      _expiryController.text = widget.initialPcs.toString();
    }
    _expiryController.addListener(_onExpiryFieldChanged);
  }

  @override
  void dispose() {
    _expiryController.removeListener(_onExpiryFieldChanged);
    _expiryController.dispose();
    super.dispose();
  }

  void _onExpiryFieldChanged() {
    if (_isMonthSelected) {
      widget.onExpiryFieldChanged(
        _selectedMonth!,
        int.tryParse(_expiryController.text) ?? 0,
        widget.index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          'Month of Expiry',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedMonth,
          onChanged: (String? newValue) {
            setState(() {
              _selectedMonth = newValue;
              _isMonthSelected = newValue != null && newValue.isNotEmpty;
            });
            _onExpiryFieldChanged();
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          hint: Text('Select Month'),
          items: [
            DropdownMenuItem<String>(
              value: '1 Month',
              child: Text('1 month'),
            ),
            DropdownMenuItem<String>(
              value: '2 Months',
              child: Text('2 months'),
            ),
            DropdownMenuItem<String>(
              value: '3 Months',
              child: Text('3 months'),
            ),
            DropdownMenuItem<String>(
              value: '4 Months',
              child: Text('4 months'),
            ),
            DropdownMenuItem<String>(
              value: '5 Months',
              child: Text('5 months'),
            ),
            DropdownMenuItem<String>(
              value: '6 Months',
              child: Text('6 months'),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'PCS of Expiry',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _expiryController,
          enabled:
              _isMonthSelected, // Enable TextField only when a month is selected
          decoration: InputDecoration(
            hintText: 'Enter PCS of expiry',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _onExpiryFieldChanged();
          },
        ),
      ],
    );
  }
}
