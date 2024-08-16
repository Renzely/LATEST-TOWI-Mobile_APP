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
              'Inventory Input',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12),
                            hintText: 'Auto-generated Input ID',
                          ),
                        ),
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
                          'Account Name Branch Manning',
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
                                                    _selectedAccount != null &&
                                                        _selectedPeriod != null;
                                              });
                                            }
                                          : null, // Disable onChange when there is only one branch
                                      decoration: InputDecoration(
                                        hintText: 'Select',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
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
                            'PERIOD',
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
                                                _weekController.text = 'Week 1';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jan06-Jan12':
                                                _monthController.text =
                                                    'January';
                                                _weekController.text = 'Week 2';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jan13-Jan19':
                                                _monthController.text =
                                                    'January';
                                                _weekController.text = 'Week 3';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jan20-Jan26':
                                                _monthController.text =
                                                    'January';
                                                _weekController.text = 'Week 4';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jan27-Feb02':
                                                _monthController.text =
                                                    'February';
                                                _weekController.text = 'Week 5';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Feb03-Feb09':
                                                _monthController.text =
                                                    'February';
                                                _weekController.text = 'Week 6';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Feb10-Feb16':
                                                _monthController.text =
                                                    'February';
                                                _weekController.text = 'Week 7';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Feb17-Feb23':
                                                _monthController.text =
                                                    'February';
                                                _weekController.text = 'Week 8';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Feb24-Mar01':
                                                _monthController.text = 'March';
                                                _weekController.text = 'Week 9';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Mar02-Mar08':
                                                _monthController.text = 'March';
                                                _weekController.text =
                                                    'Week 10';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Mar09-Mar15':
                                                _monthController.text = 'March';
                                                _weekController.text =
                                                    'Week 11';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Mar16-Mar22':
                                                _monthController.text = 'March';
                                                _weekController.text =
                                                    'Week 12';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Mar23-Mar29':
                                                _monthController.text = 'March';
                                                _weekController.text =
                                                    'Week 13';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Mar30-Apr05':
                                                _monthController.text = 'April';
                                                _weekController.text =
                                                    'Week 14';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Apr06-Apr12':
                                                _monthController.text = 'April';
                                                _weekController.text =
                                                    'Week 15';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Apr13-Apr19':
                                                _monthController.text = 'April';
                                                _weekController.text =
                                                    'Week 16';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Apr20-Apr26':
                                                _monthController.text = 'April';
                                                _weekController.text =
                                                    'Week 17';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Apr27-May03':
                                                _monthController.text = 'May';
                                                _weekController.text =
                                                    'Week 18';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'May04-May10':
                                                _monthController.text = 'May';
                                                _weekController.text =
                                                    'Week 19';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'May11-May17':
                                                _monthController.text = 'May';
                                                _weekController.text =
                                                    'Week 20';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'May18-May24':
                                                _monthController.text = 'May';
                                                _weekController.text =
                                                    'Week 21';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'May25-May31':
                                                _monthController.text = 'May';
                                                _weekController.text =
                                                    'Week 22';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jun01-Jun07':
                                                _monthController.text = 'June';
                                                _weekController.text =
                                                    'Week 23';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jun08-Jun14':
                                                _monthController.text = 'June';
                                                _weekController.text =
                                                    'Week 24';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jun15-Jun21':
                                                _monthController.text = 'June';
                                                _weekController.text =
                                                    'Week 25';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jun22-Jun28':
                                                _monthController.text = 'June';
                                                _weekController.text =
                                                    'Week 26';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jun29-Jul05':
                                                _monthController.text = 'July';
                                                _weekController.text =
                                                    'Week 27';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jul06-Jul12':
                                                _monthController.text = 'July';
                                                _weekController.text =
                                                    'Week 28';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jul13-Jul19':
                                                _monthController.text = 'July';
                                                _weekController.text =
                                                    'Week 29';
                                                _showAdditionalInfo = true;
                                                break;
                                              case 'Jul20-Jul26':
                                                _monthController.text = 'July';
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
                                          contentPadding: EdgeInsets.symmetric(
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
                                  fontWeight: FontWeight.bold, fontSize: 16),
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
                                    const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  minimumSize: MaterialStateProperty.all<Size>(
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
                                                    userName: widget.userName,
                                                    userLastName:
                                                        widget.userLastName,
                                                    userEmail: widget.userEmail,
                                                    userContactNum:
                                                        widget.userContactNum,
                                                    userMiddleName:
                                                        widget.userMiddleName,
                                                    selectedAccount:
                                                        _selectedAccount ?? '',
                                                    SelectedPeriod:
                                                        _selectedPeriod!,
                                                    selectedWeek: _selectedWeek,
                                                    selectedMonth:
                                                        _selectedMonth,
                                                    inputid: generateInputID(),
                                                  )));
                                    }
                                  : null,
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(
                                  const EdgeInsets.symmetric(vertical: 15),
                                ),
                                minimumSize: MaterialStateProperty.all<Size>(
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
        ));
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
  final String inputid;
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
    required this.inputid,
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
  int? _selectedNumberOfDaysOOS;
  bool _showCarriedTextField = false;
  bool _showNotCarriedTextField = false;
  bool _showDelistedTextField = false;
  bool _isSaveEnabled = false;
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

  void _saveInventoryItem() {
    String AccountManning = _selectedaccountname ?? '';
    String period = _selectedPeriod ?? '';
    String Version = _versionSelected ?? '';
    String status = _statusSelected ?? '';
    String SKUDescription = _selectedDropdownValue ?? '';
    String product = _productDetails ?? '';
    String skucode = _skuCode ?? '';
    String remarksOOS = _remarksOOS ?? '';
    String reasonOOS = _reasonOOS ?? '';
    int numberOfDaysOOS = _selectedNumberOfDaysOOS ?? 0;

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
    dynamic deliveryValue = delivery;
    dynamic endingValue = ending;
    dynamic offtakeValue = offtake;
    dynamic noOfDaysOOSValue = numberOfDaysOOS;

    if (status == 'Delisted') {
      beginningValue = delistedValue;
      deliveryValue = delistedValue;
      endingValue = delistedValue;
      offtakeValue = delistedValue;
      noOfDaysOOSValue = delistedValue;
      _expiryFieldsValues = [
        {'expiryMonth': delistedValue, 'expiryPcs': delistedValue}
      ];
    } else if (status == 'Not Carried') {
      beginningValue = ncValue;
      deliveryValue = ncValue;
      endingValue = ncValue;
      offtakeValue = ncValue;
      noOfDaysOOSValue = ncValue;
      _expiryFieldsValues = [
        {'expiryMonth': ncValue, 'expiryPcs': ncValue}
      ];
    }

    // Create a new InventoryItem from form inputs
    InventoryItem newItem = InventoryItem(
        id:
            ObjectId(), // You might want to generate this based on your DB setup
        userEmail: widget.userEmail,
        date: DateFormat('yyyy-MM-dd')
            .format(DateTime.now()), // Assuming current date for simplicity
        inputId: widget.inputid,
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
        delivery: deliveryValue,
        ending: endingValue,
        offtake: offtakeValue,
        inventoryDaysLevel: inventoryDaysLevel.toDouble(),
        noOfDaysOOS: noOfDaysOOSValue,
        expiryFields: _expiryFieldsValues,
        remarksOOS: remarksOOS,
        reasonOOS: reasonOOS);

    // Save the new inventory item to the database
    _saveToDatabase(newItem);
  }

  Future<void> _saveToDatabase(InventoryItem item) async {
    try {
      // Connect to your MongoDB database
      final db = await mongo.Db.create(INVENTORY_CONN_URL);
      await db.open();

      // Get a reference to the collection where you want to save items
      final collection = db.collection(USER_INVENTORY);

      // Convert the InventoryItem to a Map using the toJson() method
      final Map<String, dynamic> itemMap = item.toJson();

      // Insert the item into the collection
      await collection.insert(itemMap);

      // Close the database connection when done
      await db.close();

      print('Inventory item saved to database');
    } catch (e) {
      // Handle any errors that occur during saving
      print('Error saving inventory item: $e');
    }

    Future<List<InventoryItem>> getUserInventoryItems(String userEmail) async {
      List<InventoryItem> items = [];
      try {
        final db = await mongo.Db.create(INVENTORY_CONN_URL);
        await db.open();
        final collection = db.collection(USER_INVENTORY);

        // Query only items that match the userEmail
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
      'WAFELLO BUTTER CARAMEL 60X53.5G',
      'WAFELLO COCO CREME 60X53.5G',
      'WAFELLO CREAMY VANILLA 60X48G PH',
      'WAFELLO CHOCOLATE 48G X 60',
      'WAFELLO CHOCOLATE 21G X 10 X 20',
      'WAFELLO BUTTER CARAMEL 48G X 60',
      'WAFELLO BUTTER CARAMEL 20.5G X 10 X 20',
      'WAFELLO COCO CRÈME 48G X 60',
      'WAFELLO COCONUT CRÈME 20.5G X 10 X 20',
      'CAL CHEESE 60 X 48G',
      'CAL CHEESE 20 X 10 X 20G',
      'CAL CHEESE 20 X 20 X 8.5G',
      'CAL CHEESE CHOCO 60 X 48G',
      'CAL CHEESE CHOCO 20 X 10 X 20.5G',
      'VALMER SANDWICH CHOCOLATE 12X10X36G',
      'MALKIST CAPPUCCINO 30X10X23G PH',
    ],
    'V2': [
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
      'ENERGEN CHAMPION 12 X 10 X 2 X 35G PH'
          'KOPIKO CAFE MOCHA TP 12 X 10 X (2 X 25.5G) PH'
          'ENERGEN CHAMPION NBA TP 15 X 8 X 2 X 30G PH',
      'BLACK 420011 KOPIKO BLACK 3IN1 TWINPACK 12 X 10 X 2 X 28G',
    ],
    'V3': [
      'LE MINERALE 24x330ML',
      'LE MINERALE 24x600ML',
      'LE MINERALE 12x1500ML',
      'LE MINERALE 4 X 5000ML',
      'KOPIKO LUCKY DAY 24BTL X 180ML'
    ],
  };

  Map<String, Map<String, String>> _skuToProductSkuCode = {
    //CATEGORY V1

    'KOPIKO COFFEE CANDY 24X175G': {
      'Product': 'COFFEE SHOT',
      'SKU Code': '326924'
    },
    'KOPIKO COFFEE CANDY JAR 6X560G': {
      'Product': 'COFFEE SHOT',
      'SKU Code': '326926'
    },
    'KOPIKO CAPPUCCINO CANDY 24X175G': {
      'Product': 'COFFEE SHOT',
      'SKU Code': '326925'
    },
    'FRES BARLEY MINT 24X50X3G': {'Product': 'FRES', 'SKU Code': '326446'},
    'FRES MINT BARLEY JAR 12X2003G': {'Product': 'FRES', 'SKU Code': '329136'},
    'FRES MINT BARLEY CANDY BIGPACK 6X1350G': {
      'Product': 'FRES',
      'SKU Code': ''
    },
    'FRES CHERRY CANDY, 24 X 50 X 3G': {
      'Product': 'FRES',
      'SKU Code': '326447'
    },
    'FRES CHERRY JAR, 12X 200 X 3G': {'Product': 'FRES', 'SKU Code': '329135'},
    'FRES MINT CHERRY CANDY BIGPACK 6X1350G': {
      'Product': 'FRES',
      'SKU Code': ''
    },

    //LATEST

    'FRES CANDY CANDY BIGPACK 24 X 50 X 3G': {
      'Product': 'FRES',
      'SKU Code': '326448'
    },
    'FRES GRAPE JAR, 12 X 200 X 3G': {'Product': 'FRES', 'SKU Code': '329137'},
    'FRES APPLE PEACH 24 X 50 X 3G': {'Product': 'FRES', 'SKU Code': '329545'},
    'FRES APPLEPEACH CANDY BIGPACK 6X1350G': {
      'Product': 'FRES',
      'SKU Code': ''
    },
    'FRES MIXED CANDY JAR 12 X 600G': {'Product': 'FRES', 'SKU Code': '320015'},
    'BENG BENG CHOCOLATE 12 X 10 X 26.5G': {
      'Product': 'BENG BENG',
      'SKU Code': '329067'
    },
    'BENG BENG SHARE IT 16 X 95G': {
      'Product': 'BENG BENG',
      'SKU Code': '322583'
    },
    'CAL CHEESE 10X20X8.5G': {'Product': 'CAL CHEESE', 'SKU Code': '329809'},
    'CAL CHEESE 60X35G': {'Product': 'CAL CHEESE', 'SKU Code': '322571'},
    'CAL CHEESE 60X53.5G': {'Product': 'CAL CHEESE', 'SKU Code': '329808'},
    'CAL CHEESE CHEESE CHOCO 60X53.5G': {
      'Product': 'CAL CHEESE',
      'SKU Code': '322866'
    },
    'CAL CHEESE CHEESE CHOCO 60X35G': {
      'Product': 'CAL CHEESE',
      'SKU Code': '322867'
    },
    'MALKIST CHOCOLATE 30X10X24G': {'Product': 'MALKIST', 'SKU Code': '321036'},
    'ROMA CREAM CRACKERS': {'Product': 'ROMA', 'SKU Code': ''},
    'WAFELLO CHOCOLATE WAFER 60X53.5G': {
      'Product': 'WAFELLO',
      'SKU Code': '330016'
    },
    'WAFELLO CHOCOLATE WAFER 60X35G': {
      'Product': 'WAFELLO',
      'SKU Code': '330025'
    },
    'WAFELLO BUTTER CARAMEL 60X35G': {
      'Product': 'WAFELLO',
      'SKU Code': '322871'
    },
    'WAFELLO COCO CREME 60X35G': {'Product': 'WAFELLO', 'SKU Code': '322868'},
    'WAFELLO CREAMY VANILLA 20X10X20.5G PH': {
      'Product': 'WAFELLO',
      'SKU Code': '330073'
    },
    'VALMER CHOCOLATE 12X10X54G': {'Product': 'VALMER', 'SKU Code': '321038'},
    'SUPERSTAR TRIPLE CHOCOLATE 12 X10 X 18G': {
      'Product': 'SUPERSTAR',
      'SKU Code': '322894'
    },
    'DANISA BUTTER COOKIES 12X454G': {
      'Product': 'DANISA',
      'SKU Code': '329650'
    },
    'WAFELLO BUTTER CARAMEL 60X53.5G': {
      'Product': 'WAFELLO',
      'SKU Code': '322870'
    },
    'WAFELLO COCO CREME 60X53.5G': {'Product': 'WAFELLO', 'SKU Code': '322869'},
    'WAFELLO CREAMY VANILLA 60X48G PH': {
      'Product': 'WAFELLO',
      'SKU Code': '330060'
    },
    'WAFELLO CHOCOLATE 48G X 60': {'Product': 'WAFELLO', 'SKU Code': '330050'},
    'WAFELLO CHOCOLATE 21G X 10 X 20': {
      'Product': 'WAFELLO',
      'SKU Code': '330051'
    },
    'WAFELLO BUTTER CARAMEL 48G X 60': {
      'Product': 'WAFELLO',
      'SKU Code': '330056'
    },
    'WAFELLO BUTTER CARAMEL 20.5G X 10 X 20': {
      'Product': 'WAFELLO',
      'SKU Code': '330057'
    },
    'WAFELLO COCO CRÈME 48G X 60': {'Product': 'WAFELLO', 'SKU Code': '330058'},

    'WAFELLO COCONUT CRÈME 20.5G X 10 X 20': {
      'Product': 'WAFELLO',
      'SKU Code': '330059'
    },
    'CAL CHEESE 60 X 48G': {'Product': 'CAL CHEESE', 'SKU Code': '330052'},

    'CAL CHEESE 20 X 10 X 20G': {'Product': 'CAL CHEESE', 'SKU Code': '330053'},

    'CAL CHEESE 20 X 20 X 8.5G': {
      'Product': 'CAL CHEESE',
      'SKU Code': '330071'
    },
    'CAL CHEESE CHOCO 60 X 48G': {
      'Product': 'CAL CHEESE',
      'SKU Code': '330054'
    },
    'CAL CHEESE CHOCO 20 X 10 X 20.5G': {
      'Product': 'CAL CHEESE',
      'SKU Code': '330055'
    },
    'VALMER SANDWICH CHOCOLATE 12X10X36G': {
      'Product': 'VALMER',
      'SKU Code': '321475'
    },
    'MALKIST CAPPUCCINO 30X10X23G PH': {
      'Product': 'MALKIST',
      'SKU Code': '321446'
    },

    //CATEGORY V2

    'KOPIKO BLACK 3 IN ONE HANGER 24 X 10 X 30G': {
      'Product': 'BLACK',
      'SKU Code': '322628'
    },
    'KOPIKO BLACK 3 IN ONE POUCH 24 X 10 X 30G': {
      'Product': 'BLACK',
      'SKU Code': '322630'
    },
    'KOPIKO BLACK 3 IN ONE BAG 8 X 30 X 30G': {
      'Product': 'BLACK',
      'SKU Code': '322629'
    },
    'KOPIKO BLACK 3 IN ONE PROMO TWIN 12 X 10 X 2 X 30G': {
      'Product': 'BLACK',
      'SKU Code': '322627'
    },

    'KOPIKO BROWN COFFEE HG 27.5G 24 X 10 X 27.5G': {
      'Product': 'BROWN',
      'SKU Code': '328890'
    },
    'KOPIKO BROWN COFFEE POUCH 24 X 10 X 27.GG': {
      'Product': 'BROWN',
      'SKU Code': '329958'
    },
    'KOPIKO BROWN COFFEE BAG 8 X 30 X 27.5G': {
      'Product': 'BROWN',
      'SKU Code': '329959'
    },
    'KOPIKO BROWN PROMO TWIN 12 X 10 X 53G': {
      'Product': 'BROWN',
      'SKU Code': '329940'
    },

    'KOPIKO CAPPUCCINO HANGER 24 X 10 X 25G': {
      'Product': 'CAPPUCCINO',
      'SKU Code': '329701'
    },
    'KOPIKO CAPPUCCINO POUCH 24 X 10 X 25G': {
      'Product': 'CAPPUCCINO',
      'SKU Code': '329703'
    },
    'KOPIKO CAPPUCCINO BAG 8 X 30 X 25G': {
      'Product': 'CAPPUCCINO',
      'SKU Code': '329704'
    },

    'KOPIKO L.A. COFFEE HANGER 24 X 10 X 25G': {
      'Product': 'L.A.',
      'SKU Code': '325666'
    },
    'KOPIKO L.A. COFFEE POUCH 24 X 10 X 25G': {
      'Product': 'L.A.',
      'SKU Code': '325667'
    },

    'KOPIKO BLANCA HANGER 24 X 10 X 30G': {
      'Product': 'BLANCA',
      'SKU Code': '328888'
    },
    'KOPIKO BLANCA POUCH 24 X 10 X 30G': {
      'Product': 'BLANCA',
      'SKU Code': '328887'
    },
    'KOPIKO BLANCA BAG 8 X 30 X 30G': {
      'Product': 'BLANCA',
      'SKU Code': '328889'
    },
    'KOPIKO BLANCA TWINPACK 12 X 10 X 2 X 29G': {
      'Product': 'BLANCA',
      'SKU Code': '322711'
    },
    'TORACAFE WHITE AND CREAMY 12 X (10 X 2) X 26G': {
      'Product': 'TORA',
      'SKU Code': '322731'
    },
    'KOPIKO CREAMY CARAMELO 12 X (10 X 2) X 25G': {
      'Product': 'CARAMELO',
      'SKU Code': '322725'
    },
    'KOPIKO DOUBLE CUPS 24 X 10 X 36G': {
      'Product': 'DOUBLE CUPS',
      'SKU Code': '329744'
    },
    'ENERGEN CHOCOLATE HANGER 24 X 10 X 40G': {
      'Product': 'ENERGEN',
      'SKU Code': '328497'
    },
    'ENERGEN CHOCOLATE POUCH 24 X 10 X 40G': {
      'Product': 'ENERGEN',
      'SKU Code': '328492'
    },
    'ENERGEN CHOCOLATE BAG 8 X 30 X 40G': {
      'Product': 'ENERGEN',
      'SKU Code': '328493'
    },
    'ENERGEN CHOCOLATE VANILLA HANGER 24 X 10 X 40G': {
      'Product': 'ENERGEN',
      'SKU Code': '328494'
    },
    'ENERGEN CHOCOLATE VANILLA POUCH 24 X 10 X 40G': {
      'Product': 'ENERGEN',
      'SKU Code': '328495'
    },
    'ENERGEN CHOCOLATE VANILLA BAG 8 X 30 X 40G': {
      'Product': 'ENERGEN',
      'SKU Code': '328496'
    },
    'ENERGEN CHAMPION NBA HANGER 24 X 10 X 35G': {
      'Product': 'CHAMPION',
      'SKU Code': '325945'
    },
    'ENERGEN PADESAL MATE 24 X 10 X 30G': {
      'Product': 'EPM',
      'SKU Code': '325920'
    },
    'ENERGEN CHAMPION 12 X 10 X 2 X 35G PH': {
      'Product': 'CHAMPION',
      'SKU Code': '325944'
    },
    'KOPIKO CAFE MOCHA TP 12 X 10 X (2 X 25.5G) PH': {
      'Product': 'CAFÉ MOCHA',
      'SKU Code': '324149'
    },
    'ENERGEN CHAMPION NBA TP 15 X 8 X 2 X 30G PH': {
      'Product': 'CHAMPION',
      'SKU Code': '325965'
    },
    'BLACK 420011 KOPIKO BLACK 3IN1 TWINPACK 12 X 10 X 2 X 28G': {
      'Product': 'BLACK',
      'SKU Code': '420011'
    },

    //CATEGORY V3

    'LE MINERALE 24x330ML': {'Product': 'WATER', 'SKU Code': '328566'},
    'LE MINERALE 24x600ML': {'Product': 'WATER', 'SKU Code': '328565'},
    'LE MINERALE 12x1500ML': {'Product': 'WATER', 'SKU Code': '326770'},
    'LE MINERALE 4 X 5000ML': {'Product': 'WATER', 'SKU Code': '324045'},
    'KOPIKO LUCKY DAY 24BTL X 180ML': {'Product': 'KLD', 'SKU Code': '324046'},
  };

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
      _selectedDropdownValue = null;
      _productDetails = null;
      _skuCode = null;
      // Hide buttons when a category is deselected
      _showCarriedTextField = false;
      _showNotCarriedTextField = false;
      _showDelistedTextField = false;
    });
  }

  void _selectSKU(String? newValue) {
    setState(() {
      _selectedDropdownValue = newValue;
      _productDetails = _skuToProductSkuCode[newValue!]!['Product'];
      _skuCode = _skuToProductSkuCode[newValue]!['SKU Code'];
    });
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
      _deliveryController.clear();
      _endingController.clear();
      _offtakeController.clear();

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
      _beginningController.clear();
      _deliveryController.clear();
      _endingController.clear();
      _offtakeController.clear();
      if (status == 'Not Carried' || status == 'Delisted') {
        _selectedNumberOfDaysOOS = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _beginningController.addListener(_calculateOfftake);
    _deliveryController.addListener(_calculateOfftake);
    _endingController.addListener(_calculateOfftake);
    _offtakeController.addListener(_calculateInventoryDaysLevel);
    checkSaveEnabled();
  }

  @override
  void dispose() {
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
    double inventoryDaysLevel = ending / (offtake / 7);
    _inventoryDaysLevelController.text = inventoryDaysLevel.toStringAsFixed(2);
  }

  void checkSaveEnabled() {
    setState(() {
      if (_statusSelected == 'Carried') {
        if (_selectedNumberOfDaysOOS == 0) {
          // Enable Save button when "0" is selected
          _isSaveEnabled = true;
        } else {
          // Enable Save button only if the relevant fields are filled or criteria are met
          _isSaveEnabled = _beginningController.text.isNotEmpty &&
              _deliveryController.text.isNotEmpty &&
              _endingController.text.isNotEmpty &&
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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.green[600],
              elevation: 0,
              title: Text(
                'Inventory Input',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
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
                  Text(
                    'Week Number',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  Text(
                    'Month',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    'Account Branch Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => _toggleDropdown('V1'),
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
                      OutlinedButton(
                        onPressed: () => _toggleDropdown('V2'),
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
                      OutlinedButton(
                        onPressed: () => _toggleDropdown('V3'),
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
                    ],
                  ),
                  // Add text fields where user input is expected, and assign controllers
                  if (_isDropdownVisible && _versionSelected != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            'SKU Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Adjust as needed
                            ),
                          ),
                        ),
                        _buildDropdown(
                          '',
                          _selectSKU,
                          _categoryToSkuDescriptions[_versionSelected]!,
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
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
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
                              hintText: _skuCode,
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
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
                        OutlinedButton(
                          onPressed: () {
                            _toggleCarriedTextField('Carried');
                            checkSaveEnabled(); // Call checkSaveEnabled when category changes
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                width: 2.0,
                                color: _statusSelected == 'Carried'
                                    ? Colors.green
                                    : Colors.blueGrey.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'Carried',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      if (_productDetails != null)
                        OutlinedButton(
                          onPressed: () {
                            _toggleNotCarriedTextField('Not Carried');
                            checkSaveEnabled(); // Call checkSaveEnabled when category changes
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                width: 2.0,
                                color: _statusSelected == 'Not Carried'
                                    ? Colors.green
                                    : Colors.blueGrey.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'Not Carried',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      if (_productDetails != null)
                        OutlinedButton(
                          onPressed: () {
                            _toggleDelistedTextField('Delisted');
                            checkSaveEnabled(); // Call checkSaveEnabled when category changes
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                width: 2.0,
                                color: _statusSelected == 'Delisted'
                                    ? Colors.green
                                    : Colors.blueGrey.shade200),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'Delisted',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                  if (_showCarriedTextField)
                    Text(
                      'Beginning',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _beginningController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onChanged: (_) =>
                        checkSaveEnabled(), // Call checkSaveEnabled on change
                  ),
                  SizedBox(height: 10),
                  if (_showCarriedTextField)
                    Text(
                      'Delivery',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _deliveryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onChanged: (_) =>
                        checkSaveEnabled(), // Call checkSaveEnabled on change
                  ),
                  SizedBox(height: 10),
                  if (_showCarriedTextField)
                    Text(
                      'Ending',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _endingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onChanged: (_) =>
                        checkSaveEnabled(), // Call checkSaveEnabled on change
                  ),
                  SizedBox(height: 10),
                  if (_showCarriedTextField)
                    Center(
                      child: OutlinedButton(
                        onPressed: _addExpiryField,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 2.0, color: Colors.green),
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
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  _removeExpiryField(i);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  if (_showCarriedTextField)
                    Text(
                      'Offtake',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _offtakeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_showCarriedTextField)
                    Text(
                      'Inventory Days Level',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _inventoryDaysLevelController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_showCarriedTextField)
                    Text(
                      'No. of Days OOS',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
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
                  if (_selectedNumberOfDaysOOS != null &&
                      _selectedNumberOfDaysOOS! > 0) ...[
                    Text(
                      'Inventory Days Level',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      value: _remarksOOS,
                      onChanged: (newValue) {
                        setState(() {
                          _remarksOOS = newValue;

                          // Show or hide the Select Reason dropdown based on the Remarks selection
                          if (_remarksOOS == 'No Delivery') {
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
                  if (_showNoDeliveryDropdown) ...[
                    Text(
                      'Reason',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
                                  bool confirmed = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Save Confirmation'),
                                        content: Text(
                                            'Do you want to save this inventory item?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text('Confirm'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmed ?? false) {
                                    _saveInventoryItem();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Inventory item saved'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                }
                              : null, // Disable button if !_isSaveEnabled
                          style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                              const EdgeInsets.symmetric(vertical: 15),
                            ),
                            minimumSize: MaterialStateProperty.all<Size>(
                              const Size(150, 50),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                _isSaveEnabled ? Colors.green : Colors.grey),
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
        ));
  }

  Widget _buildDropdown(
    String title,
    ValueChanged<String?> onSelect,
    List<String> options,
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

  ExpiryField({
    required this.index,
    required this.onExpiryFieldChanged,
    required this.onDeletePressed,
  });

  @override
  _ExpiryFieldState createState() => _ExpiryFieldState();
}

class _ExpiryFieldState extends State<ExpiryField> {
  String? _selectedMonth;
  final TextEditingController _expiryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _expiryController.addListener(_onExpiryFieldChanged);
  }

  @override
  void dispose() {
    _expiryController.removeListener(_onExpiryFieldChanged);
    _expiryController.dispose();
    super.dispose();
  }

  void _onExpiryFieldChanged() {
    if (_selectedMonth != null) {
      widget.onExpiryFieldChanged(_selectedMonth!,
          int.tryParse(_expiryController.text) ?? 0, widget.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Month of Expiry',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        SizedBox(height: 10),
        DropdownButton<String>(
          value: _selectedMonth,
          onChanged: (String? newValue) {
            setState(() {
              _selectedMonth = newValue;
            });
            _onExpiryFieldChanged();
          },
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
              value: '3 months',
              child: Text('3 months'),
            ),
            DropdownMenuItem<String>(
              value: '4 months',
              child: Text('4 months'),
            ),
            DropdownMenuItem<String>(
              value: '5 months',
              child: Text('5 months'),
            ),
            DropdownMenuItem<String>(
              value: '6 months',
              child: Text('6 months'),
            ),
          ],
        ),
        Text(
          'PCS of Expiry',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        TextField(
          controller: _expiryController,
          decoration: InputDecoration(
            hintText: 'Enter PCS of expiry ',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
