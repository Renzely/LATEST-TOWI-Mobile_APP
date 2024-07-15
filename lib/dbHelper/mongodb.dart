// ignore_for_file: avoid_print

import 'dart:developer';
import 'package:demo_app/dbHelper/constant.dart';
import 'package:demo_app/dbHelper/mongodbDraft.dart';
import 'package:mongo_dart/mongo_dart.dart';


class MongoDatabase {
  static var db, userCollection;

  static Future<void> connect() async {
    db = await Db.create(MONGO_CONN_URL);
    await db.open();
    inspect(db);
    userCollection = db.collection(USER_COLLECTION);
  }

  static Future<void> close() async {
    if (db != null && db.isConnected) {
      await db.close();
    }
  }

  static Future<String> insert(MongoDemo data) async {
  try {
    if (db == null || !db.isConnected) {
      await connect();
    }
    var userCollection = db.collection("TowiDb");
    print('Inserting data: ${data.toJson()}');
    await userCollection.insertOne(data.toJson());
    return "Success";
  } catch (e) {
    print("Insertion failed: $e");
    return "Error: $e";
  } finally {
    await close();
  }
}


    static Future<List<Map<String, dynamic>>> getData() async {
    await connect();
    final arrdata = await userCollection.find().toList();
    await close();
    return arrdata;
  }



  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      await connect(); // Ensure connection is established
      if (db.state == State.OPEN) {
        final userData = await userCollection.findOne();
        print('User Data: $userData'); // Print user data for debugging
        return userData;
      } else {
        print('Error: Database connection not open');
        return null;
      }
    } catch (e) {
      print('Error fetching user info: $e');
      return null;
    } finally {
      if (db != null && db.state == State.OPEN) {
        await db.close(); // Close the database connection if it's open
      }
    }
  }

  static Future<Map<String, dynamic>?> getUserDetailsById(String userId) async {
    try {
      await connect(); // Ensure connection is established
      final user =
          await userCollection.findOne({'_id': ObjectId.parse(userId)});
      return user;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserDetailsByUsername(
      String username) async {
    try {
      await connect(); // Ensure connection is established
      final user = await userCollection.findOne({'username': username});
      return user;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getBranchData() async {
    try {
      var db = await Db.create(MONGO_CONN_URL);
      await db.open();
      var collection =
          db.collection(USER_COLLECTION); // Ensure this is the correct collection
      var branches = await collection.find().toList();
      await db.close();
      return branches;
    } catch (e) {
      print("Error fetching branch data: $e");
      return [];
    }
    
  }
  
  static Future<void> updateItemInDatabase(ReturnToVendor updatedItem) async {
    if (db == null || !db!.isConnected) {
      await connect();
    }

    final collection = db!.collection(USER_RTV);

    final Map<String, dynamic> itemMap = updatedItem.toJson();

    try {
      // Use the ObjectId to identify the document to update
      final result = await collection.updateOne(
        where.eq('_id', updatedItem.id),
        modify
            .set('inputId', updatedItem.inputId)
            .set('userEmail', updatedItem.userEmail)
            .set('date', updatedItem.date)
            .set('merchandiserName', updatedItem.merchandiserName)
            .set('outlet', updatedItem.outlet)
            .set('category', updatedItem.category)
            .set('item', updatedItem.item)
            .set('quantity', updatedItem.quantity)
            .set('driverName', updatedItem.driverName)
            .set('plateNumber', updatedItem.plateNumber)
            .set('pullOutReason', updatedItem.pullOutReason),
      );

      // Check if the update was acknowledged and if any documents were matched or modified
      if (result.isAcknowledged) {
        if (result.writeErrors.isEmpty) {
          print('Return to vendor updated in database');
        } else {
          print('Errors occurred during update: ${result.writeErrors}');
        }
      } else {
        print('Update not acknowledged');
      }
    } catch (e) {
      print('Error updating return to vendor: $e');
    } finally {
      await close();
    }
  }
}