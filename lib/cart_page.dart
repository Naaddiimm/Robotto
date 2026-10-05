import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf7fd),

      // AppBar
      appBar: AppBar(
        title: const Text(
          'My cart',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xfffdf7fd),
        elevation: 0,
      ),

      // Cart items
      body: ListView(
        padding: const EdgeInsets.all(10),

        children: const [

          // Movie 1
          CartItem(
            title: 'House Of Dead',
            image: 'assets/images/first.jpg',
          ),

          SizedBox(height: 10),

          // Movie 2
          CartItem(
            title: 'The Abyss',
            image: 'assets/images/first.jpg',
          ),

          SizedBox(height: 10),

          // Movie 3
          CartItem(
            title: 'Ice Road',
            image: 'assets/images/first.jpg',
          ),
        ],
      ),
    );
  }
}

// Reusable cart item
class CartItem extends StatelessWidget {
  final String title;
  final String image;

  const CartItem({
    super.key,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xfff5f0f6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: Color(0xffe5dfe8),
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.all(10),

        child: Row(
          children: [

            // Movie image
            Image.asset(
              image,
              width: 110,
              height: 65,
              fit: BoxFit.cover,
            ),

            const SizedBox(width: 10),

            // Movie title
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Static delete icon (no action)
            const Icon(
              Icons.delete,
              color: Colors.red,
              size: 27,
            ),
          ],
        ),
      ),
    );
  }
}


