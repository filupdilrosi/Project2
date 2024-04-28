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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: ListView.builder(
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final restaurant = _cartItems[index]['restaurant'] as String;
          final items = _cartItems[index]['items'] as List<Map<String, dynamic>>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      restaurantImages[index], // Get the image path
                      width: 40,
                      height: 40,
                    ),
                    SizedBox(width: 8),
                    Text(
                      restaurant,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final foodItem = items[index]['foodItem'] as String;

                  return ListTile(
                    title: Text(foodItem),
                    trailing: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        removeItem(
                          restaurant,
                          items[index]['id'] as String,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                // Navigate to the grocery cart page
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPage()),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the order page when submit button is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPage()),
                );
              },
              child: Text('Submit Order'),
            ),
          ],
        ),
      ),
    );
  }

  void removeItem(String restaurant, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('fooditems')
          .doc(documentId)
          .delete();

      setState(() {
        _cartItems.forEach((element) {
          if (element['restaurant'] == restaurant) {
            List<Map<String, dynamic>> items = element['items'];
            items.removeWhere((item) => item['id'] == documentId);
          }
        });
      });
    } catch (error) {
      print('Error deleting item from Firestore: $error');
    }
  }
}
