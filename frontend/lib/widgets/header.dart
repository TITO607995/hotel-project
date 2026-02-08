import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;

  const Header({
    super.key, 
    this.title = "Halo, Galang resepsionis" // Default sapaan buat kamu
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Judul / Sapaan
          Text(
            title,
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          // Bagian Logo & Profil
          Row(
            children: [
              // Logo Sekolah
              const Icon(Icons.school, color: Colors.blue, size: 35),
              const SizedBox(width: 15),
              // Logo Hotel (Maroon)
              const Icon(Icons.hotel, color: Color(0xFF8B0000), size: 35),
              const SizedBox(width: 25),
              // Garis Pembatas Tipis
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[300],
              ),
              const SizedBox(width: 25),
              // Avatar Profil
              const CircleAvatar(
                backgroundColor: Colors.pink,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}