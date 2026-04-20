import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  final bool isDarkMode;

  const AboutPage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF0D0E17) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ABOUT US',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F8EFE).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SOMETHING',
                      style: TextStyle(
                        color: Color(0xFF4F8EFE),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ABOUT US',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'The world\'s most powerful delivery ecosystem which takes the "live shopping experience" to next level. Blinkite is created by a team of experienced professional developers and designers. The team has focused on user experience and ease of use in every aspect of this project.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: subTextColor,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // Firm Info Section (Inspired by reference image)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: textColor.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('ABOUT US', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'About our firm',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'At our firm, we pride ourselves on delivering tailored solutions that empower businesses to thrive. With years of experience across various industries, our dedicated team is committed to driving growth and operational excellence.',
                          style: TextStyle(color: subTextColor, height: 1.5),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            _buildStatItem('95%', 'Complete customer satisfaction', textColor),
                            const SizedBox(width: 20),
                            _buildStatItem('10+', 'Innovation and valuable model', textColor),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildStatItem('\$10m', 'Highly efficient financial strategies', textColor),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800&q=80',
                        fit: BoxFit.cover,
                        height: 400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Quote Section
            Container(
              width: double.infinity,
              color: isDarkMode ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
              padding: const EdgeInsets.all(60),
              child: Column(
                children: [
                  Icon(Icons.format_quote, size: 48, color: const Color(0xFF4F8EFE).withOpacity(0.5)),
                  const SizedBox(height: 20),
                  Text(
                    '“Our mission is to simplify the complex and make the extraordinary accessible to everyone through innovative technology and human-centric design.”',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '— Blinkite Team',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F8EFE),
                    ),
                  ),
                ],
              ),
            ),

            // Journey Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: textColor.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('MILESTONES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Our journey: key milestones\nand achievements',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textColor),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          'Discover the significant milestones that have shaped our firm. Each achievement reflects our commitment to excellence and growth.',
                          style: TextStyle(color: subTextColor, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      _buildMilestoneCard(Icons.rocket_launch, 'Launch', '2023', isDarkMode),
                      const SizedBox(width: 16),
                      _buildMilestoneCard(Icons.groups_3, '1M Users', '2024', isDarkMode),
                      const SizedBox(width: 16),
                      _buildMilestoneCard(Icons.public, 'Global Expansion', '2026', isDarkMode),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String desc, Color textColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            val,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6), height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(IconData icon, String title, String year, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4F8EFE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(year, style: const TextStyle(color: Color(0xFF4F8EFE), fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
