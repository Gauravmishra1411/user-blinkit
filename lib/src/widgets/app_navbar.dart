import 'package:flutter/material.dart';
import 'kb_logo.dart';

class AppNavbar extends StatelessWidget {
  final bool isDarkMode;
  final String address;
  final String userName;
  final int totalCartItems;
  final int unreadNotificationsCount;
  final VoidCallback onCartTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onThemeToggle;
  final VoidCallback onAccountTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onAddressTap;
  final VoidCallback? onSearchTap;
  final String placeholder;

  const AppNavbar({
    super.key,
    required this.isDarkMode,
    required this.address,
    required this.userName,
    required this.totalCartItems,
    required this.unreadNotificationsCount,
    required this.onCartTap,
    required this.onNotificationTap,
    required this.onThemeToggle,
    required this.onAccountTap,
    this.onLogoTap,
    this.onAddressTap,
    this.onSearchTap,
    this.placeholder = 'Search "milk"',
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF0D0E17) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo
          InkWell(
            onTap: onLogoTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: const KBLogo(size: 34),
            ),
          ),
          const SizedBox(width: 12),
          
          // Address Dropdown
          InkWell(
            onTap: onAddressTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        address,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      Icon(Icons.arrow_drop_down, size: 18, color: textColor.withOpacity(0.7)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Search Bar
          Expanded(
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20, color: textColor.withOpacity(0.7)),
                    const SizedBox(width: 12),
                    Text(
                      placeholder,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),

          // Action Items
          Row(
            children: [
              // Notification
              _buildNotificationItem(textColor),
              const SizedBox(width: 24),

              // Cart
              InkWell(
                onTap: onCartTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: totalCartItems > 0 ? const Color(0xFF27C93F) : (isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: totalCartItems > 0 ? const Color(0xFF27C93F) : (isDarkMode ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: totalCartItems > 0 ? Colors.white : textColor.withOpacity(0.7), size: 14),
                      if (totalCartItems > 0) ...[
                        const SizedBox(width: 4),
                        Text('$totalCartItems', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // User Name
              Text(userName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(width: 12),

              // Account
              InkWell(
                onTap: onAccountTap,
                borderRadius: BorderRadius.circular(20),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: isDarkMode ? Colors.white10 : Colors.black12,
                  child: Icon(Icons.person_outline, size: 16, color: textColor),
                ),
              ),
              const SizedBox(width: 12),

              // Theme Toggle
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 20, color: textColor),
                onPressed: onThemeToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Color textColor) {
    return InkWell(
      onTap: onNotificationTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_none, size: 22, color: textColor),
            if (unreadNotificationsCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                  child: Text(
                    '$unreadNotificationsCount',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
