import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order.dart'; // Import the order page

class GroceryCartPage extends StatefulWidget {
  const GroceryCartPage({Key? key}) : super(key: key);

  @override
  _GroceryCartPageState createState() => _GroceryCartPageState();
}

class _GroceryCartPageState extends State<GroceryCartPage> {
  List<Map<String, dynamic>> _cartItems = [];

  // Hard code the image paths for each restaurant
  static const List<String> restaurantImages = [
    'assets/one.png',
    'assets/two.png',
    'assets/three.png',
    'assets/four.png',
    'assets/five.png',
    'assets/six.png',
    'assets/seven.png',
    'assets/eight.png',
    'assets/nine.png',
    'assets/ten.png',
  ];

  @override
  void initState() {
    super.initState();
    _fetchItemsFromFirestore();
  }

  // Method to fetch items from Firestore collection
  void _fetchItemsFromFirestore() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('fooditems').get();

      List<Map<String, dynamic>> items = snapshot.docs
          .where((doc) =>
      doc.exists &&
          doc.data() != null &&
          (doc.data() as Map<String, dynamic>).containsKey('name') &&
          (doc.data() as Map<String, dynamic>)
              .containsKey('restaurant')) // Check if 'restaurant' field exists
          .map((doc) {
        // Construct a map with both food item and restaurant name
        return {
          'id': doc.id, // Add document id to identify the document in Firestore
          'foodItem': (doc.data() as Map<String, dynamic>)['name'] as String,
          'restaurant':
          (doc.data() as Map<String, dynamic>)['restaurant'] as String,
        };
      }).toList();

      // Group items by restaurant
      Map<String, List<Map<String, dynamic>>> groupedItems = {};
      for (var item in items) {
        String restaurant = item['restaurant'];
        if (!groupedItems.containsKey(restaurant)) {
          groupedItems[restaurant] = [];
        }
        groupedItems[restaurant]!.add(item);
      }

      setState(() {
        _cartItems = groupedItems.entries
            .map((entry) => {'restaurant': entry.key, 'items': entry.value})
            .toList();
      });
    } catch (error) {
      print('Error fetching items from Firestore: $error');
    }
  }
