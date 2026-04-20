import 'package:flutter/material.dart';
import './address_page.dart'; // To access ProductItem

class ShoesPage extends StatefulWidget {
  final bool isDarkMode;
  final List<ProductItem> allProducts;
  final Map<int, int> initialCart;
  
  const ShoesPage({
    super.key, 
    required this.isDarkMode,
    required this.allProducts,
    required this.initialCart,
  });

  @override
  State<ShoesPage> createState() => _ShoesPageState();
}

class _ShoesPageState extends State<ShoesPage> {
  late Map<int, int> _localCart;
  late List<ProductItem> shoeProducts;

  @override
  void initState() {
    super.initState();
    _localCart = Map.from(widget.initialCart);
    shoeProducts = widget.allProducts.where((p) => p.category == 'Shoes').toList();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? const Color(0xFF0D0E17) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context, _localCart),
        ),
        title: Text('PREMIUM FOOTWEAR', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: textColor), 
            onPressed: () => Navigator.pop(context, _localCart)
          ),
          IconButton(icon: Icon(Icons.search, color: textColor), onPressed: () {}),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: textColor),
                onPressed: () => Navigator.pop(context, _localCart),
              ),
              if (_localCart.values.fold(0, (sum, v) => sum + v) > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: const Color(0xFF27C93F), shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '${_localCart.values.fold(0, (sum, v) => sum + v)}',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Headers
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: widget.isDarkMode ? Colors.white12 : Colors.black12)),
            ),
            child: Row(
              children: [
                _buildFilterItem('CATEGORY', true, widget.isDarkMode),
                _buildFilterItem('SIZE', false, widget.isDarkMode),
                _buildFilterItem('COLOR', false, widget.isDarkMode),
                _buildFilterItem('PRICE', false, widget.isDarkMode),
              ],
            ),
          ),
          // Product Grid - Single Column for "Large" effect
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 0.85, // Balanced large card ratio
                mainAxisSpacing: 30,
                crossAxisSpacing: 0,
              ),
              itemCount: shoeProducts.length,
              itemBuilder: (context, index) => _buildShoeCard(shoeProducts[index], widget.isDarkMode, context),
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

  Widget _buildShoeCard(ProductItem shoe, bool isDarkMode, BuildContext context) {
    final bool isDark = isDarkMode;
    final int globalIdx = widget.allProducts.indexOf(shoe);
    final int qty = _localCart[globalIdx] ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E202E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F1F1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Image Area
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: isDark ? Colors.white.withOpacity(0.02) : const Color(0xFFF9F9F9),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Hero(
                        tag: shoe.imageUrl + shoe.name,
                        child: Image.network(
                          shoe.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                      ),
                      child: const Icon(Icons.favorite_border, size: 22, color: Colors.black87),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'NEW ARRIVAL',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details Area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Delivery Timer
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27C93F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF27C93F)),
                              const SizedBox(width: 6),
                              Text('12 MINS DELIVERY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF27C93F))),
                            ],
                          ),
                        ),
                        Text(
                          shoe.price,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      shoe.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      shoe.size, // Using size for the subtitle description in ProductItem
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.white38 : Colors.black45, letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        // Sizes Preview
                        Expanded(
                          child: Row(
                            children: ['7', '8', '9', '10'].map((s) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: Text(s, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold))),
                            )).toList(),
                          ),
                        ),
                        // "ADD" Button consistent with Home Screen - Larger
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _localCart[globalIdx] = (_localCart[globalIdx] ?? 0) + 1;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${shoe.name} added to basket (Total: ${_localCart[globalIdx]})'), 
                                duration: const Duration(seconds: 1)
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            decoration: BoxDecoration(
                              color: qty > 0 ? const Color(0xFF27C93F).withOpacity(0.12) : const Color(0xFF27C93F),
                              borderRadius: BorderRadius.circular(16),
                              border: qty > 0 ? Border.all(color: const Color(0xFF27C93F), width: 1) : null,
                              boxShadow: qty > 0 ? null : [
                                BoxShadow(
                                  color: const Color(0xFF27C93F).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Text(
                              qty > 0 ? 'ADD MORE ($qty)' : 'ADD TO CART',
                              style: TextStyle(
                                color: qty > 0 ? const Color(0xFF27C93F) : Colors.white, 
                                fontSize: 13, 
                                fontWeight: FontWeight.w900, 
                                letterSpacing: 0.5
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
