import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'room_page.dart'; // Import untuk navigasi

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _currentView = "dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar Kiri (Konsisten dengan RoomPage)
          Sidebar(
            currentView: _currentView,
            onViewChanged: (view) {
              if (view == "room_data") {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomPage()));
              } else {
                setState(() => _currentView = view);
              }
            },
          ),

          // 2. Konten Utama
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5), // Background abu-abu muda Figma
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ringkasan Hotel Hari Ini",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          
                          // Statistik Berdasarkan 38 Kamar yang Kita Buat
                          Row(
                            children: [
                              _buildStatCard("Total Kamar", "38", Colors.blue),
                              const SizedBox(width: 15),
                              _buildStatCard("Tersedia", "38", Colors.green),
                              const SizedBox(width: 15),
                              _buildStatCard("Perlu Maintenance (OO/OS)", "0", Colors.orange),
                            ],
                          ),
                          
                          const SizedBox(height: 40),
                          const Text(
                            "Akses Cepat Menu",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          // Grid Menu dengan Desain Lebih Modern
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 3, // Diubah jadi 3 agar lebih pas di layar laptop
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            children: [
                              _buildMenuCard(Icons.bed, "Manajemen Kamar", () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomPage()));
                              }),
                              _buildMenuCard(Icons.book_online, "Reservasi Tamu", () {}),
                              _buildMenuCard(Icons.people, "Data Pengunjung", () {}),
                              _buildMenuCard(Icons.price_check, "Setting Harga", () {}),
                              _buildMenuCard(Icons.build, "Status OO/OS", () {}),
                              _buildMenuCard(Icons.logout, "Keluar Sistem", () {
                                Navigator.pushReplacementNamed(context, '/login');
                              }),
                            ],
                          ),
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

  // Header Sesuai Figma image_f0e0db.png
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Row(
            children: [
              const Icon(Icons.school, color: Colors.blue, size: 35),
              const SizedBox(width: 10),
              const Icon(Icons.hotel, color: Color(0xFF8B0000), size: 35),
              const SizedBox(width: 20),
              const CircleAvatar(
                backgroundColor: Colors.pinkAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border(left: BorderSide(color: color, width: 5)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: const Color(0xFF8B0000)),
            ),
            const SizedBox(height: 15),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}