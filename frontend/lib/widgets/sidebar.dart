import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String currentView;
  final Function(String) onViewChanged;

  const Sidebar({
    super.key, 
    required this.currentView, 
    required this.onViewChanged
  });

  @override
  Widget build(BuildContext context) {
    // Cek apakah view saat ini merupakan bagian dari menu Kamar
    bool isRoomMenuOpen = currentView.startsWith("room_");

    return Container(
      width: 260,
      color: const Color(0xFF8B0000), // Maroon utama proyekmu
      child: Column(
        children: [
          // 1. LOGO SECTION (Sesuai Figma)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, color: Colors.white, size: 35),
                SizedBox(width: 12),
                Icon(Icons.hotel, color: Colors.white, size: 35),
              ],
            ),
          ),
          
          // 2. MENU UTAMA
          Expanded(
            child: SingleChildScrollView( // Agar tetap aman di layar laptop Acer ES 15
              child: Column(
                children: [
                  _buildSimpleMenu(Icons.dashboard, "Dashboard", "dashboard"),
                  _buildSimpleMenu(Icons.book_online, "Reservasi", "reservasi"),

                  // 3. DROPDOWN KAMAR (MODIFIED)
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: isRoomMenuOpen, // Tetap terbuka jika sub-menu aktif
                      leading: const Icon(Icons.bed, color: Colors.white),
                      title: const Text(
                        "Kamar", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                      trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      children: [
                        _buildSubMenu("Data Kamar", "room_data"),
                        _buildSubMenu("Setting Harga Kamar", "room_price_setting"),
                        _buildSubMenu("Setting OO/OS", "room_status_setting"),
                        _buildSubMenu("Data OO/OS", "room_status_data"),
                      ],
                    ),
                  ),

                  _buildSimpleMenu(Icons.people, "Tamu", "tamu"),
                  _buildSimpleMenu(Icons.bar_chart, "Laporan", "laporan"),
                ],
              ),
            ),
          ),

          // 4. FOOTER (Sesuai desain Figma timmu)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Web by 5NYeni",
              style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menu biasa
  Widget _buildSimpleMenu(IconData icon, String title, String viewName) {
    bool isSelected = currentView == viewName;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.yellow : Colors.white),
      title: Text(
        title, 
        style: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        )
      ),
      selected: isSelected,
      selectedTileColor: Colors.black26, // Efek highlight saat terpilih
      onTap: () => onViewChanged(viewName),
    );
  }

  // Widget untuk sub-menu di dalam dropdown
  Widget _buildSubMenu(String title, String viewName) {
    bool isSelected = currentView == viewName;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 70),
      title: Text(
        title, 
        style: TextStyle(
          color: isSelected ? Colors.yellow : Colors.white70, 
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        )
      ),
      dense: true,
      onTap: () => onViewChanged(viewName),
    );
  }
}