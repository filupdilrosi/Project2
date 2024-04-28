import 'dart:async';

import 'package:flutter/material.dart';
import 'grocery_cart.dart'; // Import the grocery cart page

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Timer _timer;
  int _timeLeftInSeconds = 2700; // 45 minutes

  List<String> orderStatusList = [
    'Preparing Order',
    'Driver picking up order',
    'Order on the way',
    'Delivered',
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start the countdown timer when the widget is initialized
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeftInSeconds > 0) {
          _timeLeftInSeconds--;
          _updateCurrentIndex();
        } else {
          _timer.cancel();
        }
      });
    });
  }

  void _updateCurrentIndex() {
    if (_timeLeftInSeconds >= 1800) {
      // First 15 minutes
      _currentIndex = 0;
    } else if (_timeLeftInSeconds >= 1200) {
      // Next 10 minutes
      _currentIndex = 1;
    } else if (_timeLeftInSeconds >= 0) {
      // Last 20 minutes
      _currentIndex = 2;
    } else {
      // Timer ended
      _currentIndex = 3;
    }
  }

  String _formatTime(int seconds) {
    int minutes = (seconds / 60).truncate();
    int remainingSeconds = seconds % 60;
    String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    String secondsStr = (remainingSeconds < 10)
        ? '0$remainingSeconds'
        : '$remainingSeconds';
    return '$minutesStr:$secondsStr';
  }

  void _cancelOrder() {
    _timer.cancel();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => GroceryCartPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Status'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Estimated Delivery Time: ${_formatTime(_timeLeftInSeconds)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orderStatusList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(orderStatusList[index]),
                leading: Icon(
                  index == _currentIndex ? Icons.check_circle : Icons.circle,
                  color: index == _currentIndex ? Colors.green : null,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _cancelOrder,
              child: Text('Cancel Order'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GroceryCartPage()),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
