import 'package:flutter/material.dart';

class ShoeProduct {
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final List<String> availableSizes;
  final List<Color> availableColors;

  ShoeProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.availableSizes = const ['7', '8', '9', '10', '11'],
    this.availableColors = const [Colors.black, Colors.white, Colors.blue],
  });
}

class ShoesPage extends StatelessWidget {
  final bool isDarkMode;
  
  ShoesPage({super.key, required this.isDarkMode});

  final List<ShoeProduct> shoes = [
    ShoeProduct(
      name: 'REACT ELEMENT 87',
      description: 'LIGHT BONE',
      price: '\$130',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80',
    ),
    ShoeProduct(
      name: 'REACT ELEMENT 87',
      description: 'ANTHRACITE',
      price: '\$130',
      imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&q=80',
    ),
    ShoeProduct(
      name: 'AIR FORCE 1 LOW',
      description: '07 PRM "JUST DO IT"',
      price: '\$130',
      imageUrl: 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=400&q=80',
    ),
    ShoeProduct(
      name: 'OFF-WHITE X AIR PRESTO',
      description: 'BLACK',
      price: '\$710',
      imageUrl: 'https://images.unsplash.com/photo-1551107696-a4bc03264639?w=400&q=80',
    ),
    ShoeProduct(
      name: 'AIR FORCE 1 LOW',
      description: 'WHITE',
      price: '\$90',
      imageUrl: 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400&q=80',
    ),
    ShoeProduct(
      name: 'SEAN WOTHERSPOON X NIKE',
      description: 'AIR MAX 1/97',
      price: '\$790',
      imageUrl: 'https://images.unsplash.com/photo-1584486520270-19eca1efcce5?w=400&q=80',
    ),
    ShoeProduct(
      name: 'OFF-WHITE X VAPORMAX',
      description: 'PART 2 BLACK',
      price: '\$490',
      imageUrl: 'https://images.unsplash.com/photo-1543163530-107310df666c?w=400&q=80',
    ),
    ShoeProduct(
      name: 'ADIDAS YEEZY 350',
      description: 'TURTLE DOVE',
      price: '\$450',
      imageUrl: 'https://images.unsplash.com/photo-1587563871167-1ee9c731aefb?w=400&q=80',
    ),
    ShoeProduct(
      name: 'NIKE DUNK LOW',
      description: 'PANDA',
      price: '\$110',
      imageUrl: 'https://images.unsplash.com/photo-1628150346041-ca47af830863?w=400&q=80',
    ),
    ShoeProduct(
      name: 'AIR JORDAN 1 RETRO',
      description: 'UNIVERSITY BLUE',
      price: '\$180',
      imageUrl: 'https://images.unsplash.com/photo-1584735175315-9d58238a06cf?w=400&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF0D0E17) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('SHOES', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: textColor), onPressed: () {}),
          IconButton(icon: Icon(Icons.shopping_cart_outlined, color: textColor), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Filter Headers
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDarkMode ? Colors.white12 : Colors.black12)),
            ),
            child: Row(
              children: [
                _buildFilterItem('CATEGORY', true, isDarkMode),
                _buildFilterItem('SIZE', false, isDarkMode),
                _buildFilterItem('COLOR', false, isDarkMode),
                _buildFilterItem('PRICE', false, isDarkMode),
              ],
            ),
          ),
          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58, // Taller ratio to match home cards
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: shoes.length,
              itemBuilder: (context, index) => _buildShoeCard(shoes[index], isDarkMode, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, bool isSelected, bool isDarkMode) {
    return Expanded(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 14, color: isDarkMode ? Colors.white38 : Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _buildShoeCard(ShoeProduct shoe, bool isDarkMode, BuildContext context) {
    final bool isDark = isDarkMode;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E202E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F1F1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Image.network(shoe.imageUrl, fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(Icons.favorite_border, size: 16, color: isDark ? Colors.white38 : Colors.black38),
                ),
              ],
            ),
          ),
          // Details Area
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Timer (Reusable logic from Home)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 11, color: isDark ? Colors.white70 : Colors.black87),
                      const SizedBox(width: 4),
                      Text('12 MINS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : Colors.black87)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  shoe.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shoe.description,
                  maxLines: 1,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      shoe.price,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    // "ADD" Button consistent with Home Screen
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to basket'), duration: Duration(seconds: 1)),
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27C93F).withOpacity(0.1) : const Color(0xFFF7FFF9),
                          border: Border.all(color: const Color(0xFF27C93F), width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'ADD',
                            style: TextStyle(color: Color(0xFF27C93F), fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
