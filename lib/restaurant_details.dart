import 'package:flutter/material.dart';
import 'grocery_cart.dart'; // Import the grocery cart page
import 'order.dart'; // Import the order page
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final String restaurantName;
  final List<String> foodOptions;

  const RestaurantDetailsPage({
    Key? key,
    required this.restaurantName,
    required this.foodOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurantName),
      ),
      body: ListView.builder(
        itemCount: foodOptions.length,
        itemBuilder: (context, index) {
          final foodItem = foodOptions[index];
          return ListTile(
            title: Text(foodItem),
            // Add any additional information about the food option here
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Add item to Firestore collection when the add button is clicked
                _addItemToFirestore(context, foodItem);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Order',
          ),
        ],
        currentIndex: 0, // Current page index
        onTap: (int index) {
          if (index == 0) {
            // Navigate to the homepage when home button is tapped
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            // Navigate to the grocery cart page when cart button is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GroceryCartPage()),
            );
          } else if (index == 2) {
            // Navigate to the order page when order button is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderPage()),
            );
          }
        },
      ),
    );
  }

  void _addItemToFirestore(BuildContext context, String foodItem) {
    // Get a reference to the Firestore collection 'fooditems'
    CollectionReference foodItems =
    FirebaseFirestore.instance.collection('fooditems');

    // Add the selected food item to Firestore
    foodItems.add({
      'name': foodItem,
      'restaurant': restaurantName, // Include the restaurant identifier
      // Add any additional fields you want to save for the food item
    }).then((value) {
      // Handle success
      print("Food item added to Firestore: $foodItem");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $foodItem to Firestore')),
      );
    }).catchError((error) {
      // Handle errors
      print("Failed to add food item to Firestore: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add $foodItem to Firestore')),
      );
    });
  }
}
