import 'dart:convert';
import 'package:frontend/models/room_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti IP dengan IP Laptop kamu (cek via ipconfig di CMD)
  static const String baseUrl = 'http://172.20.120.13:8000/api'; 

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Simpan token ke memori HP
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      
      return true;
    } else {
      return false;
    }
  }

  Future<List<Room>> getRooms() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('$baseUrl/rooms'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', // Kirim token di sini
    },
  );

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body)['data'];
    return data.map((json) => Room.fromJson(json)).toList();
  } else {
    throw Exception('Gagal mengambil data kamar');
  }
}

Future<bool> updateRoomPrice(String type, int price) async {
  SharedPreferences token = await SharedPreferences.getInstance();
  String? tokenStr = token.getString('token');

  final response = await http.post(
    Uri.parse('$baseUrl/rooms/update-price'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $tokenStr',
    },
    body: {
      'type': type,
      'price': price.toString(),
    },
  );

  return response.statusCode == 200;
}

Future<bool> updateRoomStatus(int roomId, String status) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  final response = await http.post(
    Uri.parse('$baseUrl/rooms/update-status'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: {
      'id': roomId.toString(),
      'status': status,
    },
  );

  return response.statusCode == 200;
}

Future<bool> updateVisibility(int roomId, String mode, String description) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  final response = await http.post(
    Uri.parse('$baseUrl/rooms/update-visibility'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: {
      'id': roomId.toString(),
      'visibility_mode': mode,
      'description': description,
    },
  );
  return response.statusCode == 200;
}

  Future<Map<String, dynamic>> getDashboardStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception('Gagal memuat data dashboard (Status: ${response.statusCode})');
      }
    } catch (e) {
      print("ApiService Error: $e");
      throw Exception('Terjadi kesalahan pada server atau koneksi internet.');
    }
  }

  
  Future<bool> submitReservation(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Error submitReservation: $e");
      return false;
    }
  }

  Future<List<dynamic>> getPendingReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/reservations/pending'), headers: await _getHeaders());
    return jsonDecode(response.body)['data'];
  }

  Future<bool> processCheckIn(int id, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservations/$id/check-in'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token', // Token dari Laravel Sanctum
    };
  }

  // Ambil semua list reservasi
  Future<List<dynamic>> getAllReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/reservations'), headers: await _getHeaders());
    return jsonDecode(response.body)['data'];
  }

  // Update data reservasi
  Future<bool> updateReservation(int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/reservations/$id'), headers: await _getHeaders(), body: jsonEncode(data));
    return response.statusCode == 200;
  }

  // Hapus reservasi
  Future<bool> deleteReservation(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/reservations/$id'), headers: await _getHeaders());
    return response.statusCode == 200;
  }

  // Fungsi untuk mengambil daftar kamar yang statusnya 'Available'
  Future<List<dynamic>> getAvailableRooms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rooms/available'),
        headers: await _getHeaders(), // Memanggil helper header
      );

      if (response.statusCode == 200) {
        // Mengembalikan list kamar dari key 'data' sesuai struktur JSON Laravel
        return jsonDecode(response.body)['data'];
      } else {
        // Melempar error jika status code bukan 200
        throw Exception('Gagal mengambil data kamar (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Log error jika terjadi masalah koneksi atau server
      print("ApiService Error (getAvailableRooms): $e");
      return []; // Kembalikan list kosong agar UI tidak crash
    }
  }
}



