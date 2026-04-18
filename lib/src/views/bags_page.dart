import 'package:flutter/material.dart';

class BagProduct {
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final Color bgColor;
  final List<Color> variants;

  BagProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.bgColor,
    required this.variants,
  });
}

class BagsPage extends StatelessWidget {
  final bool isDarkMode;
  
  BagsPage({super.key, required this.isDarkMode});

  final List<BagProduct> bags = [
    BagProduct(
      name: 'Plume Avenue',
      description: 'Backpack M - Olive Green',
      price: '100.00 €',
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&q=80',
      bgColor: const Color(0xFF6B705C),
      variants: [const Color(0xFF6B705C), const Color(0xFFA5A58D), const Color(0xFFB7B7A4)],
    ),
    BagProduct(
      name: 'Plume Elegance',
      description: 'Handbag S - Ruby Red',
      price: '150.00 €',
      imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500&q=80',
      bgColor: const Color(0xFFBC4749),
      variants: [const Color(0xFFBC4749), const Color(0xFF6A040F), const Color(0xFF370617)],
    ),
    BagProduct(
      name: 'By The Seine',
      description: 'Bucket Bag - Royal Blue',
      price: '230.00 €',
      imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=500&q=80',
      bgColor: const Color(0xFF0077B6),
      variants: [const Color(0xFF0077B6), const Color(0xFF00B4D8), const Color(0xFF48CAE4)],
    ),
    BagProduct(
      name: 'Miss Plume',
      description: 'Backpack S - Rose Gold',
      price: '95.00 €',
      imageUrl: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=500&q=80',
      bgColor: const Color(0xFFD4A373),
      variants: [const Color(0xFFD4A373), const Color(0xFFFAEDCD), const Color(0xFFFEFAE0)],
    ),
    BagProduct(
      name: 'Variation',
      description: 'Shoulder Bag - Dusty Rose',
      price: '120.00 €',
      imageUrl: 'https://images.unsplash.com/photo-1566150905458-1bf1fd15dbc4?w=500&q=80',
      bgColor: const Color(0xFFB5838D),
      variants: [const Color(0xFFB5838D), const Color(0xFFE5989B), const Color(0xFFFFB4A2)],
    ),
    BagProduct(
      name: 'Plume Avenue',
      description: 'Tote Bag - Tan Leather',
      price: '135.00 €',
      imageUrl: 'https://images.unsplash.com/photo-1591561954557-26941169b49e?w=500&q=80',
      bgColor: const Color(0xFFCB997E),
      variants: [const Color(0xFFCB997E), const Color(0xFFDDBEA9), const Color(0xFFFFE8D6)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bags Collection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
          return GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.1,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            itemCount: bags.length,
            itemBuilder: (context, index) => _buildBagCard(bags[index]),
          );
        },
      ),
    );
  }

  Widget _buildBagCard(BagProduct bag) {
    return Container(
      color: bag.bgColor,
      padding: const EdgeInsets.all(40),
      child: Stack(
        children: [
          // Background Label
          Positioned(
            left: 0,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bag.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bag.price,
                  style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: bag.variants
                      .map((c) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30, width: 2),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          // Bag Image
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            left: 100,
            child: Center(
              child: Hero(
                tag: bag.imageUrl,
                child: Image.network(
                  bag.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Top Label
          Positioned(
            left: 0,
            top: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('LIPAULT', style: TextStyle(color: Colors.white30, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2)),
                const SizedBox(height: 12),
                Text(bag.description.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
          // Floating Action (Internal style)
          Positioned(
            right: 0,
            bottom: 0,
            child: Row(
              children: [
                _buildAction('SEE MORE', Colors.white, Colors.black),
                const SizedBox(width: 12),
                _buildActionIcon(Icons.add_shopping_cart, Colors.white24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildActionIcon(IconData icon, Color bg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}
