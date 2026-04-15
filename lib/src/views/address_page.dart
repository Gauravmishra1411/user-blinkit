import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import './add_address_page.dart';
import './payment_page.dart';
import '../widgets/kb_logo.dart';

class Product {
  final String name;
  final String image;
  final double price;

  Product({
    required this.name,
    required this.image,
    required this.price,
  });
}

Map<String, List<Product>> categoryProducts = {
  "Fruits & Vegetables": [
    Product(name: "Tomato", image: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&fit=crop", price: 20),
    Product(name: "Potato", image: "https://images.unsplash.com/photo-1518977676601-b53f02bad675?w=400&fit=crop", price: 30),
    Product(name: "Onion", image: "https://images.unsplash.com/photo-1508747703725-719777637510?w=400&fit=crop", price: 25),
  ],
  "Snacks & Munchies": [
    Product(name: "Lays Classic", image: "https://images.unsplash.com/photo-1566417713040-47b07bc271f4?w=400&fit=crop", price: 20),
    Product(name: "Kurkure", image: "https://images.unsplash.com/photo-1600271886395-d22f18962883?w=400&fit=crop", price: 15),
    Product(name: "Doritos", image: "https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400&fit=crop", price: 30),
  ],
};

class CategoryItem {
  final String label;
  final IconData icon;
  final Color color;

  CategoryItem({required this.label, required this.icon, required this.color});
}

class ProductItem {
  final String name;
  final String size;
  final String price;
  final String deliveryMins;
  final String imageUrl;
  final String category;

  ProductItem({
    required this.name,
    required this.size,
    required this.price,
    required this.deliveryMins,
    required this.imageUrl,
    required this.category,
  });
}

class AddressPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const AddressPage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  String _address = 'Gaur city center';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  final Map<int, int> _productQty = {}; // productIndex -> qty
  bool _isDonationEnabled = false;
  int _selectedTip = 0;
  int _selectedAddressIndex = 0;
  String _userName = 'Rohit';
  String _userEmail = 'rohit@example.com';
  String _userPhone = '7360842275';
  bool _showMoreCategories = false;

  final List<Map<String, String>> _savedAddresses = [
    {
      'type': 'Home',
      'address': 'Flat 402, Green Valley Apartments, Sector 12, Dwarka, Delhi',
      'icon': 'home'
    },
    {
      'type': 'Office',
      'address': 'Plot No. 18, 5th Floor, Cyber Hub, Gurgaon, Haryana',
      'icon': 'work'
    },
    {
      'type': 'Other',
      'address': 'Cafe Coffee Day, Connaught Place, Block B, New Delhi',
      'icon': 'location_on'
    },
  ];
  final List<String> _placeholderNames = [
    'paan corne',
    'dairy',
    'bread & Eggs',
    'Fruit & Vegetable',
    'cold drink & juices',
    'sweet Tooth',
    'Atta',
    'Rice &Dal'
  ];
  int _placeholderIndex = 0;
  Timer? _placeholderTimer;
  late ScrollController _categoryScrollController;

  final List<Map<String, String>> foodData = [
    {
      "title": "Non-boring recipes",
      "subtitle": "from the chef's chef",
      "offer": "FREE BOOK",
      "img": "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&fit=crop",
    },
    {
      "title": "Chips & Namkeen",
      "subtitle": "Crispy & Delicious Snacks",
      "offer": "Buy 1 Get 1",
      "img": "assets/images/download.jpg",
    },
    {
      "title": "Fresh Wheat Flour",
      "subtitle": "100% Pure & Stone Ground",
      "offer": "Flat 20% OFF",
      "img": "assets/images/Grau.jpg",
    },
  ];

  int _currentBannerIndex = 0;
  late PageController _bannerController;
  Timer? _bannerTimer;

  double get itemsTotal {
    double total = 0;
    _productQty.forEach((index, qty) {
      final product = allProducts[index];
      final priceStr = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
      final price = double.tryParse(priceStr) ?? 0;
      total += price * qty;
    });
    return total;
  }

  double get totalCartAmount => itemsTotal + 25 + 2 + (_isDonationEnabled ? 1 : 0) + _selectedTip;

  int get totalCartItems => _productQty.values.fold(0, (sum, val) => sum + val);

  final List<CategoryItem> categories = [
    CategoryItem(label: 'All', icon: Icons.dashboard, color: const Color(0xFF39D2FF)),
    CategoryItem(label: 'Paan Corner', icon: Icons.local_fire_department, color: const Color(0xFFFFB84D)),
    CategoryItem(label: 'Dairy, Bread & Eggs', icon: Icons.shopping_basket, color: const Color(0xFF9C27B0)),
    CategoryItem(label: 'Fruits & Vegetables', icon: Icons.eco, color: const Color(0xFF4CAF50)),
    CategoryItem(label: 'Cold Drinks & Juices', icon: Icons.local_cafe, color: const Color(0xFF2196F3)),
    CategoryItem(label: 'Snacks & Munchies', icon: Icons.emoji_food_beverage, color: const Color(0xFFFF9800)),
    CategoryItem(label: 'Breakfast & Instant Food', icon: Icons.restaurant, color: const Color(0xFFE91E63)),
    CategoryItem(label: 'Sweet Tooth', icon: Icons.cake, color: const Color(0xFFF44336)),
    CategoryItem(label: 'Bakery & Biscuits', icon: Icons.bakery_dining, color: const Color(0xFFD2691E)),
    CategoryItem(label: 'Tea, Coffee & Milk Drinks', icon: Icons.local_drink, color: const Color(0xFF8B4513)),
    CategoryItem(label: 'Atta, Rice & Dal', icon: Icons.grain, color: const Color(0xFFCD853F)),
    CategoryItem(label: 'Masala, Oil & More', icon: Icons.opacity, color: const Color(0xFFDEB887)),
    CategoryItem(label: 'Sauces & Spreads', icon: Icons.local_dining, color: const Color(0xFFBDB76B)),
    CategoryItem(label: 'Chicken, Meat & Fish', icon: Icons.fastfood, color: const Color(0xFFA52A2A)),
    CategoryItem(label: 'Organic & Healthy Living', icon: Icons.local_hospital, color: const Color(0xFF20B2AA)),
    CategoryItem(label: 'Baby Care', icon: Icons.child_care, color: const Color(0xFFFFB6C1)),
    CategoryItem(label: 'Pharma & Wellness', icon: Icons.medical_services, color: const Color(0xFF00CED1)),
    CategoryItem(label: 'Cleaning Essentials', icon: Icons.cleaning_services, color: const Color(0xFF696969)),
    CategoryItem(label: 'Home & Office', icon: Icons.home, color: const Color(0xFF8B7355)),
    CategoryItem(label: 'Personal Care', icon: Icons.spa, color: const Color(0xFFDDA0DD)),
    CategoryItem(label: 'Pet Care', icon: Icons.pets, color: const Color(0xFF6495ED)),
  ];

  final List<ProductItem> allProducts = [
    // All / Dairy, Bread & Eggs
    ProductItem(name: 'Amul Gold Full Cream Milk', size: '500 ml', price: '₹35', deliveryMins: '17', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'All'),
    ProductItem(name: 'Britannia Whole Wheat Bread', size: '400 g', price: '₹42', deliveryMins: '12', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'All'),
    ProductItem(name: 'Farm Fresh Eggs', size: '6 pcs', price: '₹58', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200&h=200&fit=crop', category: 'All'),
    ProductItem(name: 'Amul Butter Salted', size: '100 g', price: '₹56', deliveryMins: '19', imageUrl: 'https://images.unsplash.com/photo-1632942070066-00f4f4e3b28c?w=200&h=200&fit=crop', category: 'All'),
    ProductItem(name: 'Parle-G Biscuits', size: '800 g', price: '₹50', deliveryMins: '10', imageUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=200&h=200&fit=crop', category: 'All'),
    ProductItem(name: 'Aashirvaad Atta', size: '5 kg', price: '₹275', deliveryMins: '20', imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=200&h=200&fit=crop', category: 'All'),
    ProductItem(name: 'Fortune Sunflower Oil', size: '1 L', price: '₹148', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=200&h=200&fit=crop', category: 'All'),
    ProductItem(name: 'Tata Salt', size: '1 kg', price: '₹22', deliveryMins: '11', imageUrl: 'https://images.unsplash.com/photo-1588315029754-2dd089d39a1a?w=200&h=200&fit=crop', category: 'All'),
    ProductItem(name: 'Maggi 2-Minute Noodles', size: '560 g', price: '₹82', deliveryMins: '14', imageUrl: 'https://images.unsplash.com/photo-1617093727343-374698b1b08d?w=200&h=200&fit=crop', category: 'All'),
    // Fruits & Vegetables
    ProductItem(name: 'Fresh Tomatoes', size: '500 g', price: '₹28', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1607305387299-a3d9611cd469?w=200&h=200&fit=crop', category: 'Fruits & Vegetables'),
    ProductItem(name: 'Green Spinach', size: '250 g', price: '₹22', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=200&h=200&fit=crop', category: 'Fruits & Vegetables'),
    ProductItem(name: 'Bananas', size: '6 pcs', price: '₹40', deliveryMins: '17', imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=200&h=200&fit=crop', category: 'Fruits & Vegetables'),
    ProductItem(name: 'Apple Royal Gala', size: '4 pcs', price: '₹120', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?w=200&h=200&fit=crop', category: 'Fruits & Vegetables'),
    ProductItem(name: 'Carrots', size: '500 g', price: '₹35', deliveryMins: '14', imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=200&h=200&fit=crop', category: 'Fruits & Vegetables'),
    ProductItem(name: 'Onions', size: '1 kg', price: '₹45', deliveryMins: '12', imageUrl: 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=200&h=200&fit=crop', category: 'Fruits & Vegetables'),
    ProductItem(name: 'Mango Alphonso', size: '3 pcs', price: '₹99', deliveryMins: '20', imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=200&h=200&fit=crop', category: 'Fruits & Vegetables'),
    ProductItem(name: 'Potatoes', size: '1 kg', price: '₹38', deliveryMins: '11', imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=200&h=200&fit=crop', category: 'Fruits & Vegetables'),
    ProductItem(name: 'Grapes Green', size: '500 g', price: '₹65', deliveryMins: '16', imageUrl: 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=200&h=200&fit=crop', category: 'Fruits & Vegetables'),
    // Snacks & Munchies
    ProductItem(name: 'Lays Classic Salted', size: '73 g', price: '₹20', deliveryMins: '10', imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=200&h=200&fit=crop', category: 'Snacks & Munchies'),
    ProductItem(name: 'Haldiram Aloo Bhujia', size: '200 g', price: '₹55', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1585388013038-c88d3dc6ab5c?w=200&h=200&fit=crop', category: 'Snacks & Munchies'),
    ProductItem(name: 'Kurkure Masala', size: '80 g', price: '₹20', deliveryMins: '11', imageUrl: 'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?w=200&h=200&fit=crop', category: 'Snacks & Munchies'),
    ProductItem(name: 'Oreo Chocolate', size: '120 g', price: '₹30', deliveryMins: '12', imageUrl: 'https://images.unsplash.com/photo-1571506165871-ee72a35bc9d4?w=200&h=200&fit=crop', category: 'Snacks & Munchies'),
    ProductItem(name: 'Good Day Butter', size: '216 g', price: '₹40', deliveryMins: '14', imageUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=200&h=200&fit=crop', category: 'Snacks & Munchies'),
    ProductItem(name: 'Pringles Original', size: '107 g', price: '₹120', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=200&h=200&fit=crop', category: 'Snacks & Munchies'),
    ProductItem(name: 'Bingo Mad Angles', size: '90 g', price: '₹20', deliveryMins: '10', imageUrl: 'https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1?w=200&h=200&fit=crop', category: 'Snacks & Munchies'),
    ProductItem(name: 'Choco Pie', size: '180 g', price: '₹80', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1571506165871-ee72a35bc9d4?w=200&h=200&fit=crop', category: 'Snacks & Munchies'),
    ProductItem(name: 'Nutella Hazelnut Spread', size: '200 g', price: '₹220', deliveryMins: '19', imageUrl: 'https://images.unsplash.com/photo-1575325771870-2d8db4c1e8b7?w=200&h=200&fit=crop', category: 'Snacks & Munchies'),
    // Cold Drinks & Juices
    ProductItem(name: 'Coca-Cola', size: '750 ml', price: '₹45', deliveryMins: '11', imageUrl: 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=200&h=200&fit=crop', category: 'Cold Drinks & Juices'),
    ProductItem(name: 'Real Orange Juice', size: '1 L', price: '₹110', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200&h=200&fit=crop', category: 'Cold Drinks & Juices'),
    ProductItem(name: 'Sprite Lemon', size: '600 ml', price: '₹40', deliveryMins: '12', imageUrl: 'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=200&h=200&fit=crop', category: 'Cold Drinks & Juices'),
    ProductItem(name: 'Red Bull Energy', size: '250 ml', price: '₹125', deliveryMins: '14', imageUrl: 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=200&h=200&fit=crop', category: 'Cold Drinks & Juices'),
    ProductItem(name: 'Tropicana Apple', size: '1 L', price: '₹115', deliveryMins: '17', imageUrl: 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=200&h=200&fit=crop', category: 'Cold Drinks & Juices'),
    ProductItem(name: 'Pepsi', size: '600 ml', price: '₹38', deliveryMins: '10', imageUrl: 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=200&h=200&fit=crop', category: 'Cold Drinks & Juices'),
    ProductItem(name: 'Mountain Dew', size: '600 ml', price: '₹40', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=200&h=200&fit=crop', category: 'Cold Drinks & Juices'),
    ProductItem(name: 'Appy Fizz', size: '600 ml', price: '₹35', deliveryMins: '11', imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200&h=200&fit=crop', category: 'Cold Drinks & Juices'),
    ProductItem(name: 'Limca Lemon', size: '500 ml', price: '₹30', deliveryMins: '12', imageUrl: 'https://images.unsplash.com/photo-1625772299848-391b6a87d7b3?w=200&h=200&fit=crop', category: 'Cold Drinks & Juices'),
    // Pet Care
    ProductItem(name: 'Pedigree Adult Dog Food', size: '3 kg', price: '₹520', deliveryMins: '20', imageUrl: 'https://images.unsplash.com/photo-1589924691995-400dc9eee119?w=200&h=200&fit=crop', category: 'Pet Care'),
    ProductItem(name: 'Whiskas Cat Food', size: '1.2 kg', price: '₹360', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200&h=200&fit=crop', category: 'Pet Care'),
    ProductItem(name: 'Dog Chew Treats', size: '100 g', price: '₹180', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=200&h=200&fit=crop', category: 'Pet Care'),
    ProductItem(name: 'IAMS Kitten Food', size: '800 g', price: '₹420', deliveryMins: '19', imageUrl: 'https://images.unsplash.com/photo-1518791841217-8f162f1912da?w=200&h=200&fit=crop', category: 'Pet Care'),
    ProductItem(name: 'Dog Collar Leash', size: 'Medium', price: '₹299', deliveryMins: '22', imageUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=200&h=200&fit=crop', category: 'Pet Care'),
    ProductItem(name: 'Pet Shampoo', size: '200 ml', price: '₹145', deliveryMins: '17', imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=200&h=200&fit=crop', category: 'Pet Care'),
    ProductItem(name: 'Cat Litter Sand', size: '5 kg', price: '₹380', deliveryMins: '20', imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200&h=200&fit=crop', category: 'Pet Care'),
    ProductItem(name: 'Bird Feed Mix', size: '500 g', price: '₹95', deliveryMins: '16', imageUrl: 'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=200&h=200&fit=crop', category: 'Pet Care'),
    ProductItem(name: 'Fish Tank Gravel', size: '1 kg', price: '₹120', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=200&h=200&fit=crop', category: 'Pet Care'),
    // Baby Care
    ProductItem(name: 'Pampers Diapers', size: 'M – 44 pcs', price: '₹799', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=200&h=200&fit=crop', category: 'Baby Care'),
    ProductItem(name: 'Johnson Baby Lotion', size: '200 ml', price: '₹148', deliveryMins: '16', imageUrl: 'https://images.unsplash.com/photo-1519689680058-324335c77eba?w=200&h=200&fit=crop', category: 'Baby Care'),
    ProductItem(name: 'Cerelac Wheat', size: '300 g', price: '₹180', deliveryMins: '19', imageUrl: 'https://images.unsplash.com/photo-1558468759-5b91ba55e9a4?w=200&h=200&fit=crop', category: 'Baby Care'),
    ProductItem(name: 'Himalaya Baby Wash', size: '400 ml', price: '₹160', deliveryMins: '14', imageUrl: 'https://images.unsplash.com/photo-1519689680058-324335c77eba?w=200&h=200&fit=crop', category: 'Baby Care'),
    ProductItem(name: 'Baby Rattle Toy', size: 'Set of 3', price: '₹349', deliveryMins: '22', imageUrl: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=200&h=200&fit=crop', category: 'Baby Care'),
    ProductItem(name: 'WaterWipes Baby Wipes', size: '60 pcs', price: '₹299', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=200&h=200&fit=crop', category: 'Baby Care'),
    ProductItem(name: 'Mee Mee Feeding Bottle', size: '250 ml', price: '₹240', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1558468759-5b91ba55e9a4?w=200&h=200&fit=crop', category: 'Baby Care'),
    ProductItem(name: 'Baby Powder Talc', size: '100 g', price: '₹89', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1519689680058-324335c77eba?w=200&h=200&fit=crop', category: 'Baby Care'),
    ProductItem(name: 'Gripe Water', size: '130 ml', price: '₹95', deliveryMins: '16', imageUrl: 'https://images.unsplash.com/photo-1558468759-5b91ba55e9a4?w=200&h=200&fit=crop', category: 'Baby Care'),
    // Pharma & Wellness
    ProductItem(name: 'Dettol Sanitizer', size: '200 ml', price: '₹115', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&h=200&fit=crop', category: 'Pharma & Wellness'),
    ProductItem(name: 'Band-Aid Strips', size: '20 pcs', price: '₹65', deliveryMins: '12', imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&h=200&fit=crop', category: 'Pharma & Wellness'),
    ProductItem(name: 'Vicks VapoRub', size: '25 ml', price: '₹80', deliveryMins: '14', imageUrl: 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=200&h=200&fit=crop', category: 'Pharma & Wellness'),
    ProductItem(name: 'Strepsils Lozenges', size: '24 pcs', price: '₹110', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=200&h=200&fit=crop', category: 'Pharma & Wellness'),
    ProductItem(name: 'Betadine Antiseptic', size: '30 ml', price: '₹68', deliveryMins: '16', imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&h=200&fit=crop', category: 'Pharma & Wellness'),
    ProductItem(name: 'ENO Fruit Salt', size: '100 g', price: '₹55', deliveryMins: '11', imageUrl: 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=200&h=200&fit=crop', category: 'Pharma & Wellness'),
    ProductItem(name: 'Glucon-D', size: '200 g', price: '₹82', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=200&h=200&fit=crop', category: 'Pharma & Wellness'),
    ProductItem(name: 'Moov Pain Relief', size: '25 g', price: '₹95', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&h=200&fit=crop', category: 'Pharma & Wellness'),
    ProductItem(name: 'Volini Spray', size: '55 g', price: '₹145', deliveryMins: '17', imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&h=200&fit=crop', category: 'Pharma & Wellness'),
    // Dairy, Bread & Eggs
    ProductItem(name: 'Amul Gold Full Cream Milk', size: '500 ml', price: '₹35', deliveryMins: '17', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Taaza Toned Milk', size: '1 L', price: '₹58', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Butter Salted', size: '100 g', price: '₹56', deliveryMins: '19', imageUrl: 'https://images.unsplash.com/photo-1632942070066-00f4f4e3b28c?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Cheese Slices', size: '200 g', price: '₹118', deliveryMins: '20', imageUrl: 'https://images.unsplash.com/photo-1618166912462-4428d2e83cac?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Britannia Whole Wheat Bread', size: '400 g', price: '₹42', deliveryMins: '12', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Farm Fresh Eggs', size: '6 pcs', price: '₹58', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Nestlé Munch Curd', size: '400 g', price: '₹40', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Shrikhand Mango', size: '200 g', price: '₹70', deliveryMins: '22', imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Mother Dairy Curd', size: '500 g', price: '₹45', deliveryMins: '16', imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Britannia Brown Bread', size: '500 g', price: '₹48', deliveryMins: '14', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Mozzarella Cheese', size: '200 g', price: '₹145', deliveryMins: '21', imageUrl: 'https://images.unsplash.com/photo-1618166912462-4428d2e83cac?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Farm Eggs Tray', size: '12 pcs', price: '₹108', deliveryMins: '16', imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Lassi Rose', size: '200 ml', price: '₹28', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Milky Mist Paneer', size: '200 g', price: '₹82', deliveryMins: '20', imageUrl: 'https://images.unsplash.com/photo-1618166912462-4428d2e83cac?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Nature’s Active Pav', size: '6 pcs', price: '₹30', deliveryMins: '11', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Cream 25% Fat', size: '250 ml', price: '₹82', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Britannia Multigrain Bread', size: '400 g', price: '₹52', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Ghee', size: '500 ml', price: '₹305', deliveryMins: '19', imageUrl: 'https://images.unsplash.com/photo-1632942070066-00f4f4e3b28c?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Mother Dairy Buttermilk', size: '500 ml', price: '₹30', deliveryMins: '14', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Go Cheese Spread', size: '180 g', price: '₹110', deliveryMins: '20', imageUrl: 'https://images.unsplash.com/photo-1618166912462-4428d2e83cac?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Nandini Milk Full Cream', size: '500 ml', price: '₹34', deliveryMins: '17', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Harvest Gold Bread', size: '400 g', price: '₹40', deliveryMins: '12', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Desi Eggs Brown', size: '6 pcs', price: '₹68', deliveryMins: '16', imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Kool Flavoured Milk', size: '200 ml', price: '₹32', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Verka Paneer', size: '500 g', price: '₹195', deliveryMins: '21', imageUrl: 'https://images.unsplash.com/photo-1618166912462-4428d2e83cac?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Wibs Pav Buns', size: '12 pcs', price: '₹48', deliveryMins: '14', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Lite Slim Trim Milk', size: '500 ml', price: '₹38', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Nutralite Butter', size: '100 g', price: '₹60', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1632942070066-00f4f4e3b28c?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Mishti Doi', size: '100 g', price: '₹22', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Heritage Milk Curd Set', size: '400 g', price: '₹42', deliveryMins: '17', imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Naan Bread', size: '5 pcs', price: '₹50', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Sour Cream', size: '200 g', price: '₹78', deliveryMins: '19', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Britannia Roti', size: '400 g', price: '₹44', deliveryMins: '11', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Prabhat Butter Unsalted', size: '100 g', price: '₹58', deliveryMins: '20', imageUrl: 'https://images.unsplash.com/photo-1632942070066-00f4f4e3b28c?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Farm Fresh Organic Eggs', size: '12 pcs', price: '₹130', deliveryMins: '18', imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Pro Protein Drink', size: '500 g', price: '₹248', deliveryMins: '22', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Brun Maska Bread', size: '4 pcs', price: '₹35', deliveryMins: '12', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'ITC Sunfeast Bread', size: '300 g', price: '₹38', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Butter Lite', size: '100 g', price: '₹50', deliveryMins: '17', imageUrl: 'https://images.unsplash.com/photo-1632942070066-00f4f4e3b28c?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Mother Dairy Paneer', size: '200 g', price: '₹88', deliveryMins: '20', imageUrl: 'https://images.unsplash.com/photo-1618166912462-4428d2e83cac?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Sourdough Bread', size: '350 g', price: '₹70', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Cool Café', size: '200 ml', price: '₹35', deliveryMins: '14', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Vijaya Butter Salted', size: '100 g', price: '₹54', deliveryMins: '19', imageUrl: 'https://images.unsplash.com/photo-1632942070066-00f4f4e3b28c?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Masoom White Eggs', size: '30 pcs', price: '₹235', deliveryMins: '16', imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Donut Bread Rolls', size: '4 pcs', price: '₹42', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Spreadable Butter', size: '200 g', price: '₹102', deliveryMins: '21', imageUrl: 'https://images.unsplash.com/photo-1632942070066-00f4f4e3b28c?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Nandini Curd', size: '500 g', price: '₹44', deliveryMins: '16', imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Heritage Greek Yoghurt', size: '100 g', price: '₹45', deliveryMins: '17', imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Milky Mist Thick Curd', size: '400 g', price: '₹40', deliveryMins: '15', imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Amul Masti Spiced Buttermilk', size: '200 ml', price: '₹25', deliveryMins: '12', imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
    ProductItem(name: 'Britannia Milk Rusk', size: '290 g', price: '₹55', deliveryMins: '13', imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=200&h=200&fit=crop', category: 'Dairy, Bread & Eggs'),
  ];

  String get _categoryMessage {
    final selectedCategory = categories[_selectedCategoryIndex].label;
    return selectedCategory == 'All'
        ? 'Explore all categories and discover your favorites.'
        : 'Showing items for "$selectedCategory".';
  }

  late ScrollController _mainScrollController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    // _getCurrentAddress(); // Disabled to show fixed address as requested
    _startPlaceholderTimer();
    _categoryScrollController = ScrollController();
    _mainScrollController = ScrollController();
    _mainScrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _mainScrollController.offset;
        });
      }
    });

    _bannerController = PageController(initialPage: 501); // Middle for loop
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        _bannerController.nextPage(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }


  void _startPlaceholderTimer() {
    _placeholderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _placeholderIndex = (_placeholderIndex + 1) % _placeholderNames.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _searchController.dispose();
    _placeholderTimer?.cancel();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentAddress() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _address = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _address = 'Location permission permanently denied';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _address = 'Latitude: ${position.latitude.toStringAsFixed(6)}\n'
            'Longitude: ${position.longitude.toStringAsFixed(6)}\n'
            'Accuracy: ${position.accuracy.toStringAsFixed(2)} meters';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _address = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = categories[_selectedCategoryIndex].label;

    return Scaffold(
      appBar: null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.isDarkMode
                ? [const Color(0xFF090A12), const Color(0xFF110F23)]
                : [const Color(0xFFF0F0F0), const Color(0xFFE8E8E8)],
          ),
        ),
        child: CustomScrollView(
          controller: _mainScrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchHeaderDelegate(
                isDarkMode: widget.isDarkMode,
                address: _address,
                userName: _userName,
                searchController: _searchController,
                placeholderIndex: _placeholderIndex,
                placeholderNames: _placeholderNames,
                onSearchChanged: () => setState(() {}),
                onThemeToggle: widget.onThemeToggle,
                totalCartItems: totalCartItems,
                itemsTotal: itemsTotal,
                onCartTap: _showCartModal,
                onAccountTap: (ctx, pos) => _showAccountMenu(ctx, pos),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  children: [
                    // Content start
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      controller: _categoryScrollController,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: _showMoreCategories ? categories.length : (categories.length > 9 ? 9 : categories.length),
                      itemBuilder: (context, index) {
                        if (!_showMoreCategories && categories.length > 9 && index == 8) {
                          return _buildMoreCategoryItem();
                        }
                        final category = categories[index];
                        final isSelected = _selectedCategoryIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                              if (categoryProducts.containsKey(category.label)) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductScreen(
                                      categoryName: category.label,
                                      isDarkMode: widget.isDarkMode,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? category.color.withOpacity(0.2)
                                        : (widget.isDarkMode
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.black.withOpacity(0.08)),
                                    border: Border.all(
                                      color: isSelected
                                          ? category.color
                                          : (widget.isDarkMode
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.black.withOpacity(0.2)),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: category.color,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 75,
                                  child: Text(
                                    category.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? (widget.isDarkMode ? Colors.white : Colors.black)
                                          : (widget.isDarkMode
                                              ? Colors.white70
                                              : Colors.black54),
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _bannerController,
                      itemCount: 10000, // For infinite feel
                      onPageChanged: (index) => setState(() => _currentBannerIndex = index % foodData.length),
                      itemBuilder: (context, index) {
                        final item = foodData[index % foodData.length];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: item["img"]!.startsWith('assets/')
                                  ? AssetImage(item["img"]!) as ImageProvider
                                  : NetworkImage(item["img"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["title"]!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      item["subtitle"]!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    item["offer"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 10,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(foodData.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: _currentBannerIndex == index ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentBannerIndex == index
                                  ? const Color(0xFF27C93F)
                                  : (widget.isDarkMode ? Colors.white24 : Colors.black12),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── NEW SIX FEATURED CARDS SECTION ──────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildFeaturedStripCard(
                              title: 'Vegetables\n& Fruits',
                              count: '+173',
                              img: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&fit=crop',
                              color: const Color(0xFFE8F5E9),
                              textColor: const Color(0xFF2E7D32),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductScreen(
                                    categoryName: "Fruits & Vegetables",
                                    isDarkMode: widget.isDarkMode,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFeaturedStripCard(
                              title: 'Chips &\nNamkeen',
                              count: '+432',
                              img: 'assets/images/download.jpg',
                              color: const Color(0xFFFFF3E0),
                              textColor: const Color(0xFFE65100),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductScreen(
                                    categoryName: "Snacks & Munchies",
                                    isDarkMode: widget.isDarkMode,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFeaturedStripCard(
                              title: 'Oil, Ghee &\nMasala',
                              count: '+234',
                              img: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&fit=crop',
                              color: const Color(0xFFF3E5F5),
                              textColor: const Color(0xFF7B1FA2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFeaturedStripCard(
                              title: 'Drinks &\nJuices',
                              count: '',
                              img: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400&fit=crop',
                              color: const Color(0xFFE1F5FE),
                              textColor: const Color(0xFF0277BD),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFeaturedStripCard(
                              title: 'Dairy, Bread\n& Egg',
                              count: '',
                              img: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&fit=crop',
                              color: const Color(0xFFFFFDE7),
                              textColor: const Color(0xFFFBC02D),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFeaturedStripCard(
                              title: 'Atta, Rice\n& Dal',
                              count: '',
                              img: 'assets/images/Grau.jpg',
                              color: const Color(0xFFEFEBE9),
                              textColor: const Color(0xFF5D4037),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2D7A3E),
                      const Color(0xFF1F5A2F),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stock up on daily essentials',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Get farm-fresh goodness & a range of exotic fruits, vegetables, eggs & more',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Navigating to shop...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2D7A3E),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                            ),
                            child: const Text(
                              'Shop Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300&h=300&fit=crop',
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.agriculture,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.egg,
                                size: 32,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              Icon(
                                Icons.eco,
                                size: 32,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              Icon(
                                Icons.local_fire_department,
                                size: 32,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Three Promo Cards ──────────────────────────────
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Card 1: Pharmacy
                    _buildPromoCard(
                      title: 'Pharmacy at\nyour doorstep!',
                      subtitle: 'Cough syrups, pain\nrelief sprays & more',
                      buttonLabel: 'Order Now',
                      bgColor: const Color(0xFF1DC9A4),
                      icon: Icons.medical_services_rounded,
                      iconColor: Colors.white,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    // Card 2: Pet Care
                    _buildPromoCard(
                      title: 'Pet care supplies\nat your door',
                      subtitle: 'Food, treats, toys & more',
                      buttonLabel: 'Order Now',
                      bgColor: const Color(0xFFF5C842),
                      icon: Icons.pets_rounded,
                      iconColor: const Color(0xFF7B5E00),
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    // Card 3: Baby Care
                    _buildPromoCard(
                      title: 'No time for\na diaper run?',
                      subtitle: 'Get baby care essentials',
                      buttonLabel: 'Order Now',
                      bgColor: const Color(0xFFDDE8F5),
                      icon: Icons.child_care_rounded,
                      iconColor: const Color(0xFF2E6DA3),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Text(
                      'Welcome to Blinkite',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBagIllustration(
                          label: 'Left Bag',
                          color: const Color(0xFF39D2FF),
                          icon: Icons.shopping_bag,
                        ),
                        Column(
                          children: [
                            Container(
                              width: 130,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: widget.isDarkMode
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'this shop is best for you my sweet costomer',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF4F8EFE),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Grab your bag instantly',
                              style: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        _buildBagIllustration(
                          label: 'Right Bag',
                          color: const Color(0xFFFFB84D),
                          icon: Icons.shopping_bag_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // ── Category heading + See all ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategory == 'All' ? 'Browse Categories' : selectedCategory,
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: Color(0xFF27C93F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ── 9 Product cards – horizontal scroll ───────────
              Builder(builder: (context) {
                final catLabel = categories[_selectedCategoryIndex].label;
                final filtered = allProducts
                    .where((p) => catLabel == 'All' || p.category == catLabel)
                    .take(9)
                    .toList();

                // Fall back to 'All' products if category has no entries yet
                final productList = filtered.isNotEmpty
                    ? filtered
                    : allProducts.take(9).toList();

                return SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productList.length,
                    itemBuilder: (context, idx) {
                      final globalIdx = allProducts.indexOf(productList[idx]);
                      return Padding(
                        padding: EdgeInsets.only(
                          left: idx == 0 ? 0 : 10,
                          right: idx == productList.length - 1 ? 0 : 0,
                        ),
                        child: _buildProductCard(productList[idx], globalIdx),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 28),
              // ───────────────────────────────────────
              // DAIRY, BREAD & EGGS SECTION
              // ───────────────────────────────────────
              Builder(builder: (context) {
                final dairyProducts = allProducts
                    .where((p) => p.category == 'Dairy, Bread & Eggs')
                    .toList();
                
                final previewCount = dairyProducts.length > 9 ? 9 : dairyProducts.length;
                final totalItems = previewCount + 1;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Dairy, Bread & Eggs',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Fresh from farm to your door',
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white54 : Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: totalItems,
                        itemBuilder: (context, idx) {
                          if (idx == previewCount) {
                            return GestureDetector(
                              onTap: () async {
                                final updatedCart = await Navigator.push<Map<int, int>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AllProductsPage(
                                      title: 'Dairy, Bread & Eggs',
                                      allProducts: allProducts,
                                      categoryFilter: 'Dairy, Bread & Eggs',
                                      initialCart: Map.from(_productQty),
                                      isDarkMode: widget.isDarkMode,
                                    ),
                                  ),
                                );
                                if (updatedCart != null) {
                                  setState(() {
                                    _productQty.clear();
                                    _productQty.addAll(updatedCart);
                                  });
                                }
                              },
                              child: Container(
                                width: 140,
                                margin: const EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  color: widget.isDarkMode ? const Color(0xFF1A1B28) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: widget.isDarkMode ? Colors.white12 : Colors.black12, width: 1),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF27C93F).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.arrow_forward_ios, color: Color(0xFF27C93F), size: 20),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'See All\n${dairyProducts.length} Products',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final globalIdx = allProducts.indexOf(dairyProducts[idx]);
                          return Padding(
                            padding: EdgeInsets.only(left: idx == 0 ? 0 : 10),
                            child: _buildProductCard(dairyProducts[idx], globalIdx),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ]),
          ),
        ),
      ],
    ),
  ),
);
}

  // ── Product Card ─────────────────────────────────────────────
  Widget _buildProductCard(ProductItem product, int index) {
    final qty = _productQty[index] ?? 0;
    final bool isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1A1B28) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              product.imageUrl,
              width: 160,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 160,
                height: 120,
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: isDark ? Colors.white30 : Colors.black26,
                  size: 36,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery time badge
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.deliveryMins} MINS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Product name
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                // Size
                Text(
                  product.size,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 8),
                // Price + ADD button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.price,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    // ADD / quantity stepper
                    qty == 0
                        ? GestureDetector(
                            onTap: () => setState(() => _productQty[index] = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF27C93F),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ADD',
                                style: TextStyle(
                                  color: Color(0xFF27C93F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _qtyButton(
                                icon: Icons.remove,
                                onTap: () => setState(() {
                                  if ((_productQty[index] ?? 1) <= 1) {
                                    _productQty.remove(index);
                                  } else {
                                    _productQty[index] = (_productQty[index] ?? 1) - 1;
                                  }
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  '$qty',
                                  style: const TextStyle(
                                    color: Color(0xFF27C93F),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              _qtyButton(
                                icon: Icons.add,
                                onTap: () => setState(
                                    () => _productQty[index] = (qty) + 1),
                              ),
                            ],
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

  Widget _qtyButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFF27C93F),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildFeaturedStripCard({
    required String title,
    required String count,
    required String img,
    required Color color,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    final bool isDark = widget.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
      // Removed fixed width to allow Expanded to work
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F202D) : color,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isDark ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ] : [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: SizedBox(
              width: double.infinity,
              child: img.startsWith('assets/')
                  ? Image.asset(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: textColor.withOpacity(0.1),
                        child: Icon(Icons.shopping_basket_outlined, size: 40, color: textColor.withOpacity(0.5)),
                      ),
                    )
                  : Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: textColor.withOpacity(0.1),
                        child: Icon(Icons.shopping_basket_outlined, size: 40, color: textColor.withOpacity(0.5)),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (count.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildBagIllustration({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: color.withOpacity(0.16),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.28), width: 1.2),
          ),
          child: Icon(
            icon,
            color: color,
            size: 38,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Color bgColor,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final bool isDark = widget.isDarkMode;
    // Determine text color based on card brightness
    final bool isLightCard = bgColor.computeLuminance() > 0.5;
    final Color textColor = isLightCard ? const Color(0xFF1A1A1A) : Colors.white;
    final Color subtitleColor = isLightCard
        ? const Color(0xFF333333)
        : Colors.white.withOpacity(0.85);

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const Spacer(),
          // Order Now button
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: isLightCard
                    ? const Color(0xFF1A1A1A)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                buttonLabel,
                style: TextStyle(
                  color: isLightCard ? Colors.white : const Color(0xFF1A1A1A),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cartItems = _productQty.entries.where((e) => e.value > 0).toList();
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: widget.isDarkMode ? const Color(0xFF161726) : const Color(0xFFF5F7F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // --- Header ---
                  _buildModalHeader(context),
                  
                  // --- Content ---
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildDeliveryTimeCard(),
                          const SizedBox(height: 16),
                          _buildCartItemList(cartItems, setModalState),
                          const SizedBox(height: 16),
                          _buildBillDetails(),
                          const SizedBox(height: 16),
                          _buildDonationCard(setModalState),
                          const SizedBox(height: 16),
                          _buildTipSection(setModalState),
                          const SizedBox(height: 100), // Spacing for safe footer
                        ],
                      ),
                    ),
                  ),
                  
                  // --- Footer ---
                  _buildModalFooter(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF161726) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: widget.isDarkMode ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 8),
              Text(
                'My Cart',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF2D7A3E)),
            label: const Text(
              'Share',
              style: TextStyle(color: Color(0xFF2D7A3E), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer_outlined, color: Color(0xFFFFA500), size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery in 18 minutes',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Shipment of $totalCartItems items',
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemList(List<MapEntry<int, int>> cartItems, StateSetter setModalState) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cartItems.length,
        separatorBuilder: (context, index) => Divider(
          color: widget.isDarkMode ? Colors.white10 : Colors.black12,
          indent: 80,
        ),
        itemBuilder: (context, index) {
          final entry = cartItems[index];
          final product = allProducts[entry.key];
          final qty = entry.value;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 20,
                        color: widget.isDarkMode ? Colors.white38 : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        product.size,
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.price,
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D7A3E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_productQty[entry.key]! > 0) {
                              _productQty[entry.key] = _productQty[entry.key]! - 1;
                            }
                          });
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32),
                      ),
                      Text(
                        '$qty',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _productQty[entry.key] = (_productQty[entry.key] ?? 0) + 1;
                          });
                          setModalState(() {});
                        },
                        icon: const Icon(Icons.add, color: Colors.white, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildBillRow(Icons.description_outlined, 'Items total', '₹${itemsTotal.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _buildBillRow(Icons.delivery_dining_outlined, 'Delivery charge', '₹25', showInfo: true),
          const SizedBox(height: 12),
          _buildBillRow(Icons.shopping_bag_outlined, 'Handling charge', '₹2', showInfo: true),
          if (_selectedTip > 0) ...[
            const SizedBox(height: 12),
            _buildBillRow(Icons.volunteer_activism_outlined, 'Tip', '₹$_selectedTip'),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              Text(
                '₹${totalCartAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(IconData icon, String label, String value, {bool showInfo = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: widget.isDarkMode ? Colors.white70 : Colors.black54),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54)),
        if (showInfo) ...[
          const SizedBox(width: 4),
          Icon(Icons.info_outline, size: 14, color: widget.isDarkMode ? Colors.white38 : Colors.black38),
        ],
        const Spacer(),
        Text(value, style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)),
      ],
    );
  }

  Widget _buildDonationCard(StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Feeding India donation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Working towards a malnutrition free India.',
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Text('₹1', style: TextStyle(fontWeight: FontWeight.bold)),
              Checkbox(
                value: _isDonationEnabled,
                onChanged: (val) {
                  setState(() {
                    _isDonationEnabled = val ?? false;
                  });
                  setModalState(() {});
                },
                activeColor: const Color(0xFF2D7A3E),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipSection(StateSetter setModalState) {
    final tips = [20, 30, 50, 70];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tip your delivery partner',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: tips.map((tip) {
              final isSelected = _selectedTip == tip;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedTip = isSelected ? 0 : tip);
                  setModalState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2D7A3E) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2D7A3E) : Colors.black12,
                    ),
                  ),
                  child: Text(
                    '₹$tip',
                    style: TextStyle(
                      color: isSelected ? Colors.white : (widget.isDarkMode ? Colors.white : Colors.black),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModalFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF161726) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1D9B36),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context); // Close cart modal
              _showAddressSelection(); // Open address selection
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${totalCartAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'TOTAL',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    'Proceed to pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setAddressState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? const Color(0xFF161726) : const Color(0xFFF5F7F9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Delivery Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddAddressPage(isDarkMode: widget.isDarkMode),
                              ),
                            );
                            
                            if (result != null && result is Map<String, String>) {
                              setState(() {
                                _savedAddresses.add(result);
                                _selectedAddressIndex = _savedAddresses.length - 1;
                              });
                              // Re-open/update the sheet if needed, but since it's already open, setState works.
                              setAddressState(() {}); 
                            }
                          },
                          icon: const Icon(Icons.add, size: 18, color: Color(0xFF2D7A3E)),
                          label: const Text(
                            'Add New',
                            style: TextStyle(color: Color(0xFF2D7A3E), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _savedAddresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final addr = _savedAddresses[index];
                        final isSelected = _selectedAddressIndex == index;
                        
                        IconData addrIcon;
                        switch(addr['icon']) {
                          case 'home': addrIcon = Icons.home_rounded; break;
                          case 'work': addrIcon = Icons.work_rounded; break;
                          default: addrIcon = Icons.location_on_rounded;
                        }

                        return GestureDetector(
                          onTap: () {
                            setAddressState(() => _selectedAddressIndex = index);
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? (widget.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white)
                                : (widget.isDarkMode ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                  ? const Color(0xFF2D7A3E)
                                  : (widget.isDarkMode ? Colors.white10 : Colors.black12),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF2D7A3E).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    addrIcon,
                                    color: isSelected ? const Color(0xFF2D7A3E) : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        addr['type']!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isSelected ? (widget.isDarkMode ? Colors.white : Colors.black) : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        addr['address']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Color(0xFF2D7A3E)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close address modal
                          
                          // Prepare cart data for payment page
                          final List<Map<String, dynamic>> cartDetails = [];
                          _productQty.forEach((index, qty) {
                            if (qty > 0) {
                              final p = allProducts[index];
                              cartDetails.add({
                                'name': p.name,
                                'qty': qty,
                                'price': p.price.replaceAll('₹', '').trim(),
                              });
                            }
                          });

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => PaymentPage(
                                isDarkMode: widget.isDarkMode,
                                selectedAddress: _savedAddresses[_selectedAddressIndex]['address']!,
                                selectedAddressType: _savedAddresses[_selectedAddressIndex]['type']!,
                                totalAmount: totalCartAmount,
                                cartItems: cartDetails,
                              ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(0.0, 1.0);
                                const end = Offset.zero;
                                const curve = Curves.easeOutCubic;
                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                return SlideTransition(position: animation.drive(tween), child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 600),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D7A3E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Confirm and Pay',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  void _showAccountMenu(BuildContext context, RelativeRect position) {
    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      color: widget.isDarkMode ? const Color(0xFF1F202D) : Colors.white,
      items: <PopupMenuEntry>[
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                _userPhone,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        _buildPopupItem('My Orders', Icons.shopping_bag_outlined),
        _buildPopupItem('Saved Addresses', Icons.location_on_outlined),
        _buildPopupItem('Edit Profile', Icons.edit_outlined),
        _buildPopupItem('My Prescriptions', Icons.medical_services_outlined),
        _buildPopupItem('E-Gift Cards', Icons.card_giftcard),
        _buildPopupItem('FAQ\'s', Icons.help_outline),
        _buildPopupItem('Account Privacy', Icons.privacy_tip_outlined),
        _buildPopupItem('Log Out', Icons.logout, color: Colors.redAccent),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.white,
                  child: Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=60x60&data=BlinkiteApp',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Simple way to get groceries',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'at your doorstep',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Scan the QR code and download blinkit app',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'Edit Profile') {
        _editProfile();
      }
    });
  }

  Widget _buildMoreCategoryItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showMoreCategories = true;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                border: Border.all(
                  color: widget.isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.more_horiz,
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 75,
              child: Text(
                'More',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final phoneController = TextEditingController(text: _userPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1F202D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildEditField('Name', nameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildEditField('Email', emailController, Icons.email_outlined),
            const SizedBox(height: 16),
            _buildEditField('Phone Number', phoneController, Icons.phone_outlined),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _userName = nameController.text;
                    _userEmail = emailController.text;
                    _userPhone = phoneController.text;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D7A3E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.isDarkMode ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: widget.isDarkMode ? Colors.white54 : Colors.black45),
            filled: true,
            fillColor: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  PopupMenuItem _buildPopupItem(String title, IconData icon, {Color? color}) {
    return PopupMenuItem(
      value: title,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? (widget.isDarkMode ? Colors.white70 : Colors.black54)),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color ?? (widget.isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}


class ProductScreen extends StatelessWidget {
  final String categoryName;
  final bool isDarkMode;

  const ProductScreen({super.key, required this.categoryName, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    List<Product> products = categoryProducts[categoryName] ?? [];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF090A12) : const Color(0xFFF4F4F8),
      appBar: AppBar(
        title: Text(
          categoryName,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF0D0E17) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: products.isEmpty 
        ? Center(
            child: Text(
              'No products found in this category',
              style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black45),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              final product = products[index];

              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1A1B28) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: product.image.startsWith('http')
                            ? Image.network(product.image, fit: BoxFit.cover, width: double.infinity)
                            : Image.asset(product.image, fit: BoxFit.cover, width: double.infinity),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${product.price}",
                        style: const TextStyle(
                          color: Color(0xFF27C93F),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${product.name} added to cart"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27C93F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ALL PRODUCTS PAGE — opens when user taps "See all" card
// ═══════════════════════════════════════════════════════════════════════
class AllProductsPage extends StatefulWidget {
  final String title;
  final List<ProductItem> allProducts;
  final String categoryFilter;
  final Map<int, int> initialCart;
  final bool isDarkMode;

  const AllProductsPage({
    super.key,
    required this.title,
    required this.allProducts,
    required this.categoryFilter,
    required this.initialCart,
    required this.isDarkMode,
  });

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  late Map<int, int> _qty;
  late List<ProductItem> filteredProducts;

  @override
  void initState() {
    super.initState();
    _qty = Map.from(widget.initialCart);
    filteredProducts = widget.allProducts
        .where((p) => widget.categoryFilter == 'All' || p.category == widget.categoryFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090A12) : const Color(0xFFF4F4F8),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context, _qty),
        ),
        backgroundColor: isDark ? const Color(0xFF0D0E17) : Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          Navigator.pop(context, _qty);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF27C93F).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF27C93F).withOpacity(0.3)),
                ),
                child: Text(
                  '${filteredProducts.length} products',
                  style: const TextStyle(
                    color: Color(0xFF27C93F),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, idx) =>
                      _buildGridCard(filteredProducts[idx]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(ProductItem product) {
    final globalIdx = widget.allProducts.indexOf(product);
    final qty = _qty[globalIdx] ?? 0;
    final bool isDark = widget.isDarkMode;
    final cardBg = isDark ? const Color(0xFF1A1B28) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.black.withOpacity(0.07);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              product.imageUrl,
              width: double.infinity,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 130,
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.grey.shade100,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: isDark ? Colors.white24 : Colors.black26,
                  size: 32,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 12,
                        color: isDark ? Colors.white54 : Colors.black45),
                    const SizedBox(width: 3),
                    Text('${product.deliveryMins} MINS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : Colors.black45,
                        )),
                  ],
                ),
                const SizedBox(height: 4),
                Text(product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.25,
                    )),
                const SizedBox(height: 2),
                Text(product.size,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white38 : Colors.black38,
                    )),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product.price,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        )),
                    qty == 0
                        ? GestureDetector(
                            onTap: () => setState(() => _qty[globalIdx] = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF27C93F), width: 1.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('ADD',
                                  style: TextStyle(
                                    color: Color(0xFF27C93F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  )),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _btn(
                                icon: Icons.remove,
                                onTap: () => setState(() {
                                  if ((_qty[globalIdx] ?? 1) <= 1) {
                                    _qty.remove(globalIdx);
                                  } else {
                                    _qty[globalIdx] = (_qty[globalIdx] ?? 1) - 1;
                                  }
                                }),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Text('$qty',
                                    style: const TextStyle(
                                      color: Color(0xFF27C93F),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    )),
                              ),
                              _btn(
                                icon: Icons.add,
                                onTap: () =>
                                    setState(() => _qty[globalIdx] = qty + 1),
                              ),
                            ],
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

  Widget _btn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF27C93F),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isDarkMode;
  final String address;
  final String userName;
  final TextEditingController searchController;
  final int placeholderIndex;
  final List<String> placeholderNames;
  final VoidCallback onSearchChanged;
  final VoidCallback onThemeToggle;
  final int totalCartItems;
  final double itemsTotal;
  final VoidCallback onCartTap;
  final Function(BuildContext, RelativeRect) onAccountTap;

  _SearchHeaderDelegate({
    required this.isDarkMode,
    required this.address,
    required this.userName,
    required this.searchController,
    required this.placeholderIndex,
    required this.placeholderNames,
    required this.onSearchChanged,
    required this.onThemeToggle,
    required this.totalCartItems,
    required this.itemsTotal,
    required this.onCartTap,
    required this.onAccountTap,
  });

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 150;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0, 1.0);
    final double width = MediaQuery.of(context).size.width;
    
    final Color bgColor = isDarkMode 
      ? const Color(0xFF0D0E17).withOpacity(0.98) 
      : Colors.white.withOpacity(0.98);

    // Layout values
    // Logo
    double logoSize = 34 + (1 - progress) * 10;
    double logoLeft = 16;
    double logoTop = 12 + (progress * 4);

    // Address area
    double addressLeft = logoLeft + logoSize + 8;
    double addressTop = logoTop - 2;
    double addressWidth = progress > 0.5 ? 120 : (width - addressLeft - 100);

    // Search Bar
    double searchTop = progress > 0.6 
        ? logoTop - 2 // Move up beside address
        : 65 - (progress * 5); // Staying below
    
    double searchLeft = progress > 0.6 
        ? addressLeft + addressWidth + 10 
        : 16;
        
    double searchRight = progress > 0.6 
        ? 160 // Leave room for Toggle, Account Icon and Name
        : 16;

    // Actions (Cart, Theme)
    double actionsOpacity = (1 - progress * 2).clamp(0, 1);

    return Container(
      color: bgColor,
      child: Stack(
        children: [
          // 1. Logo
          Positioned(
            left: logoLeft,
            top: logoTop,
            child: KBLogo(size: logoSize),
          ),

          // 2. Address & Delivery Text
          Positioned(
            left: addressLeft,
            top: addressTop,
            width: addressWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (progress < 0.3)
                  Opacity(
                    opacity: (1 - progress * 3.3).clamp(0, 1),
                    child: Text(
                      'Delivery in 15-20 mins',
                      style: TextStyle(
                        color: isDarkMode ? const Color(0xFF27C93F) : const Color(0xFF1B5E20),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 12 + (1 - progress) * 2,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3 & 4 Combined: Header Row (Beside Address) for Collapsed State
          if (progress > 0.6)
            Positioned(
              left: searchLeft,
              right: 16,
              top: logoTop - 2,
              height: 38,
              child: Row(
                children: [
                  // Search Bar (Taking ~70% as requested reduction)
                  Expanded(
                    flex: 70,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          TextField(
                            controller: searchController,
                            onChanged: (_) => onSearchChanged(),
                            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: '',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search,
                                size: 16,
                                color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ),
                          if (searchController.text.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: IgnorePointer(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  child: Text(
                                    placeholderNames[placeholderIndex],
                                    key: ValueKey<int>(placeholderIndex),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Cart Pill
                  GestureDetector(
                    onTap: onCartTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: totalCartItems > 0 
                          ? const Color(0xFF27C93F) 
                          : (isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: totalCartItems > 0 
                            ? const Color(0xFF27C93F) 
                            : (isDarkMode ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined, 
                            color: totalCartItems > 0 ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black54), 
                            size: 14,
                          ),
                          if (totalCartItems > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '$totalCartItems',
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 11, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Account Icon
                  GestureDetector(
                    onTapDown: (details) {
                      final pos = RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        details.globalPosition.dx,
                        details.globalPosition.dy
                      );
                      onAccountTap(context, pos);
                    },
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: isDarkMode ? Colors.white10 : Colors.black12,
                      child: Icon(Icons.person_outline, size: 16, color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Theme Toggle (Mood) - At the end
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      size: 20,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: onThemeToggle,
                  ),
                ],
              ),
            ),

          // Search Bar for Expanded State
          if (progress <= 0.6)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: 16,
              right: 16,
              top: 65 - (progress * 5),
              height: 38,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (_) => onSearchChanged(),
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: '',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          size: 16,
                          color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                    if (searchController.text.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: IgnorePointer(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              placeholderNames[placeholderIndex],
                              key: ValueKey<int>(placeholderIndex),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Top Header Icons for Expanded State
          if (progress <= 0.6)
            Positioned(
              right: 12,
              top: logoTop + 2,
              child: Opacity(
                opacity: (1 - progress * 2).clamp(0, 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cart
                    if (totalCartItems > 0) ...[
                      GestureDetector(
                        onTap: onCartTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF27C93F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '$totalCartItems',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    // Theme Toggle
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        size: 20,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onPressed: onThemeToggle,
                    ),
                    const SizedBox(width: 16),
                    
                    // Account Icon
                    GestureDetector(
                      onTapDown: (details) {
                        final pos = RelativeRect.fromLTRB(
                          details.globalPosition.dx,
                          details.globalPosition.dy,
                          details.globalPosition.dx,
                          details.globalPosition.dy
                        );
                        onAccountTap(context, pos);
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: isDarkMode ? Colors.white10 : Colors.black12,
                        child: Icon(Icons.person_outline, size: 16, color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) {
    return oldDelegate.placeholderIndex != placeholderIndex || 
           oldDelegate.isDarkMode != isDarkMode || 
           oldDelegate.address != address ||
           oldDelegate.totalCartItems != totalCartItems ||
           oldDelegate.searchController.text != searchController.text;
  }
}
