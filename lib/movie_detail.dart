import 'package:flutter/material.dart';

class MovieDetail extends StatelessWidget {
  const MovieDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf8fd),

      appBar: AppBar(
        backgroundColor: const Color(0xfffdf8fd),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text('House Of Dead'),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Movie image
          Image.asset(
            'assets/images/first.jpg',
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            height: 20,
          ),

          // Movie description
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'The House of the Dead is a 2023 remake '
                  'take place in 1998, following AMS agents '
                  'Thomas Rogan and G as they raid the mansion '
                  'of Dr. Curien, a genetic engineer who '
                  'has released creatures upon the research team.',
              style: TextStyle(fontSize: 14),
            ),
          ),

          const Spacer(),

          // Price
          const Center(
            child: Text(
              '300 DT',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Buy button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Buy action
              },
              icon: const Icon(Icons.shopping_basket),
              label: const Text('Acheter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
