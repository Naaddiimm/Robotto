import 'package:flutter/material.dart';

class GStore extends StatelessWidget {
  const GStore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4eef4),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'G-Store',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(10),

        children: const [
          MovieCard(
            image: 'assets/images/first.jpg',
            title: 'House of Dead',
          ),

          SizedBox(height: 10),

          MovieCard(
            image: 'assets/images/first.jpg',
            title: 'The Grudge',
          ),

          SizedBox(height: 10),

          MovieCard(
            image: 'assets/images/first.jpg',
            title: 'The Abyss',
          ),
        ],
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final String image;
  final String title;

  const MovieCard({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,

      child: Padding(
        padding: const EdgeInsets.all(8),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Image.asset(
              image,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 26,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
