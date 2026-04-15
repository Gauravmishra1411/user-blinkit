import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final bool isDarkMode;
  final String selectedAddress;
  final String selectedAddressType;
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  const PaymentPage({
    super.key,
    required this.isDarkMode,
    required this.selectedAddress,
    required this.selectedAddressType,
    required this.totalAmount,
    required this.cartItems,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _expandedMethod; // 'card', 'upi', etc.
  bool _isQrGenerated = false;

  @override
  void initState() {
    super.initState();
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
    final bool isDark = widget.isDarkMode;
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
        color: widget.isDarkMode ? const Color(0xFF1F202D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.isDarkMode ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          _paymentTile('Wallets', Icons.wallet, 'wallets'),
          _divider(),
          _paymentTile('Add credit or debit cards', Icons.credit_card, 'card'),
          if (_expandedMethod == 'card') _buildCardForm(),
          _divider(),
          _paymentTile('Netbanking', Icons.account_balance, 'netbanking'),
          _divider(),
          _paymentTile('UPI', Icons.mobile_screen_share, 'upi'),
          if (_expandedMethod == 'upi') _buildUpiQr(),
          _divider(),
          _paymentTile(
            'Cash', 
            Icons.money, 
            'cash',
            subtitle: 'Cash on delivery is not applicable on first order with item total less than ₹100',
            isDisabled: widget.totalAmount < 100,
          ),
          _divider(),
          _paymentTile('Pay Later', Icons.timer_outlined, 'paylater'),
        ],
      ),
    );
  }

  Widget _paymentTile(String title, IconData icon, String methodId, {String? subtitle, bool isDisabled = false}) {
    final bool isExpanded = _expandedMethod == methodId;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Icon(icon, color: isDisabled ? Colors.grey : (widget.isDarkMode ? Colors.white70 : Colors.black87)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDisabled ? Colors.grey : (widget.isDarkMode ? Colors.white : Colors.black),
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
        });
      },
    );
  }

  Widget _buildCardForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      color: widget.isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              _cardLogo('VISA'),
              const SizedBox(width: 8),
              _cardLogo('MasterCard'),
              const SizedBox(width: 8),
              _cardLogo('RuPay'),
            ],
          ),
          const SizedBox(height: 20),
          _field('Name on Card'),
          const SizedBox(height: 12),
          _field('Card Number'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field('Expiry Date (MM/YY)')),
              const SizedBox(width: 12),
              Expanded(child: _field('CVV')),
            ],
          ),
          const SizedBox(height: 12),
          _field('Nickname for card (Optional)'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _navigateToThankYou(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7A3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We accept Credit and Debit Cards from Visa, Mastercard, Rupay, Pluxee, American Express & Diners.',
            style: TextStyle(fontSize: 10, color: widget.isDarkMode ? Colors.white38 : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiQr() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      color: widget.isDarkMode ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.02),
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
                    child: TextButton(
                      onPressed: () => _navigateToThankYou(),
                      child: const Text('Done Payment?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardLogo(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
    );
  }

  Widget _upiIcon(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _field(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _navigateToThankYou() {
    final String orderId = 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ThankYouPage(
          isDarkMode: widget.isDarkMode,
          orderId: orderId,
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: widget.isDarkMode ? Colors.white10 : Colors.black12, thickness: 1);
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1F202D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.isDarkMode ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Address', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '${widget.selectedAddressType}: ${widget.selectedAddress}',
            style: TextStyle(
              fontSize: 13,
              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
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
                    style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
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
              onPressed: () => _navigateToThankYou(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D7A3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Pay Now ₹${widget.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThankYouPage extends StatelessWidget {
  final bool isDarkMode;
  final String orderId;
  const ThankYouPage({super.key, required this.isDarkMode, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0D0E17) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF2D7A3E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your order has been placed successfully. We are preparing it for delivery.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode ? Colors.white12 : Colors.black12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Order ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white38 : Colors.black38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#$orderId',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFF3D5AFE) : const Color(0xFF2D7A3E),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D7A3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension RowAnim on Widget {
  Widget animateRow() {
    return this; // Placeholder for additional row animations if needed
  }
}
