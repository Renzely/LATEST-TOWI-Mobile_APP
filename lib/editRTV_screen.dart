// ignore_for_file: prefer_final_fields

import 'package:demo_app/dbHelper/mongodb.dart';
import 'package:demo_app/dbHelper/mongodbDraft.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditRTVScreen extends StatefulWidget {
  final ReturnToVendor item;

  EditRTVScreen({required this.item});

  @override
  _EditRTVScreenState createState() => _EditRTVScreenState();
}

class _EditRTVScreenState extends State<EditRTVScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _inputId;
  late TextEditingController _merchandiserNameController;
  late TextEditingController _outletController;
  late TextEditingController _categoryController;
  late TextEditingController _itemController;
  late TextEditingController _quantityController;
  late TextEditingController _driverNameController;
  late TextEditingController _plateNumberController;
  late TextEditingController _pullOutReasonController;

  String selectedCategory = '';
  List<String> itemOptions = [];
  String selectedItem = '';
  bool isSaveButtonEnabled = false;

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
      'ENERGEN CHAMPION 12 X 10 X 2 X 35G PH',
      'KOPIKO CAFE MOCHA TP 12 X 10 X (2 X 25.5G) PH',
      'ENERGEN CHAMPION NBA TP 15 X 8 X 2 X 30G PH',
      'BLACK 420011 KOPIKO BLACK 3IN1 TWINPACK 12 X 10 X 2 X 28G',
    ],
    'V3': [
      'LE MINERALE 24x330ML',
      'LE MINERALE 24x600ML',
      'LE MINERALE 12x1500ML',
      'LE MINERALE 4 X 5000ML',
      'KOPIKO LUCKY DAY 24BTL X 180ML',
    ],
  };

  @override
  void initState() {
    super.initState();
    _inputId = TextEditingController(text: widget.item.inputId);
    _merchandiserNameController =
        TextEditingController(text: widget.item.merchandiserName);
    _outletController = TextEditingController(text: widget.item.outlet);
    _categoryController = TextEditingController();
    _itemController = TextEditingController();
    _quantityController = TextEditingController();
    _driverNameController = TextEditingController();
    _plateNumberController = TextEditingController();
    _pullOutReasonController = TextEditingController();

    _quantityController.addListener(_checkIfAllFieldsAreFilled);
    _driverNameController.addListener(_checkIfAllFieldsAreFilled);
    _plateNumberController.addListener(_checkIfAllFieldsAreFilled);
    _pullOutReasonController.addListener(_checkIfAllFieldsAreFilled);

    if (_categoryToSkuDescriptions.isNotEmpty) {
      selectedCategory = widget.item.category.isEmpty
          ? _categoryToSkuDescriptions.keys.first
          : widget.item.category;
      updateItemOptions(selectedCategory);
    }
  }

  @override
  void dispose() {
    _merchandiserNameController.dispose();
    _outletController.dispose();
    _inputId.dispose();
    _categoryController.dispose();
    _itemController.dispose();
    _quantityController.dispose();
    _driverNameController.dispose();
    _plateNumberController.dispose();
    _pullOutReasonController.dispose();
    super.dispose();
  }

  void updateItemOptions(String category) {
    setState(() {
      itemOptions = _categoryToSkuDescriptions[category] ?? [];
      selectedItem = itemOptions.isNotEmpty ? itemOptions.first : '';
      _itemController.text = selectedItem;
    });
  }

  void _toggleDropdown(String category) {
    setState(() {
      selectedCategory = category;
      updateItemOptions(category);
    });
  }

  void _checkIfAllFieldsAreFilled() {
    setState(() {
      isSaveButtonEnabled = _quantityController.text.isNotEmpty &&
          _driverNameController.text.isNotEmpty &&
          _plateNumberController.text.isNotEmpty &&
          _pullOutReasonController.text.isNotEmpty;
    });
  }

  Future<void> _confirmSaveReturnToVendor() async {
    if (!isSaveButtonEnabled) return;
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

    if (confirmed) {
      _saveChanges();
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Create an updated item object with the new values
      final updatedItem = ReturnToVendor(
        id: widget.item.id, // keep the same id to update the correct document
        inputId: _inputId.text,
        userEmail: widget.item.userEmail,
        date: widget.item.date,
        merchandiserName: _merchandiserNameController.text,
        outlet: _outletController.text,
        category: selectedCategory,
        item: _itemController.text,
        quantity: _quantityController.text,
        driverName: _driverNameController.text,
        plateNumber: _plateNumberController.text,
        pullOutReason: _pullOutReasonController.text,
      );

      // Call the method to update the item in the database
      MongoDatabase.updateItemInDatabase(updatedItem);

      // Navigate back to the RTV list screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit RTV',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Input ID',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: _inputId,
                readOnly: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Merchandiser',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: _merchandiserNameController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Outlet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: _outletController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
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
                    onPressed: null, // Disable button interaction
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
              Text(
                'SKU Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedItem,
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
                onChanged: null, // Disable the dropdown interaction
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  enabled:
                      false, // Optionally adjust the decoration to indicate read-only state
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Quantity',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                controller: _quantityController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Driver Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                controller: _driverNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter driver name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Plate Number',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                controller: _plateNumberController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter plate number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Pull Out Reason',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                controller: _pullOutReasonController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pull out reason';
                  }
                  return null;
                },
              ),
              SizedBox(height: 50),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSaveButtonEnabled ? Colors.green : Colors.grey,
                    padding: EdgeInsets.all(
                        20), // Increase padding to make the button larger
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          100), // Increased from 50 to 100 for a larger curve
                    ),
                  ),
                  onPressed:
                      isSaveButtonEnabled ? _confirmSaveReturnToVendor : null,
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: itemOptions.length,
          itemBuilder: (context, index) {
            final item = itemOptions[index];
            return ListTile(
              title: Text(item),
              onTap: () {
                setState(() {
                  selectedItem = item;
                  _itemController.text = selectedItem;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
