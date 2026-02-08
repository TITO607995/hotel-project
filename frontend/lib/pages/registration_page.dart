import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:frontend/pages/data_reservasi_page.dart';
import 'package:frontend/pages/reservation_page.dart';
import 'package:frontend/pages/room_page.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../services/api_service.dart';

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});

  @override
  State<RegistrasiPage> createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  String _currentView = "reservasi_checkin";
  List<dynamic> _pendingList = [];
  dynamic _selectedBooking;
  bool _isLoading = true;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _paymentMethod;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  void _loadPending() async {
    try {
      final data = await ApiService().getPendingReservations();
      setState(() {
        _pendingList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Isi form otomatis saat nama tamu dipilih
  void _onGuestSelected(dynamic booking) {
    setState(() {
      _selectedBooking = booking;
      _nameController.text = booking['guest_name'];
      _countryController.text = booking['country'] ?? "";
      _cityController.text = booking['city'] ?? "";
      _phoneController.text = booking['phone'] ?? "";
      _paymentMethod = booking['payment_method'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            currentView: _currentView,
            onViewChanged: (view) {
              if (view == "dashboard") {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
              } 
              // Navigasi ke sub-menu Reservasi
              else if (view == "reservasi_create") {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ReservasiPage()));
              } 
              else if (view == "reservasi_checkin") {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegistrasiPage()));
              } 
              else if (view == "reservasi_data") {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DataReservasiPage()));
              }
              // Navigasi ke menu Kamar
              else if (view.startsWith("room_")) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RoomPage()));
              }
            },
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFE5E5E5),
              child: Column(
                children: [
                  const Header(),
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            children: [
                              _buildSelectionCard(), // Pilih tamu dulu
                              const SizedBox(height: 20),
                              if (_selectedBooking != null) _buildRegistrationCard(),
                            ],
                          ),
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

  Widget _buildSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: DropdownButtonFormField<dynamic>(
        decoration: const InputDecoration(labelText: "Pilih Tamu Booking untuk Check-in", border: OutlineInputBorder()),
        items: _pendingList.map((b) => DropdownMenuItem(value: b, child: Text("${b['guest_name']} - Kamar ${b['room_type']}"))).toList(),
        onChanged: _onGuestSelected,
      ),
    );
  }

  Widget _buildRegistrationCard() {
    bool isNonGaransi = _selectedBooking['reservation_type'] == 'non-guaranteed';

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("REGISTRATION CARD (CHECK-IN)", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTextField("Lead Guest", _nameController)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField("Country", _countryController)),
            ],
          ),
          const SizedBox(height: 15),
          _buildTextField("Phone", _phoneController),
          const SizedBox(height: 20),
          
          // INFO PEMBAYARAN UNTUK NON-GARANSI
          if (isNonGaransi) 
            Container(
              padding: const EdgeInsets.all(15),
              color: Colors.orange[50],
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 10),
                  Text("Tamu Non-Garansi: Pastikan pembayaran lunas sebelum Check-in!", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          
          const SizedBox(height: 20),
          _buildDropdown("Konfirmasi Pembayaran", ["Cash", "Transfer", "Credit Card"], (val) => _paymentMethod = val),
          const SizedBox(height: 30),
          
          ElevatedButton(
            onPressed: () async {
              bool success = await ApiService().processCheckIn(_selectedBooking['id'], {
                "payment_method": _paymentMethod,
              });
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check-in Berhasil! Kamar sudah Terisi.")));
                Navigator.pushReplacementNamed(context, '/dashboard');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000), minimumSize: const Size(double.infinity, 55)),
            child: const Text("PROSES CHECK-IN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(controller: controller, readOnly: true, decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.grey[100], border: const OutlineInputBorder()));
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: _paymentMethod,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}