import 'package:flutter/material.dart';
import 'package:frontend/pages/data_reservasi_page.dart';
import 'package:frontend/pages/registration_page.dart';
import 'package:frontend/pages/reservation_page.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../models/room_model.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _currentView = "dashboard";
  List<Room> _rooms = [];
  List<dynamic> _stats = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    try {
      final response = await ApiService().getDashboardStats(); 
      setState(() {
        _rooms = (response['rooms'] as List).map((e) => Room.fromJson(e)).toList();
        _stats = response['stats']; 
        _isLoading = false;
      });
    } catch (e) {
      print("Error Dashboard: $e");
      setState(() => _isLoading = false);
    }
  }

  // LOGIKA STATUS KIRI (Time & Guarantee Based)
  String _getLeftStatus(Room room) {
    int currentHour = DateTime.now().hour;
    String status = room.status.toLowerCase();
    bool isGuaranteed = room.isPaid; 
    bool isCheckIn = status == 'occupied' || status == 'terisi';

    if (isCheckIn) {
      if (currentHour >= 12 && currentHour < 14) return "Dirty";
      return "Occupied In-house"; 
    } 

    if (status == 'booking') {
      if (isGuaranteed) {
        return "Booked In-house"; 
      } else {
        if (currentHour >= 0 && currentHour < 6) {
          return "Booked (Pending Cancel)"; 
        }
        return "Booked";
      }
    }

    return "-";
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
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000)))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          child: Column(
                            children: [
                              _buildStatCardsRow(),
                              const SizedBox(height: 30),
                              _buildRoomTableSection(),
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

  Widget _buildStatCardsRow() {
    return Row(
      children: _stats.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _buildTypeStatCard("Kamar ${item['type']}", item['total'], item['sisa']),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeStatCard(String title, int total, int sisa) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF8B0000), fontSize: 18, fontWeight: FontWeight.bold)),
          Text("$total", style: const TextStyle(color: Color(0xFF8B0000), fontSize: 50, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("kamar sisa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF8B0000), borderRadius: BorderRadius.circular(15)),
                child: Text("$sisa", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRoomTableSection() {
    final filteredRooms = _rooms.where((r) => r.status.toLowerCase() != 'available').toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Daftar Aktivitas Kamar", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1), 1: FlexColumnWidth(1.2), 2: FlexColumnWidth(1.5), 
              3: FlexColumnWidth(1.5), 4: FlexColumnWidth(1), 5: FlexColumnWidth(1.2), 6: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[200]),
                children: const [
                  _TableCell(text: "Room No", isHeader: true),
                  _TableCell(text: "Type", isHeader: true),
                  _TableCell(text: "Status", isHeader: true),
                  _TableCell(text: "Reservasi", isHeader: true),
                  _TableCell(text: "Payment", isHeader: true),
                  _TableCell(text: "", isHeader: true),
                  _TableCell(text: "Visibility", isHeader: true),
                ],
              ),
              ...filteredRooms.map((room) {
                bool isMaintenance = room.status.toLowerCase() == 'oo' || room.status.toLowerCase() == 'os';
                return TableRow(
                  children: [
                    _TableCell(text: room.roomNumber),
                    _TableCell(text: room.type),
                    _TableCell(text: _getLeftStatus(room)), 
                    _TableCell(text: isMaintenance ? "-" : (room.paymentMethod ?? "Belum Input")),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: isMaintenance 
                          ? const Center(child: Text("-")) 
                          : Icon(room.isPaid ? Icons.check_circle : Icons.cancel, 
                                 color: room.isPaid ? Colors.green : Colors.red, size: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildStatusBadge(room.status),
                    ),
                    GestureDetector(
                      onTap: () => _showVisibilityPopup(room),
                      child: _TableCell(text: room.visibilityMode ?? "Public", isLink: true),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  // Fungsi Pop-up dan Badge Status tetap sama seperti sebelumnya
  void _showVisibilityPopup(Room room) {
    // Controller untuk mengisi alasan kenapa tamu minta Incognito
    TextEditingController reasonController = 
        TextEditingController(text: room.visibilityDescription);
    String tempMode = room.visibilityMode ?? "Public";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Setting Visibilitas Kamar ${room.roomNumber}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown Pilih Mode
            DropdownButtonFormField<String>(
              value: tempMode,
              items: const [
                DropdownMenuItem(value: "Public", child: Text("Public")),
                DropdownMenuItem(value: "Incognito", child: Text("Incognito")),
              ],
              onChanged: (val) => tempMode = val!,
              decoration: const InputDecoration(
                labelText: "Pilih Mode",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Input Alasan untuk laporan FO
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: "Keterangan FO (Alasan Incognito)",
                border: OutlineInputBorder(),
                hintText: "Contoh: Permintaan privasi tamu VIP",
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000), // Warna Maroon Proyekmu
            ),
            onPressed: () async {
              // Kirim data ke Laravel melalui ApiService
              bool success = await ApiService().updateVisibility(
                room.id, 
                tempMode, 
                reasonController.text
              );

              if (success) {
                if (mounted) {
                  Navigator.pop(context);
                  _fetchData(); // Refresh data Dashboard agar status berubah
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Visibilitas berhasil diperbarui!"))
                  );
                }
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'terisi':
      case 'occupied': color = const Color(0xFF8B0000); break;
      case 'booking': color = Colors.orange; break;
      case 'oo': color = Colors.black; break;
      case 'os': color = Colors.grey; break;
      default: color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), textAlign: TextAlign.center, 
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool isLink;
  const _TableCell({required this.text, this.isHeader = false, this.isLink = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(text, style: TextStyle(
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        fontSize: 14, color: isLink ? Colors.blue : Colors.black,
        decoration: isLink ? TextDecoration.underline : TextDecoration.none,
      )),
    );
  }
}