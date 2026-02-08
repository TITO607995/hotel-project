import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'room_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _currentView = "dashboard";

  void _navigateTo(String view) {
    setState(() => _currentView = view);
    // Navigasi ke Halaman Kamar
    if (view == "room_data" || view == "Manajemen Kamar") {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const RoomPage())
      );
    } 
    // Navigasi Logout
    else if (view == "logout") {
      Navigator.pushReplacementNamed(context, '/login');
    } 
    // Fitur lainnya
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          backgroundColor: const Color(0xFF1A1A1A),
          content: Text("🚀 Fitur $view akan segera hadir di update mendatang!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Background super clean
      body: Row(
        children: [
          // Sidebar Kiri
          Sidebar(
            currentView: _currentView,
            onViewChanged: _navigateTo,
          ),
          
          Expanded(
            child: Column(
              children: [
                _buildModernHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 35),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPremiumWelcome(),
                        const SizedBox(height: 35),
                        _buildStatSection(),
                        const SizedBox(height: 50),
                        const Text(
                          "Layanan Cepat",
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.w900, 
                            letterSpacing: -0.5,
                            color: Color(0xFF1A1A1A)
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildModernGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "DASHBOARD ANALYTICS",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.5, color: Colors.blueGrey),
          ),
          Row(
            children: [
              _headerIcon(Icons.search_rounded),
              const SizedBox(width: 15),
              _headerIcon(Icons.notifications_none_rounded),
              const SizedBox(width: 25),
              const VerticalDivider(indent: 30, endIndent: 30, thickness: 1.5),
              const SizedBox(width: 25),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Zaky Administrator", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  Text("Hotel Manager", style: TextStyle(fontSize: 12, color: Color(0xFF8B0000), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 20),
              // PERBAIKAN ICON DISINI: Icons.person_rounded
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF8B0000), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF1A1A1A),
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.black87, size: 22),
    );
  }

  Widget _buildPremiumWelcome() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selamat Datang, Zaky! 👋",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.black.withOpacity(0.85)),
            ),
            const SizedBox(height: 5),
            const Text("Sistem manajemen hotel terpantau aman hari ini.",
                style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
        _buildActionButton(Icons.add_rounded, "Check-In Baru"),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: const Color(0xFF8B0000).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B0000),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildStatSection() {
    return Row(
      children: [
        _buildStatCard("KAMAR TOTAL", "38", Icons.door_front_door_rounded, [const Color(0xFF2D3436), const Color(0xFF636E72)]),
        const SizedBox(width: 25),
        _buildStatCard("TERSEDIA", "38", Icons.check_circle_rounded, [const Color(0xFF00B894), const Color(0xFF55E6C1)]),
        const SizedBox(width: 25),
        _buildStatCard("PERBAIKAN", "0", Icons.handyman_rounded, [const Color(0xFFD63031), const Color(0xFFFF7675)]),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, List<Color> colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 10),
                Text(count, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
            Icon(icon, size: 50, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 30,
      mainAxisSpacing: 30,
      childAspectRatio: 1.4,
      children: [
        _buildMenuCard(Icons.bed_rounded, "Manajemen Kamar", "Kelola semua tipe & unit", () => _navigateTo("Manajemen Kamar")),
        _buildMenuCard(Icons.calendar_month_rounded, "Reservasi", "Data check-in & booking", () => _navigateTo("reservasi")),
        _buildMenuCard(Icons.people_alt_rounded, "Pengunjung", "Database tamu menginap", () => _navigateTo("pengunjung")),
        _buildMenuCard(Icons.receipt_long_rounded, "Laporan", "History transaksi hotel", () => _navigateTo("laporan")),
        _buildMenuCard(Icons.settings_rounded, "Pengaturan", "Konfigurasi sistem & harga", () => _navigateTo("pengaturan")),
        _buildMenuCard(Icons.logout_rounded, "Keluar", "Selesaikan sesi kerja", () => _navigateTo("logout"), isDestructive: true),
      ],
    );
  }

  Widget _buildMenuCard(IconData icon, String label, String sub, VoidCallback onTap, {bool isDestructive = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDestructive ? Colors.red.withOpacity(0.1) : const Color(0xFF8B0000).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 32, color: isDestructive ? Colors.red : const Color(0xFF8B0000)),
              ),
              const SizedBox(height: 20),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D3436))),
              const SizedBox(height: 4),
              Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}