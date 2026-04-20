import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  final bool isDarkMode;

  const OrdersPage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0D0E17) : const Color(0xFFF5F7F9);
    final Color cardColor = isDark ? const Color(0xFF1F202D) : Colors.white;

    // Enhanced mock data with product details
    final List<Map<String, dynamic>> orders = [
      {
        'id': 'BK142157',
        'date': '16 April 2026, 12:30 PM',
        'amount': '693',
        'status': 'Arriving',
        'timer': '14:39',
        'items': [
          {'name': 'Aashirvaad Atta', 'qty': 2, 'price': 275},
          {'name': 'Farm Fresh Eggs', 'qty': 2, 'price': 58},
        ],
      },
      {
        'id': 'BK9821123',
        'date': '15 April 2026, 08:15 AM',
        'amount': '120',
        'status': 'Delivered',
        'timer': null,
        'items': [
          {'name': 'Lays Classic', 'qty': 3, 'price': 20},
          {'name': 'Kurkure Masala', 'qty': 4, 'price': 15},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D7A3E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No orders yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Card Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: order['status'] == 'Arriving' ? const Color(0xFF2D7A3E) : Colors.grey.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${order['id']}',
                                  style: TextStyle(
                                    color: order['status'] == 'Arriving' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  order['date'],
                                  style: TextStyle(
                                    color: order['status'] == 'Arriving' ? Colors.white.withOpacity(0.8) : Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: order['status'] == 'Arriving' ? Colors.white24 : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order['status'],
                                style: TextStyle(
                                  color: order['status'] == 'Arriving' ? Colors.white : Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Card Body: Map (Left) + Content (Right)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Map Section (Left side as requested)
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                              child: _OrderTrackingMap(
                                isDarkMode: isDark,
                                status: order['status'],
                                timer: order['timer'],
                              ),
                            ),
                          ),
                          
                          // 2. Content Section (Right)
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order Summary',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ... (order['items'] as List).map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Text('${item['qty']}x ', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        Expanded(
                                          child: Text(
                                            item['name'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isDark ? Colors.white70 : Colors.black87,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '₹${item['price']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Text(
                                        '₹${order['amount']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF2D7A3E),
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
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _OrderTrackingMap extends StatelessWidget {
  final bool isDarkMode;
  final String status;
  final String? timer;

  const _OrderTrackingMap({
    required this.isDarkMode,
    required this.status,
    this.timer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black26 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Placeholder for Google Map / Flutter Map
            Image.network(
              isDarkMode 
                ? 'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=600&q=80' // Darkish city map look
                : 'https://images.unsplash.com/photo-1569336415962-a4bd9f6dfc0f?w=600&q=80', // Light city map look
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            
            // Route Line (Visual representation)
            if (status == 'Arriving')
              Positioned.fill(
                child: CustomPaint(
                  painter: _RoutePainter(isDarkMode: isDarkMode),
                ),
              ),

            // Pick location (Store)
            Positioned(
              top: 40,
              left: 40,
              child: _MapMarker(
                icon: Icons.store,
                color: Colors.blueAccent,
                label: 'Pick',
              ),
            ),

            // Drop location (Home)
            Positioned(
              bottom: 40,
              right: 40,
              child: _MapMarker(
                icon: Icons.home,
                color: const Color(0xFF2D7A3E),
                label: 'Drop',
              ),
            ),

            // Delivery boy moving (Only if arriving)
            if (status == 'Arriving')
              const Positioned(
                bottom: 80,
                right: 80,
                child: _MovingDeliveryAgent(),
              ),

            // Arriving Overlay
            if (timer != null)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 10, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        timer!,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
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

class _MapMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _MapMarker({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _MovingDeliveryAgent extends StatefulWidget {
  const _MovingDeliveryAgent();

  @override
  State<_MovingDeliveryAgent> createState() => _MovingDeliveryAgentState();
}

class _MovingDeliveryAgentState extends State<_MovingDeliveryAgent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-10 * _controller.value, -10 * _controller.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
        child: const Icon(Icons.delivery_dining, color: Colors.white, size: 20),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final bool isDarkMode;
  _RoutePainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.26)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(60, 60)
      ..lineTo(size.width * 0.4, 70)
      ..lineTo(size.width * 0.5, 120)
      ..lineTo(size.width * 0.8, size.height - 60);

    canvas.drawPath(path, paint);

    // Draw active part of route
    final activePaint = Paint()
      ..color = const Color(0xFF2D7A3E)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final activePath = Path()
      ..moveTo(60, 60)
      ..lineTo(size.width * 0.4, 70)
      ..lineTo(size.width * 0.5, 120);
      
    canvas.drawPath(activePath, activePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
