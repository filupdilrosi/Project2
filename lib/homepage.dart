// homepage.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'food_options.dart'; // Import the food options file
import 'restaurant_details.dart'; // Import the restaurant details page
import 'grocery_cart.dart'; // Import the grocery cart page
import 'order.dart'; // Import the order page

class Homepage extends StatelessWidget {
  final User user;

  const Homepage({Key? key, required this.user}) : super(key: key);

  // Define a getter to dynamically compute the list of restaurant names
  List<String> get restaurants => foodOptions.keys.toList();

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

  // Generate random ratings for each restaurant
  Map<String, double> generateRandomRatings() {
    Random random = Random();
    return Map.fromIterable(restaurants, key: (restaurant) => restaurant, value: (_) => random.nextDouble() * 5);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> restaurantRatings = generateRandomRatings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Restaurants',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the restaurant details page when a restaurant is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailsPage(
                            restaurantName: restaurants[index],
                            foodOptions: foodOptions[restaurants[index]]!, // Pass the food options map instead of a list
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(restaurants[index]),
                            SizedBox(width: 8),
                            _buildStarRating(restaurantRatings[restaurants[index]] ?? 0),
                          ],
                        ),
                        // Container to hold background image
                        leading: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: AssetImage(restaurantImages[index]), // Use the hardcoded image path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Navigate to the homepage when home button is tapped
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                // Navigate to the grocery cart page when cart button is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroceryCartPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                // Navigate to the order page when order button is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Build star rating widget based on the given rating
  Widget _buildStarRating(double rating) {
    rating = max(rating, 3); // Ensure minimum rating of 3 stars
    int starCount = rating.floor();
    List<int> starList = List.generate(5, (index) => index + 1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: starList.map((index) {
        if (index <= starCount) {
          return Icon(Icons.star, color: Colors.orange);
        } else if (index - 1 < rating && rating < index) {
          return Icon(Icons.star_half, color: Colors.orange);
        } else {
          return Icon(Icons.star_border, color: Colors.orange);
        }
      }).toList(),
    );
  }
}
