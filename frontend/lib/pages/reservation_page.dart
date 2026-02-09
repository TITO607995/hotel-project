import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:frontend/pages/data_reservasi_page.dart';
import 'package:frontend/pages/registration_page.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../services/api_service.dart';

class ReservasiPage extends StatefulWidget {
  const ReservasiPage({super.key});

  @override
  State<ReservasiPage> createState() => _ReservasiPageState();
}

class _ReservasiPageState extends State<ReservasiPage> {
  String _currentView = "reservasi_create";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _guestsCountController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  List<dynamic> _availableRooms = [];
  String? _selectedRoomId;
  String? _selectedPayment;
  String? _selectedResType = "non-guaranteed";
  bool _isLoadingRooms = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailableRooms(); 
  }

  Future<void> _fetchAvailableRooms() async {
    try {
      final rooms = await ApiService().getAvailableRooms();
      setState(() {
        _availableRooms = rooms;
        _isLoadingRooms = false;
      });
    } catch (e) {
      print("Error Fetch Rooms: $e");
      setState(() => _isLoadingRooms = false);
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF8B0000)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _handleBtnSubmit() async {
    if (_nameController.text.isEmpty || _selectedRoomId == null || _selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi data wajib (Nama, Kamar, & Payment)!"))
      );
      return;
    }

    setState(() => _isSubmitting = true);


    Map<String, dynamic> formData = {
      "room_id": int.parse(_selectedRoomId!),
      "guest_name": _nameController.text,
      "country": _countryController.text,
      "num_guests": int.tryParse(_guestsCountController.text) ?? 1,
      "city": _cityController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "arrival_date": _arrivalController.text,
      "departure_date": _departureController.text,
      "place_birth": _dobController.text, 
      "payment_method": _selectedPayment, 
      "reservation_type": _selectedResType,
    };
    
    bool success = await ApiService().submitReservation(formData);

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reservasi Berhasil!")));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan data.")));
    }
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
              else if (view == "reservasi_create") {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ReservasiPage()));
              } 
              else if (view == "reservasi_checkin") {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegistrasiPage()));
              } 
              else if (view == "reservasi_data") {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DataReservasiPage()));
              }
              else if (view.startsWith("room_")) {
                setState(() {
                  _currentView = view; 
                });
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(30),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: _buildLeftPanel()),
                          const SizedBox(width: 30),
                          Expanded(flex: 2, child: _buildRegistrationCard()),
                        ],
                      ),
                    ),
                  ),
                  _buildFooterNote(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              _buildTimeButton("Check in", () => _selectDate(_arrivalController)),
              const SizedBox(height: 15),
              _buildTimeButton("Check out", () => _selectDate(_departureController)),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: const Column(
            children: [
              Text("Pilih Tanggal Kedatangan", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Icon(Icons.calendar_month, size: 200, color: Color(0xFF8B0000)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("RESERVATION CARD", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(child: _buildTextField("Lead Guest:", _nameController)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField("Country", _countryController)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildTextField("Number of guests", _guestsCountController)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField("City", _cityController)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildDateField("Arrival (YYYY-MM-DD)", _arrivalController)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField("Email address", _emailController)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildDateField("Departure (YYYY-MM-DD)", _departureController)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField("Number Telephone", _phoneController)),
            ],
          ),
          const SizedBox(height: 15),
          _buildTextField("PLACE & DATE OF BIRTH", _dobController),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _isLoadingRooms 
                  ? const LinearProgressIndicator()
                  : _buildDropdown(
                      "Pilih Kamar (Tersedia)", 
                      _availableRooms.map((r) => "No. ${r['room_number']} - ${r['type']}").toList(), 
                      (val) {
                        var selected = _availableRooms.firstWhere((r) => "No. ${r['room_number']} - ${r['type']}" == val);
                        setState(() => _selectedRoomId = selected['id'].toString());
                      }
                    ),
              ),
              const SizedBox(width: 20),
              Expanded(child: _buildDropdown("Reservation Type", ["guaranteed", "non-guaranteed"], (val) => setState(() => _selectedResType = val))),
            ],
          ),
          const SizedBox(height: 15),
          _buildDropdown("Payment Method", ["Cash", "Transfer", "Credit Card"], (val) => setState(() => _selectedPayment = val)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleBtnSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isSubmitting 
              ? const CircularProgressIndicator(color: Colors.white) 
              : const Text("SUBMIT", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: true, // User tidak boleh mengetik manual
          onTap: () => _selectDate(controller),
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTimeButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Color(0xFF8B0000)),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFF8B0000), fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFooterNote() {
    return Container(
      padding: const EdgeInsets.all(15),
      alignment: Alignment.bottomLeft,
      child: const Text(
        "*NOTE :\nCHECK IN TIME : AT 02.00 PM\nCHECK OUT TIME : AT 12.00 NOON",
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }
}