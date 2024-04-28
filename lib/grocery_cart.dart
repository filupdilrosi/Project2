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
// food_options.dart

// Define food options for each restaurant
const Map<String, List<String>> foodOptions = {
  'Café Bella': [
    'Pasta Carbonara',
    'Margherita Pizza',
    'Tiramisu',
    'Bruschetta',
    'Caprese Salad',
    'Chicken Alfredo',
    'Mushroom Risotto',
    'Chocolate Lava Cake',
    'Garlic Bread',
    'Tortellini Soup',
    'Cannoli',
    'Spinach Ravioli',
    'Panna Cotta',
    'Fettuccine Alfredo',
    'Italian Wedding Soup',
  ],
  'Rustic Kitchen': [
    'Grilled Salmon',
    'Wild Mushroom Risotto',
    'Apple Pie',
    'Ribeye Steak',
    'Mashed Potatoes',
    'Pumpkin Soup',
    'Lobster Bisque',
    'Fried Chicken',
    'Cornbread',
    'Gnocchi',
    'Stuffed Bell Peppers',
    'Beef Wellington',
    'Crème Brûlée',
    'Tuna Tartare',
    'Shrimp Scampi',
  ],
  'Spice Garden': [
    'Pad Thai',
    'Chicken Curry',
    'Tom Yum Soup',
    'Green Curry',
    'Mango Sticky Rice',
    'Thai Basil Fried Rice',
    'Red Curry',
    'Massaman Curry',
    'Spring Rolls',
    'Pineapple Fried Rice',
    'Papaya Salad',
    'Thai Iced Tea',
    'Fish Cakes',
    'Beef Satay',
    'Coconut Soup',
  ],
  'Ocean Blue Grill': [
    'Fish and Chips',
    'Clam Chowder',
    'Grilled Shrimp',
    'Lobster Roll',
    'Fish Tacos',
    'Seafood Paella',
    'Grilled Calamari',
    'Crab Cakes',
    'Shrimp Scampi',
    'Tuna Steak',
    'Salmon Burger',
    'Oysters Rockefeller',
    'Mussels Marinara',
    'Scallops',
    'Tuna Tartare',
  ],
  'Golden Harvest': [
    'Cheeseburger',
    'Club Sandwich',
    'French Fries',
    'Chicken Tenders',
    'Chicken Caesar Salad',
    'Buffalo Wings',
    'BLT Sandwich',
    'Grilled Cheese Sandwich',
    'Chicken Fried Steak',
    'Meatloaf',
    'Corned Beef Hash',
    'Reuben Sandwich',
    'Pot Roast',
    'Chicken Pot Pie',
    'Turkey Dinner',
  ],
  'Green Leaf': [
    'Caesar Salad',
    'Caprese Salad',
    'Greek Salad',
    'Spinach Salad',
    'Cobb Salad',
    'Nicoise Salad',
    'Waldorf Salad',
    'Chef Salad',
    'Asian Salad',
    'Quinoa Salad',
    'Fruit Salad',
    'Pasta Salad',
    'Taco Salad',
    'Steak Salad',
    'Beet Salad',
  ],
  'Sunrise Cafe': [
    'Pancakes',
    'French Toast',
    'Waffles',
    'Eggs Benedict',
    'Omelette',
    'Breakfast Burrito',
    'Bagel with Cream Cheese',
    'Avocado Toast',
    'Egg Sandwich',
    'Biscuits and Gravy',
    'Granola with Yogurt',
    'Fruit Smoothie',
    'Breakfast Bowl',
    'English Muffin with Jam',
    'Sausage Links',
  ],
  'LongHorns': [
    'Filet Mignon',
    'New York Strip Steak',
    'Ribeye Steak',
    'T-Bone Steak',
    'Porterhouse Steak',
    'Prime Rib',
    'Sirloin Steak',
    'Flat Iron Steak',
    'Chateaubriand',
    'Skirt Steak',
    'Hanger Steak',
    'Flank Steak',
    'Chuck Eye Steak',
    'Round Steak',
    'Beef Tenderloin',
  ],
  'Mystic Thai': [
    'Pad See Ew',
    'Green Curry',
    'Red Curry',
    'Tom Yum Soup',
    'Pad Thai',
    'Massaman Curry',
    'Thai Basil Chicken',
    'Mango Sticky Rice',
    'Papaya Salad',
    'Coconut Soup',
    'Spring Rolls',
    'Drunken Noodles',
    'Cashew Chicken',
    'Pineapple Fried Rice',
    'Crispy Pork Belly',
  ],
  'Pasta Paradise': [
    'Spaghetti Bolognese',
    'Fettuccine Alfredo',
    'Lasagna',
    'Penne Arrabiata',
    'Ravioli',
    'Carbonara',
    'Pesto Pasta',
    'Mac and Cheese',
    'Linguine with Clams',
    'Shrimp Scampi',
    'Seafood Linguine',
    'Chicken Parmesan',
    'Gnocchi',
    'Tortellini',
    'Stuffed Shells',
  ],
};
