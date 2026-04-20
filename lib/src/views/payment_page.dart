import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class PaymentPage extends StatefulWidget {
  final bool isDarkMode;
  final String selectedAddress;
  final String selectedAddressType;
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  final String userName;
  final String userId;

  final VoidCallback onThemeToggle;

  const PaymentPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.selectedAddress,
    required this.selectedAddressType,
    required this.totalAmount,
    required this.cartItems,
    this.userName = 'User',
    this.userId = 'USER123',
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _expandedMethod; // 'card', 'upi', etc.
  String? _selectedMode; // 'Online', 'Cash on Delivery', 'UPI'
  String? _transactionId;
  bool _isQrGenerated = false;

  late String _orderId;

  @override
  void initState() {
    super.initState();
    _orderId = 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isWide = size.width > 900;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E17) : const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D0E17) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Payment Method',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: widget.onThemeToggle,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isWide) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildPaymentMethodsList()),
                    const SizedBox(width: 40),
                    Expanded(flex: 2, child: _buildOrderSummary()),
                  ],
                ),
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPaymentMethodsList(),
                    _buildOrderSummary(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F202D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          _paymentTile('Online Payment', Icons.payment, 'online', subtitle: 'Pay via Card, Netbanking or Wallets'),
          if (_expandedMethod == 'online') _buildOnlineOptions(),
          _divider(),
          _paymentTile('UPI', Icons.mobile_screen_share, 'upi', subtitle: 'Pay using any UPI app'),
          if (_expandedMethod == 'upi') _buildUpiQr(),
          _divider(),
          if (widget.totalAmount >= 150) ...[
            _paymentTile(
              'Cash on Delivery', 
              Icons.money, 
              'cash',
              subtitle: 'Pay when your order arrives',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOnlineOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.02),
      child: Column(
        children: [
          _subPaymentTile('Credit / Debit Card', Icons.credit_card, 'card'),
          _subPaymentTile('Netbanking', Icons.account_balance, 'netbanking'),
          _subPaymentTile('Wallets', Icons.account_balance_wallet, 'wallets'),
        ],
      ),
    );
  }

  Widget _subPaymentTile(String title, IconData icon, String mode) {
    bool isSelected = _selectedMode == mode;
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: isSelected ? const Color(0xFF2D7A3E) : Colors.grey),
      title: Text(title, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF2D7A3E), size: 18) : null,
      onTap: () {
        setState(() {
          _selectedMode = mode;
          _transactionId = 'TXN${math.Random().nextInt(999999).toString().padLeft(6, '0')}';
        });
      },
    );
  }

  Widget _paymentTile(String title, IconData icon, String methodId, {String? subtitle, bool isDisabled = false}) {
    final bool isExpanded = _expandedMethod == methodId;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Icon(icon, color: isDisabled ? Colors.grey : (isDark ? Colors.white70 : Colors.black87)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDisabled ? Colors.grey : (isDark ? Colors.white : Colors.black),
        ),
      ),
      subtitle: subtitle != null ? Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.blueAccent),
        ),
      ) : null,
      trailing: Icon(
        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
        color: isExpanded ? const Color(0xFF2D7A3E) : Colors.grey,
      ),
      onTap: isDisabled ? null : () {
        setState(() {
          _expandedMethod = isExpanded ? null : methodId;
          if (methodId == 'cash') {
            _selectedMode = 'Cash on Delivery';
            _transactionId = null;
          } else if (methodId == 'upi') {
            _selectedMode = 'UPI';
            _transactionId = 'UPI${math.Random().nextInt(999999).toString().padLeft(6, '0')}';
          }
        });
      },
    );
  }

  Widget _buildUpiQr() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Scan QR to pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Use any UPI app on your phone to scan and pay', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              _upiIcon('G Pay'),
              const SizedBox(width: 8),
              _upiIcon('PhonePe'),
              const SizedBox(width: 8),
              _upiIcon('Paytm'),
              const SizedBox(width: 8),
              const Text('or others', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Opacity(
                      opacity: _isQrGenerated ? 1.0 : 0.3,
                      child: Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=BlinkitePayment',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.qr_code, size: 100, color: Colors.white24)),
                      ),
                    ),
                  ),
                ),
                if (!_isQrGenerated)
                  ElevatedButton(
                    onPressed: () => setState(() => _isQrGenerated = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEB4B4B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Generate QR', style: TextStyle(fontSize: 14)),
                  ),
                if (_isQrGenerated)
                  Positioned(
                    bottom: 10,
                    child: Text('Payment Active', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _upiIcon(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _navigateToThankYou() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ThankYouPage(
          isDarkMode: isDark,
          onThemeToggle: widget.onThemeToggle,
          orderId: _orderId,
          totalAmount: widget.totalAmount,
          cartItems: widget.cartItems,
          userName: widget.userName,
          userId: widget.userId,
          paymentMode: _selectedMode ?? 'Online',
          transactionId: _transactionId,
          status: _selectedMode == 'Cash on Delivery' ? 'Cash' : 'Online',
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12, thickness: 1);
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F202D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order ID', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(_orderId, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 12),
          const Text('Delivery Address', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '${widget.selectedAddressType}: ${widget.selectedAddress}',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${widget.cartItems.length} item', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.cartItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text('${item['qty']} x ', style: const TextStyle(color: Colors.grey)),
                Expanded(
                  child: Text(
                    item['name'],
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                ),
                Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ).animateRow(),
          )),
          const Divider(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedMode != null ? () => _navigateToThankYou() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27C93F),
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _selectedMode == null 
                  ? 'Select Payment Mode' 
                  : 'Confirm Order (₹${widget.totalAmount.toStringAsFixed(0)})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThankYouPage extends StatefulWidget {
  final bool isDarkMode;
  final String orderId;
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;
  final String userName;
  final String userId;
  final String paymentMode;
  final String? transactionId;
  final String status;

  final VoidCallback onThemeToggle;

  const ThankYouPage({
    super.key,
    required this.isDarkMode, 
    required this.onThemeToggle,
    required this.orderId,
    required this.totalAmount,
    required this.cartItems,
    required this.userName,
    required this.userId,
    required this.paymentMode,
    this.transactionId,
    required this.status,
  });

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> with TickerProviderStateMixin {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  bool _showOrderCard = false;
  late AnimationController _celebrationController;
  final List<EmojiParticle> _particles = [];
  Timer? _orderTimer;
  int _secondsRemaining = 15 * 60;

  // Map related
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isMapLoading = true;

  // Mock Pickup Location (Delivery Hub)
  static const LatLng _pickupLocation = LatLng(28.5355, 77.3910); 

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      });

    _generateParticles();
    _celebrationController.forward();

    // Show order card after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showOrderCard = true;
        });
        _startTimer();
        _initializeMapData();
      }
    });
  }

  Future<void> _initializeMapData() async {
    try {
      // 1. Get Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 2. Get Current Location
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isMapLoading = false;
          _setupMarkersAndRoute();
        });
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (mounted) {
        setState(() => _isMapLoading = false);
      }
    }
  }

  void _setupMarkersAndRoute() {
    if (_currentPosition == null) return;
    
    final LatLng userLoc = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    setState(() {
      // Add Markers
      _markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLocation,
        infoWindow: const InfoWindow(title: 'Blinkit Hub'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));

      _markers.add(Marker(
        markerId: const MarkerId('delivery'),
        position: userLoc,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));

      // Add simple direct polyline (In real app, use Directions API)
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: [_pickupLocation, userLoc],
        color: const Color(0xFF2D7A3E),
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ));
    });

    // Zoom to fit both points
    _fitBounds();
  }

  void _fitBounds() {
    if (_mapController == null || _currentPosition == null) return;
    
    final LatLng userLoc = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    
    LatLngBounds bounds;
    if (_pickupLocation.latitude > userLoc.latitude) {
      bounds = LatLngBounds(southwest: userLoc, northeast: _pickupLocation);
    } else {
      bounds = LatLngBounds(southwest: _pickupLocation, northeast: userLoc);
    }

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _generateParticles() {
    final random = math.Random();
    final emojis = ['🔥', '🎁', '✨', '🎈', '🎉', '💥'];
    for (int i = 0; i < 50; i++) {
      _particles.add(EmojiParticle(
        emoji: emojis[random.nextInt(emojis.length)],
        angle: random.nextDouble() * 2 * math.pi,
        speed: random.nextDouble() * 4 + 2,
        size: random.nextDouble() * 20 + 20,
      ));
    }
  }

  void _startTimer() {
    _orderTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _orderTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _orderTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E17) : const Color(0xFFF5F7F9),
      body: Stack(
        children: [
          // Celebration Animation
          if (!_showOrderCard)
            Center(
              child: Stack(
                children: _particles.map((p) {
                  double progress = _celebrationController.value;
                  double dx = math.cos(p.angle) * p.speed * 100 * progress;
                  double dy = math.sin(p.angle) * p.speed * 100 * progress + (progress * progress * 200);
                  double opacity = (1 - progress).clamp(0.0, 1.0);
                  
                  return Transform.translate(
                    offset: Offset(dx, dy),
                    child: Opacity(
                      opacity: opacity,
                      child: Text(p.emoji, style: TextStyle(fontSize: p.size)),
                    ),
                  );
                }).toList(),
              ),
            ),

          if (!_showOrderCard)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Processing Order...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: Colors.blueAccent),
                ],
              ),
            ),

          // Order Success Card
          if (_showOrderCard)
            AnimatedOpacity(
              opacity: _showOrderCard ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: math.min(MediaQuery.of(context).size.width * 0.9, 450),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F202D) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with status
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2D7A3E),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.check_circle, size: 64, color: Colors.white),
                              const SizedBox(height: 12),
                              const Text(
                                'Order Placed!',
                                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Order #${widget.orderId}',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                              ),
                            ],
                          ),
                          ),
                        ),
                        
                        // Map Section
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _isMapLoading 
                              ? const Center(child: CircularProgressIndicator())
                              : GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _pickupLocation,
                                    zoom: 12,
                                  ),
                                  onMapCreated: (controller) {
                                    _mapController = controller;
                                    if (_currentPosition != null) _fitBounds();
                                  },
                                  markers: _markers,
                                  polylines: _polylines,
                                  zoomControlsEnabled: false,
                                  myLocationButtonEnabled: false,
                                  mapToolbarEnabled: false,
                                  style: isDark ? _darkMapStyle : null,
                                ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // Timer Section
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('Arriving in', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                                      Text(
                                        _formatTime(_secondsRemaining),
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // User & Order Info Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow('User Name', widget.userName, isDark),
                                    _buildInfoRow('User ID', widget.userId, isDark),
                                    const Divider(height: 24),
                                    _buildInfoRow('Order ID', widget.orderId, isDark),
                                    _buildInfoRow('Payment Mode', widget.paymentMode, isDark),
                                    if (widget.transactionId != null)
                                      _buildInfoRow('Transaction ID', widget.transactionId!, isDark),
                                    _buildInfoRow('Status', widget.status, isDark, valueColor: widget.status == 'Online' ? Colors.blue : Colors.orange),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              Text('Product Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                              const SizedBox(height: 8),
                              ...widget.cartItems.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Text('${item['qty']}x ', style: const TextStyle(color: Colors.grey)),
                                    Expanded(child: Text(item['name'], style: TextStyle(color: isDark ? Colors.white70 : Colors.black87))),
                                    Text('₹${item['price']}', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
                                  ],
                                ),
                              )),
                              const Divider(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text('₹${widget.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D7A3E))),
                                ],
                              ),
                              const SizedBox(height: 32),
                              
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2D7A3E),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(color: valueColor ?? (isDark ? Colors.white70 : Colors.black87), fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  static const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#746855"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#242f3e"}]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#d59563"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#263c3f"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6b9a76"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#38414e"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#212a37"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9ca5b3"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#746855"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#1f2835"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#f3d19c"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#17263c"}]
  }
]
''';
}

class EmojiParticle {
  final String emoji;
  final double angle;
  final double speed;
  final double size;

  EmojiParticle({
    required this.emoji,
    required this.angle,
    required this.speed,
    required this.size,
  });
}

extension RowAnim on Widget {
  Widget animateRow() {
    return this; // Placeholder for additional row animations if needed
  }
}
