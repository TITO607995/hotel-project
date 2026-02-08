import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard.dart';
import 'package:frontend/pages/data_reservasi_page.dart';
import 'package:frontend/pages/registration_page.dart';
import 'package:frontend/pages/reservation_page.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart'; // Import Header modular baru
import '../models/room_model.dart';
import '../services/api_service.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  String _currentView = "room_data"; 
  List<Room> _rooms = []; 
  bool _isLoading = true;

  // State untuk Dropdown OO/OS
  int? _selectedRoomId;
  String _selectedStatus = "oo";

  // Controller untuk Setting Harga
  final Map<String, TextEditingController> _priceControllers = {
    "Standard": TextEditingController(),
    "Deluxe": TextEditingController(),
    "Suite": TextEditingController(),
    "Executive": TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _fetchRooms(); 
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Fungsi ambil data dari Laravel & Sinkronisasi Harga
  void _fetchRooms() async {
    try {
      List<Room> data = await ApiService().getRooms(); 
      setState(() {
        _rooms = data; 
        _isLoading = false;

        for (var type in _priceControllers.keys) {
          var roomWithType = _rooms.firstWhere(
            (r) => r.type == type,
            orElse: () => Room(id: 0, roomNumber: '', type: type, price: 0, status: '', image: null),
          );
          if (roomWithType.price > 0) {
            _priceControllers[type]?.text = roomWithType.price.toString();
          }
        }
      });
    } catch (e) {
      print("Error Sinkronisasi: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar Kiri
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
          
          // 2. Area Konten Kanan
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Column(
                children: [
                  // MENGGUNAKAN HEADER MODULAR
                  const Header(title: "Manajemen Data Kamar"), 
                  
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000))) 
                      : SingleChildScrollView(child: _buildMainContent()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NAVIGASI VIEW ---
  Widget _buildMainContent() {
    switch (_currentView) {
      case "room_data":
        return _buildRoomDataGrid();
      case "room_price_setting":
        return _buildPriceSettingView();
      case "room_status_setting":
        return _buildStatusSettingView();
      case "room_status_data":
        return _buildStatusDataView();
      default:
        return _buildRoomDataGrid();
    }
  }

  // --- 1. VIEW: DATA KAMAR (GRID) ---
  Widget _buildRoomDataGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemCount: _rooms.length,
      itemBuilder: (context, index) => _buildRoomCard(_rooms[index]),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Container(
                width: double.infinity,
                color: Colors.grey[200], 
                child: const Icon(Icons.hotel, size: 50, color: Colors.white)
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ROOM ${room.roomNumber}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Type: ${room.type}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text("Harga: Rp ${room.price}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B0000))),
                const SizedBox(height: 10),
                _buildStatusBadge(room.status),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 2. VIEW: SETTING HARGA ---
  Widget _buildPriceSettingView() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Card(
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Tipe Kamar")),
            DataColumn(label: Text("Harga Baru")),
            DataColumn(label: Text("Aksi")),
          ],
          rows: _priceControllers.entries.map((entry) => DataRow(cells: [
            DataCell(Text(entry.key)),
            DataCell(TextField(controller: entry.value, decoration: const InputDecoration(prefixText: "Rp "))),
            DataCell(ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
              onPressed: () async {
                bool success = await ApiService().updateRoomPrice(entry.key, int.parse(entry.value.text));
                if (success) _fetchRooms();
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            )),
          ])).toList(),
        ),
      ),
    );
  }

  // --- 3. VIEW: INPUT OO/OS ---
  Widget _buildStatusSettingView() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Pilih Nomor Kamar", border: OutlineInputBorder()),
                value: _selectedRoomId,
                items: _rooms.map((room) => DropdownMenuItem(value: room.id, child: Text("Kamar ${room.roomNumber} (${room.type})"))).toList(),
                onChanged: (val) => setState(() => _selectedRoomId = val),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Ubah Status", border: OutlineInputBorder()),
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: "oo", child: Text("Out of Order (Rusak)")),
                  DropdownMenuItem(value: "os", child: Text("Out of Service (Maintenance)")),
                  DropdownMenuItem(value: "Available", child: Text("Tersedia Kembali")),
                ],
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000), minimumSize: const Size(double.infinity, 50)),
                onPressed: () async {
                  if (_selectedRoomId != null) {
                    bool success = await ApiService().updateRoomStatus(_selectedRoomId!, _selectedStatus);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status Berhasil Diupdate!")));
                      _fetchRooms();
                    }
                  }
                },
                child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 4. VIEW: DATA OO/OS ---
  Widget _buildStatusDataView() {
    final maintenanceRooms = _rooms.where((r) => r.status.toLowerCase() == "oo" || r.status.toLowerCase() == "os").toList();
    return Padding(
      padding: const EdgeInsets.all(30),
      child: maintenanceRooms.isEmpty 
        ? const Center(child: Text("Semua kamar dalam kondisi baik."))
        : ListView.builder(
            shrinkWrap: true,
            itemCount: maintenanceRooms.length,
            itemBuilder: (context, index) {
              final room = maintenanceRooms[index];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.warning, color: room.status == "oo" ? Colors.red : Colors.orange),
                  title: Text("Kamar ${room.roomNumber}"),
                  subtitle: Text("Status: ${room.status.toUpperCase()}"),
                  trailing: Text("Rp ${room.price}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
    );
  }

  // --- BADGE STATUS ---
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'available': color = Colors.green; break;
      case 'booking': color = Colors.orange; break;
      case 'terisi': color = Colors.blue; break;
      case 'oo': color = Colors.red; break;
      case 'os': color = Colors.grey; break;
      default: color = Colors.black;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}