import 'package:flutter/material.dart';
import 'dart:js' as js;
import '../widgets/app_footer.dart';
import '../widgets/app_navbar.dart';
import './blog_page.dart';
import './orders_page.dart';
import './login_page.dart';

class AboutPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final String address;
  final String userName;
  final int totalCartItems;
  final int unreadNotificationsCount;

  const AboutPage({
    super.key, 
    required this.isDarkMode,
    required this.onThemeToggle,
    this.address = 'Gaur city center',
    this.userName = 'User',
    this.totalCartItems = 0,
    this.unreadNotificationsCount = 0,
  });

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _onFooterLinkTap(String title) {
    final t = title.toUpperCase();
    if (t == 'CUSTOMER SUPPORT') {
      try {
        if (js.context.hasProperty('Tawk_API')) {
          js.JsObject tawk = js.context['Tawk_API'];
          tawk.callMethod('showWidget');
          tawk.callMethod('maximize');
        }
      } catch (e) {
        debugPrint('Tawk.to Error: $e');
      }
      return;
    }
    if (t == 'HOME') {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }
    if (t == 'BLOG') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => BlogPage(isDarkMode: _isDarkMode)));
      return;
    }
    if (t == 'ORDERS') {
       Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage(isDarkMode: _isDarkMode)));
       return;
    }
    if (t == 'ABOUT US' || t == 'ABOUT') {
      return;
    }
  }

  void _onAccountTap(BuildContext context) {
    final RelativeRect position = RelativeRect.fromLTRB(
      MediaQuery.of(context).size.width - 100,
      80,
      MediaQuery.of(context).size.width - 16,
      0,
    );
    
    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        const PopupMenuItem(
          value: 'orders',
          child: Row(children: [Icon(Icons.shopping_bag_outlined, size: 18), SizedBox(width: 10), Text('Orders', style: TextStyle(fontSize: 13))]),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(children: [Icon(Icons.logout, size: 18, color: Colors.red), SizedBox(width: 10), Text('Logout', style: TextStyle(fontSize: 13, color: Colors.red))]),
        ),
      ],
    ).then((value) {
      if (value == 'orders') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage(isDarkMode: _isDarkMode)));
      } else if (value == 'logout') {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => LoginPage(
            isDarkMode: _isDarkMode,
            onThemeToggle: widget.onThemeToggle,
          )), 
          (route) => false
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkMode ? const Color(0xFF0D0E17) : Colors.white;
    final primaryBlue = const Color(0xFF0056D2);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // --- SHARED NAVBAR ---
          AppNavbar(
            isDarkMode: _isDarkMode,
            address: widget.address,
            userName: widget.userName,
            totalCartItems: widget.totalCartItems,
            unreadNotificationsCount: widget.unreadNotificationsCount,
            onLogoTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            onAddressTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            onSearchTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            onCartTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            onNotificationTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon!')));
            },
            onThemeToggle: () {
              widget.onThemeToggle();
              setState(() => _isDarkMode = !_isDarkMode);
            },
            onAccountTap: () => _onAccountTap(context),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- HERO SECTION ---
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1557683316-973673baf926?w=1600&q=80'),
                        fit: BoxFit.cover,
                        opacity: 0.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
                    child: Column(
                      children: [
                        const Text(
                          'Our Story',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'The conviction in our mission',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 100),
                          child: Text(
                            'Synergistically transition cost effective niches without frictionless niche markets. Conveniently leverage other\'s leveraged information for',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- OUR STORY TEXT SECTION ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 100),
                    color: Colors.white,
                    child: Column(
                      children: [
                        const Text(
                          'Our Story',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'The conviction in our mission came after being in the e-commerce industry for two decades as shoppers and merchants. Then, Bight was born out of necessity. Fraud, chargebacks, high fees, slow transaction settlements, and lack of customer privacy, represent a small sample of the industry\'s persisting problems.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'At Bight, we understand that such problems cannot be solved without new disruptive technology. Thus, we use the blockchain technology to simplify cryptocurrencies for everyday transactions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- TEAM SECTION ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
                    color: const Color(0xFFF8F9FA),
                    child: Column(
                      children: [
                        const Text(
                          'Meet our team',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 60),
                        // Team Grid
                        Wrap(
                          spacing: 30,
                          runSpacing: 40,
                          alignment: WrapAlignment.center,
                          children: [
                            _teamCard('Richard L. Channel', 'CEO at bight', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80'),
                            _teamCard('Richard L. Channel', 'CEO at bight', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&q=80'),
                            _teamCard('Richard L. Channel', 'CEO at bight', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&q=80'),
                            _teamCard('Richard L. Channel', 'CEO at bight', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80'),
                            _teamCard('Richard L. Channel', 'CEO at bight', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&q=80'),
                            _teamCard('Richard L. Channel', 'CEO at bight', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&q=80'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- SUBSCRIBE CTA ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(60),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('All dolled up', style: TextStyle(color: Colors.black54, fontSize: 14)),
                                const SizedBox(height: 8),
                                const Text(
                                  'Design&trending\nsubscribe us',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0056D2),
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 300,
                            height: 54,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(27),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Enter your email',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(4),
                                  width: 46,
                                  height: 46,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0056D2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- REUSABLE FOOTER ---
                  AppFooter(
                    isDark: _isDarkMode,
                    onLinkTap: _onFooterLinkTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamCard(String name, String role, String img) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(img, height: 250, width: 250, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(role, style: const TextStyle(color: Colors.black38, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _socialIcon(Icons.camera_alt_outlined),
                    _socialIcon(Icons.facebook),
                    _socialIcon(Icons.chat_bubble_outline),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Icon(icon, size: 14, color: const Color(0xFF0056D2)),
    );
  }
}
