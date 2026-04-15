import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AddAddressPage extends StatefulWidget {
  final bool isDarkMode;
  const AddAddressPage({super.key, required this.isDarkMode});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(28.6139, 77.2090); // Default: Delhi
  String _selectedTag = 'Home';
  
  final TextEditingController _flatController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isMapLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isMapLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isMapLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isMapLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isMapLoading = false;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;
    final Size size = MediaQuery.of(context).size;
    final bool isWide = size.width > 900;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0E17) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D0E17) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enter complete address',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 3, child: _buildMapSection()),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 2, 
                  child: SingleChildScrollView(
                    child: _buildFormSection()
                  )
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 350, child: _buildMapSection()),
                  _buildFormSection(),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildMapSection() {
    return Stack(
      children: [
        if (_isMapLoading)
          const Center(child: CircularProgressIndicator(color: Color(0xFF2D7A3E)))
        else
          SizedBox(
            height: 350,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 16,
              ),
              onMapCreated: (controller) => _mapController = controller,
              zoomControlsEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('current'),
                  position: _currentPosition,
                  draggable: true,
                  onDragEnd: (newPos) {
                    setState(() => _currentPosition = newPos);
                  },
                ),
              },
            ),
          ),
        
        // Search Bar on Map
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            decoration: BoxDecoration(
              color: widget.isDarkMode ? const Color(0xFF1F202D) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for area, street name...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Current Location Button
        Positioned(
          bottom: 20,
          left: 20,
          child: GestureDetector(
            onTap: _determinePosition,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: Row(
                children: const [
                  Icon(Icons.my_location, color: Color(0xFF2D7A3E), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Go to current location',
                    style: TextStyle(color: Color(0xFF2D7A3E), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Deliver To Info Card
        Positioned(
          bottom: 80,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? const Color(0xFF1F202D) : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Delivering your order to', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gaur City 1', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'Sector 4, Greater Noida',
                            style: TextStyle(fontSize: 12, color: widget.isDarkMode ? Colors.white54 : Colors.black54),
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
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Save address as*', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTag('Home', Icons.home_filled),
              const SizedBox(width: 8),
              _buildTag('Work', Icons.work),
              const SizedBox(width: 8),
              _buildTag('Hotel', Icons.hotel),
              const SizedBox(width: 8),
              _buildTag('Other', Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField('Flat / House no / Building name *', _flatController),
          const SizedBox(height: 16),
          _buildTextField('Floor (optional)', _floorController),
          const SizedBox(height: 16),
          _buildTextField('Area / Sector / Locality *', _areaController, initialValue: 'Gaur City 1, Sector 4, Greater Noida'),
          const SizedBox(height: 16),
          _buildTextField('Nearby landmark (optional)', _landmarkController),
          const SizedBox(height: 24),
          const Text('Enter your details for seamless delivery experience', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          _buildTextField('Your name *', _nameController),
          const SizedBox(height: 16),
          _buildTextField('Your phone number (optional)', _phoneController, initialValue: '7360842275'),
          const SizedBox(height: 32),
          _buildSaveButton(),
          const SizedBox(height: 40), // Extra space at bottom
        ],
      ),
    );
  }

  Widget _buildTag(String label, IconData icon) {
    final bool isSelected = _selectedTag == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTag = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF2FFF5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2D7A3E) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? const Color(0xFF2D7A3E) : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF2D7A3E) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? initialValue}) {
    if (initialValue != null && controller.text.isEmpty) {
      controller.text = initialValue;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            final newAddr = {
              'type': _selectedTag,
              'address': '${_flatController.text}, ${_areaController.text}',
              'icon': _selectedTag.toLowerCase(),
            };
            Navigator.pop(context, newAddr);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D7A3E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: const Text('Save Address', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
