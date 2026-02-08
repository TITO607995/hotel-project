class Room {
  final int id; // Tambahkan ini agar tidak error lagi
  final String roomNumber;
  final String type;
  final int price;
  final String status;
  final String? image;
  final String? paymentMethod; // Tambahkan ini (Cash/Transfer)
  final bool isPaid;
  final String? visibilityMode; // Tambahkan ini
  final String? visibilityDescription;

  Room({
    required this.id, 
    required this.roomNumber,
    required this.type,
    required this.price,
    required this.status,
    this.image,
    this.paymentMethod,
    this.isPaid = false,
    this.visibilityMode,
    this.visibilityDescription,
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
      paymentMethod: json['payment_method'], // Data dari join tabel reservasi
      isPaid: json['is_paid'] == 1 || json['is_paid'] == true,
      visibilityMode: json['visibility_mode'] ?? "Public",
      visibilityDescription: json['visibility_description'], // Ambil dari Laravel
    );
  }
}