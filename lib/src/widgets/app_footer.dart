import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  final bool isDark;
  final Function(String) onLinkTap;

  const AppFooter({
    super.key,
    required this.isDark,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    _footerHeader('FOLLOW US'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _footerSocialIcon(Icons.facebook),
                        _footerSocialIcon(Icons.camera_alt_outlined),
                        _footerSocialIcon(Icons.business_center_outlined),
                        _footerSocialIcon(Icons.chat_bubble_outline),
                        _footerSocialIcon(Icons.alternate_email),
                        _footerSocialIcon(Icons.image_outlined),
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
                    _footerLink('Customer Support'),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _footerBottomLink('HOME'),
                const SizedBox(width: 20),
                _footerBottomLink('BLOG'),
                const SizedBox(width: 20),
                _footerBottomLink('EXPLORE'),
                const SizedBox(width: 20),
                _footerBottomLink('WORKS'),
                const SizedBox(width: 20),
                _footerBottomLink('SHOP'),
                const SizedBox(width: 20),
                _footerBottomLink('BAGS'),
                const SizedBox(width: 20),
                _footerBottomLink('ABOUT US'),
                const SizedBox(width: 20),
                _footerBottomLink('CONTACT'),
              ],
            ),
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
        style: const TextStyle(
          color: Color(0xFF4F8EFE),
          fontWeight: FontWeight.w900,
          fontSize: 14,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _footerLink(String title) {
    return InkWell(
      onTap: () => onLinkTap(title),
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
      onTap: () => onLinkTap(title),
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

  Widget _footerSocialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 18),
    );
  }
}
