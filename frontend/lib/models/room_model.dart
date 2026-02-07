class Room {
  final int id; // Tambahkan ini agar tidak error lagi
  final String roomNumber;
  final String type;
  final int price;
  final String status;
  final String? image;

  Room({
    required this.id, 
    required this.roomNumber,
    required this.type,
    required this.price,
    required this.status,
    this.image,
  });

  // Factory untuk memetakan JSON dari Laravel ke objek Flutter
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'], // Pastikan nama key sesuai dengan database Laravel (id)
      roomNumber: json['room_number'].toString(),
      type: json['type'],
      price: json['price'],
      status: json['status'],
      image: json['image'],
    );
  }
}