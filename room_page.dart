import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../models/room_model.dart';
import '../services/api_service.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  String _currentView = "room_data"; 
  List<Room> _rooms = []; // Ini variabel yang bikin error tadi, pastikan pakai underscore (_)
  bool _isLoading = true;

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
    _fetchRooms(); // Ambil data saat halaman dibuka
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Fungsi ambil data dari Laravel
  void _fetchRooms() async {
    try {
      List<Room> data = await ApiService().getRooms(); 
      setState(() {
        _rooms = data; // Simpan ke variabel state
        _isLoading = false;

        // Sinkronkan harga ke TextField
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
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            currentView: _currentView,
            onViewChanged: (view) => setState(() => _currentView = view),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Column(
                children: [
                  _buildHeader(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Halo, Galang resepsionis",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Row(
            children: [
              const Icon(Icons.school, color: Colors.blue, size: 35),
              const SizedBox(width: 10),
              const Icon(Icons.hotel, color: Color(0xFF8B0000), size: 35),
              const SizedBox(width: 20),
              const CircleAvatar(backgroundColor: Colors.pink, radius: 18),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentView) {
      case "room_data":
        return _buildRoomDataGrid(); // Panggil tanpa parameter
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

  // 1. FIXED: Fungsi Grid Data Kamar (Menggunakan _rooms)
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
      itemCount: _rooms.length, // Pakai _rooms
      itemBuilder: (context, index) => _buildRoomCard(_rooms[index]),
    );
  }

  Widget _buildRoomCard(Room room) { // Tambahkan parameter Room di sini
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
                color: Colors.grey[300], 
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
                Text("type : ${room.type}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text("Harga : Rp ${room.price}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B0000))),
                const SizedBox(height: 10),
                _buildStatusBadge(room.status),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 2. VIEW: SETTING HARGA KAMAR
  Widget _buildPriceSettingView() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Setting Harga Kamar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Tipe Kamar")),
                DataColumn(label: Text("Harga")),
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
          )
        ],
      ),
    );
  }

  // 3. VIEW: SETTING OO/OS
int? _selectedRoomId;
String _selectedStatus = "oo";

// --- VIEW: SETTING OO/OS ---
Widget _buildStatusSettingView() {
  return Padding(
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Input Status OO / OS", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Dropdown Pilih Nomor Kamar (Dari 38 kamar yang sudah di-fetch)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Pilih Nomor Kamar", border: OutlineInputBorder()),
                  value: _selectedRoomId,
                  items: _rooms.map((room) {
                    return DropdownMenuItem(value: room.id, child: Text("Kamar ${room.roomNumber} (${room.type})"));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedRoomId = val),
                ),
                const SizedBox(height: 20),
                // Dropdown Pilih Status
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Ubah Status Menjadi", border: OutlineInputBorder()),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    if (_selectedRoomId != null) {
                      bool success = await ApiService().updateRoomStatus(_selectedRoomId!, _selectedStatus);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status Berhasil Diperbarui!")));
                        _fetchRooms(); // Refresh data agar grid & list terupdate
                      }
                    }
                  },
                  child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// --- VIEW: DATA OO/OS (Daftar Kamar Rusak) ---
Widget _buildStatusDataView() {
  // Filter hanya kamar yang statusnya oo atau os
  final maintenanceRooms = _rooms.where((r) => r.status.toLowerCase() == "oo" || r.status.toLowerCase() == "os").toList();

  return Padding(
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Daftar Kamar Dalam Perbaikan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        maintenanceRooms.isEmpty 
          ? const Center(child: Text("Semua kamar dalam kondisi baik."))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: maintenanceRooms.length,
              itemBuilder: (context, index) {
                final room = maintenanceRooms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(Icons.warning, color: room.status == "oo" ? Colors.red : Colors.orange),
                    title: Text("Kamar ${room.roomNumber} - ${room.type}"),
                    subtitle: Text("Status: ${room.status.toUpperCase()}"),
                    trailing: Text("Rp ${room.price}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
      ],
    ),
  );
}

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'available': color = Colors.green; break;
      case 'booking': color = Colors.orange; break;
      case 'terisi': color = Colors.red; break;
      case 'oo': color = Colors.blue; break;
      case 'os': color = Colors.grey; break;
      default: color = Colors.black;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}