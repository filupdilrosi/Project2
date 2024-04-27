import 'package:flutter/material.dart';

void main() {
  runApp(FoodDeliveryApp());
}

class FoodDeliveryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Homepage(),
    );
  }
}

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants'),
      ),
      body: RestaurantScreen(),
    );
  }
}

class RestaurantScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return ListTile(
          title: Text(restaurant.name),
          subtitle: Text(restaurant.description),
          trailing: Text('\$${restaurant.avgPrice.toStringAsFixed(2)}'),
          onTap: () {
            // Navigate to restaurant details screen
          },
        );
      },
    );
  }
}

// Model class for Restaurant
class Restaurant {
  final String name;
  final String description;
  final double avgPrice;

  Restaurant({
    required this.name,
    required this.description,
    required this.avgPrice,
  });
}

// Dummy data for restaurants
List
