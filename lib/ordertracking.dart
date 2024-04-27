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
      home: OrderTrackingScreen(),
    );
  }
}

class OrderTrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dummy order data
    List<Order> orders = [
      Order(id: '1', status: 'Preparing', estimatedTime: '20 mins'),
      Order(id: '2', status: 'On the way', estimatedTime: '5 mins'),
      Order(id: '3', status: 'Delivered', estimatedTime: 'N/A'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Tracking'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text('Order ID: ${order.id}'),
            subtitle: Text('Status: ${order.status} - ETA: ${order.estimatedTime}'),
          );
        },
      ),
    );
  }
}

// Model class for Order
class Order {
  final String id;
  final String status;
  final String estimatedTime;

  Order({
    required this.id,
    required this.status,
    required this.estimatedTime,
  });
}
