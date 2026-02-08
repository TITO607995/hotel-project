import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:frontend/pages/registration_page.dart';
import 'package:frontend/pages/reservation_page.dart';
import 'package:frontend/pages/room_page.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../services/api_service.dart';

class DataReservasiPage extends StatefulWidget {
  const DataReservasiPage({super.key});

  @override
  State<DataReservasiPage> createState() => _DataReservasiPageState();
}

class _DataReservasiPageState extends State<DataReservasiPage> {
  final String _currentView = "reservasi_data";
  List<dynamic> _allReservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final data = await ApiService().getAllReservations();
      setState(() {
        _allReservations = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(currentView: _currentView, 
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
                          child: _buildTableCard(),
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

  Widget _buildTableCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Data Seluruh Reservasi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Table(
            border: TableBorder.all(color: Colors.grey[300]!),
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[100]),
                children: const [
                  _Cell(text: "Nama Tamu", isHeader: true),
                  _Cell(text: "Tipe", isHeader: true),
                  _Cell(text: "Check-in", isHeader: true),
                  _Cell(text: "Status", isHeader: true),
                  _Cell(text: "Aksi", isHeader: true),
                ],
              ),
              ..._allReservations.map((res) => TableRow(
                children: [
                  _Cell(text: res['guest_name']),
                  _Cell(text: res['reservation_type']),
                  _Cell(text: res['arrival_date']),
                  _Cell(text: res['reservation_status']),
                  _buildActionButtons(res),
                ],
              )).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic res) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(res['id']),
        ),
      ],
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Reservasi?"),
        content: const Text("Kamar akan kembali Available setelah data dihapus."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              bool success = await ApiService().deleteReservation(id);
              if (success) {
                Navigator.pop(context);
                _loadData(); // Refresh list
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool isHeader;
  const _Cell({required this.text, this.isHeader = false});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(12), child: Text(text, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)));
  }
}