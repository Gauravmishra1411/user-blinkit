import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './add_address_page.dart';
import './payment_page.dart';
import './orders_page.dart';
import './login_page.dart';
import '../widgets/kb_logo.dart';
import './blog_page.dart';
import './shoes_page.dart';
import './bags_page.dart';
import './about_page.dart';

// Unified models are now imported or defined below.
// Removed hardcoded categoryProducts map.

class CategoryItem {
  final String label;
  final String imageUrl;
  final Color color;

  CategoryItem({required this.label, required this.imageUrl, required this.color});
}

class ProductItem {
  final String id;
  final String name;
  final String size;
  final String price;
  final String deliveryMins;
  final String imageUrl;
  final List<String> images;
  final String category;
  final bool isRecent;
  final double rating;

  ProductItem({
    required this.id,
    required this.name,
    required this.size,
    required this.price,
    required this.deliveryMins,
    required this.imageUrl,
    List<String>? images,
    required this.category,
    this.isRecent = false,
    this.rating = 4.5,
  }) : this.images = images ?? [imageUrl];
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

class _AddressPageState extends State<AddressPage> with SingleTickerProviderStateMixin {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  String _address = 'Gaur city center';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  List<ProductItem> allProducts = [];
  List<ProductItem> recentlyAddedProducts = [];
  StreamSubscription? _productSubscription;
  StreamSubscription? _categorySubscription;
  StreamSubscription? _bannerSubscription;
  late ScrollController _mainScrollController;
  late ScrollController _categoryScrollController;
  double _scrollOffset = 0;

  List<CategoryItem> categories = [];

  final List<ProductItem> _fallbackProducts = [
    ProductItem(
      id: 'fb1',
      name: 'Fresh Milk',
      size: '500ml',
      price: '₹35',
      deliveryMins: '15-20',
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&fit=crop',
      category: 'Dairy, Bread & Eggs',
    ),
    ProductItem(
      id: 'fb2',
      name: 'Organic Tomatoes',
      size: '500g',
      price: '₹45',
      deliveryMins: '15-20',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&fit=crop',
      category: 'Fruits & Vegetables',
    ),
    ProductItem(
      id: 'fb3',
      name: 'Cold Coffee',
      size: '200ml',
      price: '₹60',
      deliveryMins: '15-20',
      imageUrl: 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400&fit=crop',
      category: 'Cold Drinks & Juices',
    ),
    ProductItem(
      id: 'fb4',
      name: 'Potato Chips',
      size: '100g',
      price: '₹20',
      deliveryMins: '15-20',
      imageUrl: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&fit=crop',
      category: 'Snacks & Munchies',
    ),
  ];
  List<String> _recentlyViewedIndices = []; // To track recently viewed products ID

  Map<String, int> _productQty = {}; // productId -> qty

  final NotificationService _notificationService = NotificationService();
  int _unreadNotificationsCount = 0;
  List<NotificationItem> _notifications = [];

  int _selectedTip = 0;
  int _selectedAddressIndex = 0;
  String _userName = 'User';
  String _userEmail = '';
  String _userId = '';
  String _userPhone = '7360842275';
  bool _showMoreCategories = false;
  bool _isDonationEnabled = false;
  Set<String> _favoriteProductIds = {};


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

  List<Map<String, String>> foodData = [
    {
      "title": "Non-boring recipes",
      "subtitle": "from the chef's chef",
      "offer": "FREE BOOK",
      "img": "https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&fit=crop",
    },
  ];

  int _currentBannerIndex = 0;
  late PageController _bannerController;
  Timer? _bannerTimer;

  double get itemsTotal {
    double total = 0;
    _productQty.forEach((id, qty) {
      // Find product in either allProducts or recentlyAddedProducts or fallback
      ProductItem? product;
      try {
        product = allProducts.firstWhere((p) => p.id == id);
      } catch (_) {
        try {
          product = recentlyAddedProducts.firstWhere((p) => p.id == id);
        } catch (_) {
           // If still not found, check fallback
           try {
             product = _fallbackProducts.firstWhere((p) => p.id == id);
           } catch (_) {}
        }
      }
      
      if (product != null) {
        final priceStr = product.price.replaceAll(RegExp(r'[^0-9.]'), '');
        final price = double.tryParse(priceStr) ?? 0;
        total += price * qty;
      }
    });
    return total;
  }


  double get totalCartAmount => itemsTotal + 25 + 2 + (_isDonationEnabled ? 1 : 0) + _selectedTip;

  int get totalCartItems => _productQty.values.fold(0, (sum, val) => sum + val);


  @override
  void initState() {
    super.initState();
    _categoryScrollController = ScrollController();
    _mainScrollController = ScrollController();
    
    // Initialize FCM
    _notificationService.initializeFCM();

    // Notifications Listener
    _notificationService.getNotifications().listen((notifs) {
      if (mounted) {
        setState(() {
          _notifications = notifs;
          _unreadNotificationsCount = notifs.where((n) => !n.isRead).length;
        });
      }
    }, onError: (e) {
      debugPrint('Notification Listener Error: $e');
    });

    // Load actual user info
    _loadUserInfo();

    _mainScrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _mainScrollController.offset;
        });
      }
    });

    _bannerController = PageController(initialPage: 501);
    _startBannerTimer();
    _startPlaceholderTimer();
    
    allProducts = List.from(_fallbackProducts);
    _listenToProducts();
    _listenToCategories();
    _listenToBanners();
    _loadRecentlyViewed();
    _loadFavorites();
    _notificationService.initializeFCM();
  }

  void _loadUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
        _userEmail = user.email ?? '';
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('favorite_products');
    if (stored != null) {
      setState(() {
        _favoriteProductIds = stored.toSet();
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_products', _favoriteProductIds.toList());
  }

  void _toggleFavorite(String productId) {
    setState(() {
      if (_favoriteProductIds.contains(productId)) {
        _favoriteProductIds.remove(productId);
      } else {
        _favoriteProductIds.add(productId);
      }
    });
    _saveFavorites();
  }

  Future<void> _loadRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('recently_viewed');
    if (stored != null) {
      setState(() {
        _recentlyViewedIndices = stored;

      });
    }
  }

  Future<void> _saveRecentlyViewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recently_viewed', _recentlyViewedIndices);

  }

  void _listenToProducts() {
    _productSubscription = FirebaseFirestore.instance
        .collection('product')
        .snapshots()
        .listen((snapshot) {
      DateTime parseDateTime(dynamic value) {
        if (value is Timestamp) return value.toDate();
        if (value is String) return DateTime.tryParse(value) ?? DateTime(1970);
        return DateTime(1970);
      }
      
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          final List<Map<String, dynamic>> docsWithData = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // Filter by visibility and sort by createdAt
          docsWithData.removeWhere((data) => data['isVisible'] == false);
          
          docsWithData.sort((a, b) {
            final aTime = parseDateTime(a['createdAt']);
            final bTime = parseDateTime(b['createdAt']);
            return bTime.compareTo(aTime); // Descending
          });

          allProducts = docsWithData.map((data) {
            final List<dynamic> gallery = data['gallery'] ?? [];
            final String mainImg = data['imageUrl'] ?? data['mainImage'] ?? '';
            final List<String> images = gallery.isNotEmpty 
                ? gallery.map((e) => e.toString()).toList() 
                : (mainImg.isNotEmpty ? [mainImg] : []);
            
            final List<dynamic> sizes = data['selectedSizes'] ?? [];
            final String sizeStr = sizes.isNotEmpty ? sizes.first.toString() : 'Regular';

            return ProductItem(
              id: data['id'] ?? data['title'] ?? data['name'] ?? '',
              name: data['title'] ?? data['name'] ?? 'Unnamed Product',
              size: sizeStr,
              price: '₹${data['price'] ?? data['mrp'] ?? '0'}',
              deliveryMins: '15-20',
              imageUrl: mainImg,
              category: data['category'] ?? 'All',
              images: images,
              isRecent: data['isRecent'] == true,
              rating: double.tryParse(data['rating']?.toString() ?? '4.5') ?? 4.5,
            );
          }).toList();

          final List<Map<String, dynamic>> recentDocs = docsWithData
              .where((data) => data['isRecent'] == true)
              .toList();

          recentDocs.sort((a, b) {
            final aTime = parseDateTime(a['recentAddedAt'] ?? a['createdAt']);
            final bTime = parseDateTime(b['recentAddedAt'] ?? b['createdAt']);
            return bTime.compareTo(aTime); // Descending
          });

          final List<ProductItem> recentlyAddedItems = recentDocs.map((data) {
                final List<dynamic> gallery = data['gallery'] ?? [];
                final String mainImg = data['imageUrl'] ?? data['mainImage'] ?? '';
                final List<String> images = gallery.isNotEmpty 
                    ? gallery.map((e) => e.toString()).toList() 
                    : (mainImg.isNotEmpty ? [mainImg] : []);
                
                final List<dynamic> sizes = data['selectedSizes'] ?? [];
                final String sizeStr = sizes.isNotEmpty ? sizes.first.toString() : 'Regular';

                return ProductItem(
                  id: data['id'] ?? data['title'] ?? data['name'] ?? '',
                  name: data['title'] ?? data['name'] ?? 'Unnamed Product',
                  size: sizeStr,
                  price: '₹${data['price'] ?? data['mrp'] ?? '0'}',
                  deliveryMins: '15-20',
                  imageUrl: mainImg,
                  category: data['category'] ?? 'All',
                  images: images,
                  isRecent: true,
                  rating: double.tryParse(data['rating']?.toString() ?? '4.5') ?? 4.5,
                );
              }).toList();
          
          setState(() {
            recentlyAddedProducts = recentlyAddedItems;
          });
          
          if (allProducts.isEmpty) {
            allProducts = List.from(_fallbackProducts);
          }
        });
      }
    });
  }

  void _listenToBanners() {
    _bannerSubscription = FirebaseFirestore.instance
        .collection('banners')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        // Filter active banners locally to avoid needing complex Firestore indices immediately
        final activeDocs = snapshot.docs.where((doc) {
          final data = doc.data();
          return data['isActive'] == true;
        }).toList();

        if (activeDocs.isNotEmpty) {
          setState(() {
            foodData = activeDocs.map((doc) {
              final data = doc.data();
              return {
                "title": data['title']?.toString() ?? 'Special Offer',
                "subtitle": data['subtitle']?.toString() ?? 'Limited time only',
                "offer": data['offer']?.toString() ?? 'Deal',
                "img": data['img']?.toString() ?? '',
              };
            }).toList();
          });
        }
      }
    }, onError: (e) => debugPrint('Banner Stream Error: $e'));
  }

  void _listenToCategories() {
    _categorySubscription = FirebaseFirestore.instance
        .collection('categories')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        debugPrint('Fetched ${snapshot.docs.length} dynamic categories from Firestore');
        setState(() {
          final dynamicCategories = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final colorStr = (data['color'] as String? ?? '').trim();
            final label = (data['label'] as String? ?? 'Unknown').trim();
            
            Color categoryColor;
            try {
              if (colorStr.isEmpty) {
                categoryColor = const Color(0xFFE8F5E9);
              } else if (colorStr.startsWith('#')) {
                // Handle #RRGGBB or #AARRGGBB
                String hex = colorStr.replaceFirst('#', '');
                if (hex.length == 6) hex = 'FF' + hex;
                categoryColor = Color(int.parse('0x' + hex));
              } else if (colorStr.startsWith('0x') || colorStr.startsWith('0X')) {
                categoryColor = Color(int.parse(colorStr));
              } else {
                // Assume it's a raw hex string RRGGBB
                String hex = colorStr;
                if (hex.length == 6) hex = 'FF' + hex;
                categoryColor = Color(int.parse('0x' + hex));
              }
            } catch (e) {
              debugPrint('Error parsing color $colorStr for category $label: $e');
              categoryColor = const Color(0xFFE8F5E9);
            }

            return CategoryItem(
              label: label.isEmpty ? 'Unknown' : label,
              imageUrl: data['imageUrl'] ?? '',
              color: categoryColor,
            );
          }).toList();

          // Show only dynamic categories
          categories = dynamicCategories;
          
          // Deduplicate based on label (case-insensitive)
          final seen = <String>{};
          categories = categories.where((c) => seen.add(c.label.toLowerCase().trim())).toList();
          debugPrint('Total categories after merge: ${categories.length}');
        });
      }
    });
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
    _productSubscription?.cancel();
    _categorySubscription?.cancel();
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
    String selectedCategory = 'All';
    if (categories.isNotEmpty) {
      if (_selectedCategoryIndex >= categories.length) {
        _selectedCategoryIndex = 0;
      }
      selectedCategory = categories[_selectedCategoryIndex].label;
    }

    return Scaffold(
      appBar: null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
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
                isDarkMode: isDark,
                address: _address,
                userName: _userName,
                searchController: _searchController,
                placeholderIndex: _placeholderIndex,
                placeholderNames: _placeholderNames,
                onSearchChanged: () => setState(() {}),
                onThemeToggle: widget.onThemeToggle,
                totalCartItems: totalCartItems,
                itemsTotal: itemsTotal,
                unreadNotificationsCount: _unreadNotificationsCount,
                onCartTap: _showCartModal,
                onAccountTap: (ctx, pos) => _showAccountMenu(ctx, pos),
                onNotificationTap: _showNotificationsOverlay,
              ),

            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_searchController.text.isNotEmpty) ..._buildSearchResults(),
                  if (_searchController.text.isEmpty) ..._buildRecentlyViewedSection(),
                  const SizedBox(height: 20),
                  _buildStaticAdBanner(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Shop by Category'),
                  const SizedBox(height: 12),
                  _buildCategoryGrid(),
                  const SizedBox(height: 32),
                  if (recentlyAddedProducts.isNotEmpty) ...[
                    _buildSectionHeader('Recently Added'),
                    const SizedBox(height: 16),
                    _buildRecentlyAddedSection(),
                    const SizedBox(height: 32),
                  ],
                  const SizedBox(height: 32),
                  _buildSectionHeader('Handpicked for You'),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 230, // Increased to 230 for a larger, more premium look
                    child: PageView.builder(
                      controller: _bannerController,
                      itemCount: foodData.isEmpty ? 1 : 10000, 
                      onPageChanged: (index) => setState(() => _currentBannerIndex = index % (foodData.isEmpty ? 1 : foodData.length)),
                      itemBuilder: (context, index) {
                        if (foodData.isEmpty) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black12,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }
                        final item = foodData[index % foodData.length];
                        final bool isCurrent = _currentBannerIndex == (index % foodData.length);
                        
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          margin: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: isCurrent ? 0 : 8, // Subtle vertical shrink for inactive
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isCurrent ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ] : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                // Stronger 50% Zoom-Out Effect
                                AnimatedScale(
                                  scale: isCurrent ? 1.0 : 1.5,
                                  duration: const Duration(milliseconds: 1500),
                                  curve: Curves.easeOutQuart,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: item["img"]!.startsWith('assets/')
                                            ? AssetImage(item["img"]!) as ImageProvider
                                            : NetworkImage(item["img"]!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.transparent
                                      ],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 25,
                                  left: 25,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["title"]!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item["subtitle"]!,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${item["offer"]!}% OFF',
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
                                  : (isDark ? Colors.white24 : Colors.black12),
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
                                  builder: (context) => AllProductsPage(
                                    title: "Fruits & Vegetables",
                                    allProducts: allProducts,
                                    categoryFilter: "Fruits & Vegetables",
                                    initialCart: Map.from(_productQty),
                                    isDarkMode: isDark,
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
                                  builder: (context) => AllProductsPage(
                                    title: "Snacks & Munchies",
                                    allProducts: allProducts,
                                    categoryFilter: "Snacks & Munchies",
                                    initialCart: Map.from(_productQty),
                                    isDarkMode: isDark,
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
                  // ── DYNAMIC CATEGORY PRODUCT ROWS ──────────────────
                  ..._buildCategoryProductSections(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Support Daily Essentials'),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2D7A3E), Color(0xFF1F5A2F)],
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
                                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Get farm-fresh goodness & a range of exotic fruits, vegetables, eggs & more',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF2D7A3E),
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: const Text('Shop Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Text(
                      'Welcome to Blinkite',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
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
                                color: isDark
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
                                color: isDark
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
                      color: isDark ? Colors.white : Colors.black,
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
                final catLabel = categories.isNotEmpty ? categories[_selectedCategoryIndex].label : 'All';
                final filtered = allProducts
                    .where((p) => (catLabel == 'All' || p.category == catLabel) && !p.isRecent)
                    .take(9)
                    .toList();

                // Fall back to 'All' products if category has no entries yet
                final productList = filtered.isNotEmpty
                    ? filtered
                    : allProducts.take(9).toList();

                return SizedBox(
                  height: 300,
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
                    .where((p) => p.category == 'Dairy, Bread & Eggs' && !p.isRecent)
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
                            color: isDark ? Colors.white : Colors.black,
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
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: totalItems,
                        itemBuilder: (context, idx) {
                          if (idx == previewCount) {
                            return GestureDetector(
                              onTap: () async {
                                final updatedCart = await Navigator.push<Map<String, int>>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AllProductsPage(
                                      title: 'Dairy, Bread & Eggs',
                                      allProducts: allProducts,
                                      categoryFilter: 'Dairy, Bread & Eggs',
                                      initialCart: Map.from(_productQty),
                                      isDarkMode: isDark,
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
                                  color: isDark ? const Color(0xFF1A1B28) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 1),
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
                                        color: isDark ? Colors.white : Colors.black87,
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
              const SizedBox(height: 60),
              
              _buildPromotionBanners(),
              
              const SizedBox(height: 20),

              // ── DYNAMIC CATEGORY SECTIONS ───────────────────────
              ..._buildCategoryProductSections(),
              
              const SizedBox(height: 60),

              _FeaturedProductsSection(
                allProducts: allProducts,
                newArrivalProducts: recentlyAddedProducts,
                favoriteProductIds: _favoriteProductIds,
                onFavoriteToggle: _toggleFavorite,
                onAddToCart: (id) => setState(() =>
                    _productQty[id] = (_productQty[id] ?? 0) + 1),
                onShowDetail: (product, idx) => _showProductDetail(product, idx),
                productQty: _productQty,
                isDark: isDark,
              ),

              
              const SizedBox(height: 60),

              // ── FOOTER SECTION ──────────────────────────────────
              _buildFooter(),
            ]),
          ),
        ),
      ],
    ),
  ),
);
}

  // ── Product Card ─────────────────────────────────────────────
  Widget _buildProductCard(ProductItem product, [int? index]) {
    final qty = _productQty[product.id] ?? 0;


    // Forced white background as per user request
    const cardBg = Colors.white;
    const borderColor = Color(0xFFF1F1F1);
    
    // Use dark text colors since background is white
    const primaryTextColor = Colors.black;
    const secondaryTextColor = Colors.black54;
    const tertiaryTextColor = Colors.black38;

    return GestureDetector(
      onTap: () => _showProductDetail(product, index),
      child: Container(
        width: 170,
        height: 280,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.black12,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _favoriteProductIds.contains(product.id) ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: _favoriteProductIds.contains(product.id) ? Colors.red : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Delivery time badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 11,
                          color: Colors.black87,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.deliveryMins} MINS',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 10, color: Colors.black12),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 11, color: Color(0xFFFFB300)),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Product name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Size
                  Text(
                    product.size,
                    style: const TextStyle(
                      fontSize: 12,
                      color: tertiaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Price + ADD button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.price,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: primaryTextColor,
                        ),
                      ),
                      // ADD / quantity stepper
                      qty == 0
                          ? GestureDetector(
                              onTap: () => setState(() => _productQty[product.id] = 1),

                              child: Container(
                                width: 64,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FFF9),
                                  border: Border.all(
                                    color: const Color(0xFF27C93F),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'ADD',
                                    style: TextStyle(
                                      color: Color(0xFF27C93F),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF27C93F),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _qtyButtonMinimal(
                                    icon: Icons.remove,
                                    onTap: () => setState(() {
                                      if ((_productQty[product.id] ?? 1) <= 1) {
                                        _productQty.remove(product.id);
                                      } else {
                                        _productQty[product.id] = (_productQty[product.id] ?? 1) - 1;
                                      }
                                    }),

                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      '$qty',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  _qtyButtonMinimal(
                                    icon: Icons.add,
                                    onTap: () => setState(
                                        () => _productQty[product.id] = (qty) + 1),
                                  ),

                                ],
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyButtonMinimal({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }

  Widget _buildStaticAdBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFFFF512F), const Color(0xFFDD2476)] 
              : [const Color(0xFFFF8008), const Color(0xFFFFC837)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.redAccent : Colors.orangeAccent).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'LIMITED TIME OFFER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Up to 50% OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'on Premium Jackets & Bags',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Shop Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Product Detail Card ──────────────────────────────────────
  void _showProductDetail(ProductItem product, [int? index]) {

    
    // Add to recently viewed if not already at the front
    setState(() {
      final String id = product.id;
      _recentlyViewedIndices.remove(id);
      _recentlyViewedIndices.insert(0, id);
      if (_recentlyViewedIndices.length > 10) {
        _recentlyViewedIndices.removeLast();
      }
    });

    _saveRecentlyViewed();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final bool isFavorite = _favoriteProductIds.contains(product.id);
          final int qty = _productQty[product.id] ?? 0;

          final PageController pageController = PageController();
          
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: 350, // Roughly 3.5 inches equivalent width
              height: 580, // Roughly 7 inches equivalent height
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  children: [
                    // Top Image Stack
                    Stack(
                      children: [
                        SizedBox(
                          height: 300,
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: product.images.length,
                            itemBuilder: (context, i) => Image.network(
                              product.images[i],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Close Button
                        Positioned(
                          top: 16,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withOpacity(0.4),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        // Favorite Button
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              _toggleFavorite(product.id);
                              setDialogState(() {}); // Update local dialog state
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        // Image Indicator
                        if (product.images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${product.images.length} Images',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Product Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Fresh',
                                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.size,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Premium quality item sourced directly for your convenience. Hand-picked and guaranteed fresh upon delivery.',
                              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                            ),
                            const Spacer(),
                            // Bottom Action Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('MRP', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    Text(
                                      product.price,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                // Add Button
                                qty == 0
                                  ? ElevatedButton(
                                      onPressed: () {
                                        setState(() => _productQty[product.id] = 1);

                                        setDialogState(() {});
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF27C93F),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 0,
                                      ),
                                      child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.w900)),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF27C93F),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          _qtyButton(
                                            icon: Icons.remove,
                                            onTap: () {
                                              setState(() {
                                                if ((_productQty[product.id] ?? 1) <= 1) {
                                                  _productQty.remove(product.id);
                                                } else {
                                                  _productQty[product.id] = (_productQty[product.id] ?? 1) - 1;
                                                }
                                              });
                                              setDialogState(() {});

                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              '$qty',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                                            ),
                                          ),
                                          _qtyButton(
                                            icon: Icons.add,
                                            onTap: () {
                                              setState(() => _productQty[product.id] = (qty) + 1);
                                              setDialogState(() {});
                                            },

                                          ),
                                        ],
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
            ),
          );
        },
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
            color: isDark ? Colors.white70 : Colors.black54,
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

  void _showNotificationsOverlay() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161722) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: StreamBuilder<List<NotificationItem>>(
          stream: _notificationService.getNotifications(),
          builder: (context, snapshot) {
            final notifications = snapshot.data ?? [];
            final unreadCount = notifications.where((n) => !n.isRead).length;

            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          if (unreadCount > 0)
                            Text(
                              '$unreadCount unread messages',
                              style: const TextStyle(color: Color(0xFF27C93F), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          if (unreadCount > 0)
                            TextButton(
                              onPressed: () => _notificationService.markAllAsRead(),
                              child: const Text('Mark all as read', style: TextStyle(fontSize: 12)),
                            ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // List
                Expanded(
                  child: notifications.isEmpty
                      ? _buildEmptyNotifications()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _buildNotificationTile(notification, (fn) => fn()); // Dummy state setter
                          },
                        ),
                ),
                
                // Footer
                if (notifications.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _notificationService.clearAll(),
                        child: const Text('Clear All Notifications', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: isDark ? Colors.white24 : Colors.black12),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'We will notify you about your orders and offers!',
            style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem notification, StateSetter setModalState) {
    IconData icon;
    Color iconColor;
    
    switch (notification.type) {
      case 'order':
        icon = Icons.shopping_bag_outlined;
        iconColor = Colors.orange;
        break;
      case 'offer':
        icon = Icons.local_offer_outlined;
        iconColor = Colors.redAccent;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = const Color(0xFF27C93F);
    }

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          _notificationService.markAsRead(notification.id);
          setModalState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02))
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.blue.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead 
              ? null 
              : Border.all(color: const Color(0xFF27C93F).withOpacity(0.3)),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        _formatDate(notification.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF27C93F),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}';
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
                color: isDark ? const Color(0xFF161726) : const Color(0xFFF5F7F9),
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
        color: isDark ? const Color(0xFF161726) : Colors.white,
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
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 8),
              Text(
                'My Cart',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
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
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
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
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Shipment of $totalCartItems items',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemList(List<MapEntry<String, int>> cartItems, StateSetter setModalState) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cartItems.length,
        separatorBuilder: (context, index) => Divider(
          color: isDark ? Colors.white10 : Colors.black12,
          indent: 80,
        ),
        itemBuilder: (context, index) {
          final entry = cartItems[index];
          final String productId = entry.key;
          final int qty = entry.value;

          ProductItem? product;
          try {
            product = allProducts.firstWhere((p) => p.id == productId);
          } catch (_) {
            try {
              product = recentlyAddedProducts.firstWhere((p) => p.id == productId);
            } catch (_) {
               try {
                 product = _fallbackProducts.firstWhere((p) => p.id == productId);
               } catch (_) {}
            }
          }

          if (product == null) return const SizedBox.shrink();

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
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 20,
                        color: isDark ? Colors.white38 : Colors.grey,
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
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        product.size,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.price,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
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
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
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
        Icon(icon, size: 18, color: isDark ? Colors.white70 : Colors.black54),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        if (showInfo) ...[
          const SizedBox(width: 4),
          Icon(Icons.info_outline, size: 14, color: isDark ? Colors.white38 : Colors.black38),
        ],
        const Spacer(),
        Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
      ],
    );
  }

  Widget _buildDonationCard(StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
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
                    color: isDark ? Colors.white54 : Colors.black54,
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
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
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
                      color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
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
        color: isDark ? const Color(0xFF161726) : Colors.white,
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
                color: isDark ? const Color(0xFF161726) : const Color(0xFFF5F7F9),
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
                                builder: (context) => AddAddressPage(isDarkMode: isDark),
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
                                ? (isDark ? Colors.white.withOpacity(0.1) : Colors.white)
                                : (isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                  ? const Color(0xFF2D7A3E)
                                  : (isDark ? Colors.white10 : Colors.black12),
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
                                          color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        addr['address']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white70 : Colors.black54,
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
                        onPressed: () async {
                          Navigator.pop(context); // Close address modal
                          
                          // Prepare cart data for payment page
                          final List<Map<String, dynamic>> cartDetails = [];
                          _productQty.forEach((id, qty) {
                            if (qty > 0) {
                              ProductItem? p;
                              try {
                                p = allProducts.firstWhere((item) => item.id == id);
                              } catch (_) {
                                try {
                                  p = recentlyAddedProducts.firstWhere((item) => item.id == id);
                                } catch (_) {
                                  try {
                                    p = _fallbackProducts.firstWhere((item) => item.id == id);
                                  } catch (_) {}
                                }
                              }

                              if (p != null) {
                                cartDetails.add({
                                  'name': p.name,
                                  'qty': qty,
                                  'price': p.price.replaceAll('₹', '').trim(),
                                });
                              }
                            }
                          });


                          final bool? orderSuccess = await Navigator.push<bool>(
                            context,
                            PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => PaymentPage(
                                  isDarkMode: isDark,
                                  onThemeToggle: widget.onThemeToggle,
                                  selectedAddress: _savedAddresses[_selectedAddressIndex]['address']!,
                                  selectedAddressType: _savedAddresses[_selectedAddressIndex]['type']!,
                                  totalAmount: totalCartAmount,
                                  cartItems: cartDetails,
                                  userName: _userName,
                                  userId: _userId,
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

                          if (orderSuccess == true) {
                            setState(() {
                              _productQty.clear();
                            });
                          }
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
      color: isDark ? const Color(0xFF1F202D) : Colors.white,
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
                  color: isDark ? Colors.white : Colors.black,
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
        _buildPopupItem('Log Out', Icons.logout, color: Colors.redAccent),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.blue.withOpacity(0.05),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'Edit Profile') {
        _editProfile();
      } else if (value == 'My Orders') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrdersPage(isDarkMode: isDark),
          ),
        );
      } else if (value == 'Log Out') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('isMockLoggedIn');
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => LoginPage(
                onThemeToggle: widget.onThemeToggle,
                isDarkMode: widget.isDarkMode,
              ),
            ),
            (route) => false,
          );
        }
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
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.more_horiz,
                color: isDark ? Colors.white70 : Colors.black54,
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
                  color: isDark ? Colors.white70 : Colors.black54,
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
          color: isDark ? const Color(0xFF1F202D) : Colors.white,
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
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
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
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black45),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
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
          Icon(icon, size: 20, color: color ?? (isDark ? Colors.white70 : Colors.black54)),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color ?? (isDark ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'See All',
              style: TextStyle(
                color: const Color(0xFF27C93F),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionBanners() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Left Banner (Large)
          Expanded(
            flex: 6,
            child: Container(
              height: 380,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=1200&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                    begin: Alignment.bottomLeft,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('New Arrivals', style: TextStyle(color: Color(0xFF4F8EFE), fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                      "Women's Style\nUp to 70% Off",
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Shop Now'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right Stack
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildSmallBanner('Handbag', 'Shop Now', '25% OFF', 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&q=80', const Color(0xFF4F8EFE)),
                const SizedBox(height: 16),
                _buildSmallBanner('Fashion Shoes', 'Shop Now', 'HOT', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80', const Color(0xFF27C93F)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBanner(String title, String subtitle, String tag, String img, Color tagColor) {
    return GestureDetector(
      onTap: () async {
        if (title.contains('Shoes')) {
          final updatedCart = await Navigator.push<Map<String, int>>(
            context,
            MaterialPageRoute(
              builder: (context) => ShoesPage(
                isDarkMode: isDark,
                allProducts: allProducts,
                initialCart: Map.from(_productQty),
              ),
            ),
          );
          if (updatedCart != null) {
            setState(() {
              _productQty.clear();
              _productQty.addAll(updatedCart);
            });
          }
        }
      },
      child: Container(
        height: 182,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [Colors.black.withOpacity(0.4), Colors.transparent], begin: Alignment.centerLeft),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(4)),
                child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: Text('$subtitle >', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13141F) : const Color(0xFF1F202D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.fromLTRB(40, 60, 40, 40),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Follow Us
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FOLLOW US',
                      style: TextStyle(
                        color: const Color(0xFF4F8EFE),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _footerSocialIcon(Icons.facebook),
                        _footerSocialIcon(Icons.camera_alt_outlined),
                        _footerSocialIcon(Icons.business_center_outlined), // LinkedIn
                        _footerSocialIcon(Icons.chat_bubble_outline), // Twitter
                        _footerSocialIcon(Icons.alternate_email), // G+
                        _footerSocialIcon(Icons.image_outlined), // Behance
                      ],
                    ),
                  ],
                ),
              ),
              
              // Column 2: Shop
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _footerHeader('SHOP'),
                    _footerLink('New In'),
                    _footerLink('Shoes'),
                    _footerLink('Bags'),
                    _footerLink('Shirts'),
                    _footerLink('Jackets'),
                    _footerLink('Accessories'),
                  ],
                ),
              ),
              
              // Column 3: Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _footerHeader('INFORMATION'),
                    _footerLink('About Us'),
                    _footerLink('Customers'),
                    _footerLink('Service'),
                    _footerLink('Collection'),
                    _footerLink('Sellers'),
                  ],
                ),
              ),
              
              // Column 4: Press
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _footerHeader('PRESS'),
                    _footerLink('Press Releases'),
                    _footerLink('Awards'),
                    _footerLink('Testimonials'),
                    _footerLink('Timeline'),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 80),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 40),
          
          // Bottom Navigation Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _footerBottomLink('HOME'),
              _footerBottomLink('BLOG'),
              _footerBottomLink('EXPLORE'),
              _footerBottomLink('WORKS'),
              _footerBottomLink('SHOP'),
              _footerBottomLink('BAGS'),
              _footerBottomLink('ABOUT US'),
              _footerBottomLink('CONTACT'),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            '© 2026 Blinkite User App. All Rights Reserved.',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _footerHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF4F8EFE),
          fontWeight: FontWeight.w900,
          fontSize: 14,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _footerLink(String title) {
    return InkWell(
      onTap: () => _onFooterLinkTap(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _footerBottomLink(String title) {
    return InkWell(
      onTap: () => _onFooterLinkTap(title),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF4F8EFE).withOpacity(0.8),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _onFooterLinkTap(String title) async {
    final t = title.toUpperCase();
    if (t == 'HOME') {
      _mainScrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      return;
    }
    if (t == 'SHOP') {
      // Scroll to categories (approx 200px down)
      _mainScrollController.animateTo(200, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      return;
    }
    if (t == 'BLOG') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BlogPage(isDarkMode: isDark)));
      return;
    }
    if (t == 'ABOUT US') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage(isDarkMode: isDark)));
      return;
    }
    if (t == 'BAGS' || title.toUpperCase() == 'BAGS') {
      final updatedCart = await Navigator.push<Map<String, int>>(
        context,
        MaterialPageRoute(
          builder: (context) => AllProductsPage(
            title: 'BAGS COLLECTION',
            categoryFilter: 'Bags',
            allProducts: allProducts,
            initialCart: Map.from(_productQty),
            isDarkMode: isDark,
          ),
        ),
      );
      if (updatedCart != null) setState(() { _productQty.clear(); _productQty.addAll(updatedCart); });
      return;
    }
    if (t == 'SHOES' || title.toUpperCase() == 'SHOES') {
      final updatedCart = await Navigator.push<Map<String, int>>(
        context,
        MaterialPageRoute(
          builder: (context) => AllProductsPage(
            title: 'PREMIUM FOOTWEAR',
            categoryFilter: 'Shoes',
            allProducts: allProducts,
            initialCart: Map.from(_productQty),
            isDarkMode: isDark,
          ),
        ),
      );
      if (updatedCart != null) setState(() { _productQty.clear(); _productQty.addAll(updatedCart); });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $title...'),
        backgroundColor: const Color(0xFF27C93F),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _footerSocialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  // ── DYNAMIC CATEGORY SECTIONS ──────────────────────────────

  List<Widget> _buildRecentlyViewedSection() {
    // If no history, show "Recently Added" instead
    final bool hasHistory = _recentlyViewedIndices.isNotEmpty;
    final List<String> displayIds = hasHistory 
      ? _recentlyViewedIndices 
      : recentlyAddedProducts.map((p) => p.id).take(8).toList();

    if (displayIds.isEmpty) return [];

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
        child: Row(
          children: [
            Icon(
              hasHistory ? Icons.history : Icons.auto_awesome_outlined, 
              color: hasHistory ? const Color(0xFF4F8EFE) : const Color(0xFFF5C842), 
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              hasHistory ? 'Recently Viewed' : 'Recently Added',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            if (hasHistory)
              TextButton(
                onPressed: () {
                  setState(() => _recentlyViewedIndices.clear());
                  _saveRecentlyViewed();
                },
                child: const Text('Clear', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
          ],
        ),
      ),
      SizedBox(
        height: 260,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: displayIds.length,
          itemBuilder: (context, idx) {
            final productId = displayIds[idx];
            ProductItem? product;
            try {
              product = allProducts.firstWhere((p) => p.id == productId);
            } catch (_) {
              try {
                product = recentlyAddedProducts.firstWhere((p) => p.id == productId);
              } catch (_) {}
            }
            
            if (product == null) return const SizedBox();
            
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildSmallProductCard(product, 0), // index not strictly needed for detail show
            );
          },
        ),
      ),
      const SizedBox(height: 20),
      Divider(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), height: 1),
    ];
  }

  Widget _buildSmallProductCard(ProductItem product, int index) {
    const cardBg = Colors.white;
    const borderColor = Color(0xFFF1F1F1);
    
    return GestureDetector(
      onTap: () => _showProductDetail(product, index),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Image.network(product.imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.price,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF2D7A3E)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSearchResults() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) return [];

    final results = allProducts.where((p) {
      return p.name.toLowerCase().contains(query) || 
             p.category.toLowerCase().contains(query);
    }).toList();

    if (results.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 60),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              const SizedBox(height: 20),
              Text(
                'No results found for "$query"',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try checking your spelling or use more general terms',
                style: TextStyle(
                  color: isDark ? Colors.white24 : Colors.black26,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 40),
      ];
    }

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF27C93F),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Search Results',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              '${results.length} items',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: results.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
          childAspectRatio: 0.62,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, idx) {
          final product = results[idx];
          final globalIdx = allProducts.indexOf(product);
          return _buildProductCard(product, globalIdx);
        },
      ),
      const SizedBox(height: 20),
      const Divider(height: 60),
      // Only show the header for regular content if we have search results
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
             Icon(Icons.auto_awesome, color: const Color(0xFFF5C842), size: 18),
             const SizedBox(width: 8),
             Text(
               'Discover More',
               style: TextStyle(
                 color: isDark ? Colors.white70 : Colors.black54,
                 fontSize: 16,
                 fontWeight: FontWeight.bold,
               ),
             ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildCategoryProductSections() {
    // Group products by category
    Map<String, List<ProductItem>> grouped = {};
    for (var p in allProducts) {
      if (p.category == 'All' || p.isRecent) continue;
      grouped.putIfAbsent(p.category, () => []).add(p);
    }

    // Sort categories alphabetically
    var sortedCategories = grouped.keys.toList()..sort();

    return sortedCategories.map((catName) {
      final products = grouped[catName]!;
      if (products.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  catName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                TextButton(
                  onPressed: () async {
                    final updatedCart = await Navigator.push<Map<String, int>>(

                      context,
                      MaterialPageRoute(
                        builder: (context) => AllProductsPage(
                          title: catName,
                          categoryFilter: catName,
                          allProducts: allProducts,
                          initialCart: Map.from(_productQty),
                          isDarkMode: isDark,
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
                  child: const Text('See all >',
                      style: TextStyle(
                          color: Color(0xFF27C93F), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final gIdx = allProducts.indexOf(product);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _AddressPageProductCard(
                    product: product,
                    isFavorite: _favoriteProductIds.contains(product.id),
                    onFavoriteToggle: () => _toggleFavorite(product.id),
                    qty: _productQty[product.id] ?? 0,
                    onAddToCart: () => setState(() =>
                        _productQty[product.id] = (_productQty[product.id] ?? 0) + 1),
                    onTap: () => _showProductDetail(product, gIdx),

                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }

  Widget _buildCategoryGrid() {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: GridView.builder(
        controller: _categoryScrollController,
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 180, // Card width
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _CategoryHoverCard(
            category: categories[index],
            isDark: isDark,
            onTap: () async {
              setState(() => _selectedCategoryIndex = index);
              final updatedCart = await Navigator.push<Map<String, int>>(
                context,
                MaterialPageRoute(
                  builder: (context) => AllProductsPage(
                    title: categories[index].label,
                    categoryFilter: categories[index].label,
                    allProducts: allProducts,
                    initialCart: Map.from(_productQty),
                    isDarkMode: isDark,
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
          );
        },
      ),
    );
  }

  Widget _buildRecentlyAddedSection() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentlyAddedProducts.length,
        itemBuilder: (context, index) {
          final product = recentlyAddedProducts[index];
          final globalIdx = allProducts.indexOf(product);
          return _buildProductCard(product, globalIdx);
        },
      ),
    );
  }
}

class _CategoryHoverCard extends StatefulWidget {
  final CategoryItem category;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryHoverCard({required this.category, required this.isDark, required this.onTap});

  @override
  State<_CategoryHoverCard> createState() => _CategoryHoverCardState();
}

class _CategoryHoverCardState extends State<_CategoryHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.05 : 1.0)
            ..translate(0.0, _isHovered ? -8.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.1),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 12 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full background image
                Image.network(
                  widget.category.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.category, size: 40),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(_isHovered ? 0.8 : 0.6),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Category Name
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    widget.category.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ProductScreen replaced by unified AllProductsPage for better dynamic support.

// ═══════════════════════════════════════════════════════════════════════
// ALL PRODUCTS PAGE — opens when user taps "See all" card
// ═══════════════════════════════════════════════════════════════════════
class AllProductsPage extends StatefulWidget {
  final String title;
  final List<ProductItem> allProducts;
  final String categoryFilter;
  final Map<String, int> initialCart;
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
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  late Map<String, int> _qty;
  late List<ProductItem> filteredProducts;

  Set<String> _favoriteProductIds = {}; 

  @override
  void initState() {
    super.initState();
    _qty = Map.from(widget.initialCart);
    filteredProducts = widget.allProducts
        .where((p) => (widget.categoryFilter == 'All' || p.category == widget.categoryFilter) && !p.isRecent)
        .toList();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList('favorite_products');
    if (stored != null) {
      setState(() {
        _favoriteProductIds = stored.toSet();
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_products', _favoriteProductIds.toList());
  }

  void _toggleFavorite(String productId) {
    setState(() {
      if (_favoriteProductIds.contains(productId)) {
        _favoriteProductIds.remove(productId);
      } else {
        _favoriteProductIds.add(productId);
      }
    });
    _saveFavorites();
  }

  @override
  Widget build(BuildContext context) {

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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
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

  void _showProductDetail(ProductItem product) {

    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final bool isFavorite = _favoriteProductIds.contains(product.id);
          final int qty = _qty[product.id] ?? 0;
          final PageController pageController = PageController();

          
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: screenWidth > 600 ? 450 : screenWidth * 0.9,
              height: screenHeight * 0.85,
              constraints: const BoxConstraints(maxHeight: 700),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 300,
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: product.images.length,
                            itemBuilder: (context, i) => Image.network(
                              product.images[i],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withOpacity(0.4),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              _toggleFavorite(product.id);
                              setDialogState(() {});
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        if (product.images.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${product.images.length} Images',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.size,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Premium quality item sourced directly for your convenience. Hand-picked and guaranteed fresh upon delivery.',
                              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('MRP', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    Text(
                                      product.price,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                qty == 0
                                  ? ElevatedButton(
                                      onPressed: () {
                                        setState(() => _qty[product.id] = 1);
                                        setDialogState(() {});
                                      },

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF27C93F),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 0,
                                      ),
                                      child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.w900)),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF27C93F),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          _detailQtyButton(
                                            icon: Icons.remove,
                                            onTap: () {
                                              setState(() {
                                                if ((_qty[product.id] ?? 1) <= 1) {
                                                  _qty.remove(product.id);
                                                } else {
                                                  _qty[product.id] = (_qty[product.id] ?? 1) - 1;
                                                }
                                              });
                                              setDialogState(() {});

                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              '$qty',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                                            ),
                                          ),
                                          _detailQtyButton(
                                            icon: Icons.add,
                                            onTap: () {
                                              setState(() => _qty[product.id] = (qty) + 1);
                                              setDialogState(() {});
                                            },

                                          ),
                                        ],
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
            ),
          );
        },
      ),
    );
  }

  Widget _detailQtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _btn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFF27C93F),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildGridCard(ProductItem product) {
    final qty = _qty[product.id] ?? 0;

    
    final cardBg = isDark ? const Color(0xFF1A1B28) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.black.withOpacity(0.07);

    return GestureDetector(
      onTap: () => _showProductDetail(product),
      child: Container(
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
                    const SizedBox(width: 8),
                    Container(width: 1, height: 10, color: isDark ? Colors.white12 : Colors.black12),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, size: 11, color: Color(0xFFFFB300)),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
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
                            onTap: () => setState(() => _qty[product.id] = 1),

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
                                  if ((_qty[product.id] ?? 1) <= 1) {
                                    _qty.remove(product.id);
                                  } else {
                                    _qty[product.id] = (_qty[product.id] ?? 1) - 1;
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
                                    setState(() => _qty[product.id] = qty + 1),

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
  final int unreadNotificationsCount;
  final VoidCallback onCartTap;
  final VoidCallback onNotificationTap;
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
    required this.unreadNotificationsCount,
    required this.onCartTap,
    required this.onNotificationTap,
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
                                  duration: const Duration(seconds: 1),
                                  transitionBuilder: (child, animation) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.0, 1.2),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                      child: FadeTransition(opacity: animation, child: child),
                                    );
                                  },
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
                  
                  // Notification Bell
                  _buildHeaderNotificationBell(),
                  const SizedBox(width: 12),
                  
                  // Blog Button in Header

                  TextButton(
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => BlogPage(isDarkMode: isDarkMode))
                    ),
                    child: Text(
                      'BLOG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isDarkMode ? const Color(0xFF4F8EFE) : const Color(0xFF1A73E8),
                        letterSpacing: 1.1,
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
                            duration: const Duration(seconds: 1),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 1.2),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                child: FadeTransition(opacity: animation, child: child),
                              );
                            },
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
                    
                    // Notification Bell
                    _buildHeaderNotificationBell(),
                    const SizedBox(width: 16),

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

  Widget _buildHeaderNotificationBell() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onNotificationTap,
          child: Icon(
            Icons.notifications_none,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 22,
          ),
        ),
        if (unreadNotificationsCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFF27C93F),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                unreadNotificationsCount > 9 ? '9+' : '$unreadNotificationsCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
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

class _FeaturedProductsSection extends StatefulWidget {
  final List<ProductItem> allProducts;
  final List<ProductItem> newArrivalProducts;
  final Set<String> favoriteProductIds;
  final Function(String) onAddToCart;
  final Function(String) onFavoriteToggle;
  final Function(ProductItem, int?) onShowDetail;
  final Map<String, int> productQty;
  final bool isDark;


  const _FeaturedProductsSection({
    required this.allProducts,
    required this.newArrivalProducts,
    required this.favoriteProductIds,
    required this.onAddToCart,
    required this.onFavoriteToggle,
    required this.onShowDetail,
    required this.productQty,
    required this.isDark,
  });

  @override
  State<_FeaturedProductsSection> createState() => _FeaturedProductsSectionState();
}

class _FeaturedProductsSectionState extends State<_FeaturedProductsSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['New Arrival', 'Best Selling', 'Top Rated'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              const Text(
                'Featured Products',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFF27C93F),
                indicatorWeight: 3,
                labelColor: widget.isDark ? Colors.white : Colors.black,
                unselectedLabelColor: widget.isDark ? Colors.white38 : Colors.black38,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
                dividerColor: Colors.transparent,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 320,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProductRow(widget.newArrivalProducts),
              Center(child: Text('Best Selling coming soon...', style: TextStyle(color: widget.isDark ? Colors.white54 : Colors.black54))),
              Center(child: Text('Top Rated coming soon...', style: TextStyle(color: widget.isDark ? Colors.white54 : Colors.black54))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductRow(List<ProductItem> products) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final qty = widget.productQty[product.id] ?? 0;
        
        return Container(
          width: 170,
          margin: const EdgeInsets.only(right: 16, bottom: 10),
          child: _AddressPageProductCard(
            product: product,
            isFavorite: widget.favoriteProductIds.contains(product.id),
            onFavoriteToggle: () => widget.onFavoriteToggle(product.id),
            qty: qty,
            onAddToCart: () => widget.onAddToCart(product.id),
            onTap: () => widget.onShowDetail(product, null),
          ),
        );
      },

    );
  }
}

// Extract the product card to a reusable widget logic to satisfy the user's request
class _AddressPageProductCard extends StatelessWidget {
  final ProductItem product;
  final int qty;
  final bool isFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const _AddressPageProductCard({
    required this.product,
    required this.qty,
    required this.isFavorite,
    required this.onAddToCart,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F1F1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Image.network(product.imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite ? Colors.red : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 11, color: Colors.black87),
                        const SizedBox(width: 4),
                        Text('${product.deliveryMins} MINS', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black87)),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 10, color: Colors.black12),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 11, color: Color(0xFFFFB300)),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black, height: 1.2)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black)),
                      qty == 0
                        ? GestureDetector(
                            onTap: onAddToCart,
                            child: Container(
                              width: 64, height: 36,
                              decoration: BoxDecoration(color: const Color(0xFFF7FFF9), border: Border.all(color: const Color(0xFF27C93F), width: 1.5), borderRadius: BorderRadius.circular(8)),
                              child: const Center(child: Text('ADD', style: TextStyle(color: Color(0xFF27C93F), fontSize: 13, fontWeight: FontWeight.w800))),
                            ),
                          )
                        : Container(
                            width: 64, height: 36,
                            decoration: BoxDecoration(color: const Color(0xFF27C93F), borderRadius: BorderRadius.circular(8)),
                            child: const Center(child: Text('ADDED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
