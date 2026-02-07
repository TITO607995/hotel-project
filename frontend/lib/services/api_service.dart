import 'dart:convert';
import 'package:frontend/models/room_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti IP dengan IP Laptop kamu (cek via ipconfig di CMD)
  static const String baseUrl = 'http://192.168.1.14:8000/api'; 

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
}

