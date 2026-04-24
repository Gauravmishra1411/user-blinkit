import 'package:flutter/material.dart';
import './address_page.dart'; // To access ProductItem

class ShoesPage extends StatefulWidget {
  final bool isDarkMode;
  final List<ProductItem> allProducts;
  final Map<String, int> initialCart;
  
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
  late Map<String, int> _localCart;

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
                crossAxisCount: 4,
                childAspectRatio: 100 / 155, // 100px width / 150px height approx
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
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
    final int qty = _localCart[shoe.id] ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E202E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F1F1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
                      padding: const EdgeInsets.all(8.0),
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
                    top: 6,
                    right: 6,
                    child: Icon(Icons.favorite_border, size: 14, color: isDark ? Colors.white38 : Colors.black26),
                  ),
                ],
              ),
            ),
            // Minimal Details Area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shoe.price,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shoe.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    // Ultra Minimal ADD Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _localCart[shoe.id] = (_localCart[shoe.id] ?? 0) + 1;
                        });
                      },

                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: qty > 0 ? const Color(0xFF27C93F).withOpacity(0.12) : const Color(0xFF27C93F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            qty > 0 ? '$qty' : 'ADD',
                            style: TextStyle(
                              color: qty > 0 ? const Color(0xFF27C93F) : Colors.white, 
                              fontSize: 9, 
                              fontWeight: FontWeight.w900, 
                            ),
                          ),
                        ),
                      ),
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
