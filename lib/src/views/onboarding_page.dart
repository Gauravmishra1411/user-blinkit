import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinish;
  final bool isDarkMode;

  const OnboardingPage({
    super.key,
    required this.onFinish,
    required this.isDarkMode,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Fresh & Fast",
      description: "Get all your daily essentials delivered to your doorstep in minutes.",
      icon: Icons.flash_on,
      color: const Color(0xFF39D2FF),
    ),
    OnboardingData(
      title: "Best Quality",
      description: "We pick only the best and freshest products for you and your family.",
      icon: Icons.star_border_rounded,
      color: const Color(0xFFE57CFF),
    ),
    OnboardingData(
      title: "Easy Payments",
      description: "Multiple payment options available with secure checkout process.",
      icon: Icons.payment_rounded,
      color: const Color(0xFF4F8EFE),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF0D0E17) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingSlide(
                    data: _pages[index],
                    isDarkMode: widget.isDarkMode,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : (widget.isDarkMode ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Button
                  FloatingActionButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        widget.onFinish();
                      }
                    },
                    backgroundColor: _pages[_currentPage].color,
                    elevation: 0,
                    child: Icon(
                      _currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                    ),
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

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class OnboardingSlide extends StatelessWidget {
  final OnboardingData data;
  final bool isDarkMode;

  const OnboardingSlide({
    super.key,
    required this.data,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: data.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      data.icon,
                      size: 100,
                      color: data.color,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 60),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
