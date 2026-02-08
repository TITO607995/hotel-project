<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Reservation;
use App\Models\Room;

class ReservationController extends Controller
{
    public function store(Request $request)
{
    try {
        // 1. Ambil data kamar untuk mendapatkan tipenya
        $room = \App\Models\Room::findOrFail($request->room_id);

        $data = $request->all();
        // 2. Isi 'room_type' secara otomatis dari database
        $data['room_type'] = $room->type; 
        $data['reservation_status'] = 'booked';

        // 3. Simpan reservasi
        $reservation = \App\Models\Reservation::create($data);

        // 4. Update status kamar di dashboard
        $room->update([
            'status' => 'Booking',
            'is_paid' => $request->reservation_type == 'guaranteed' ? true : false,
        ]);

        return response()->json(['status' => 'success', 'data' => $reservation], 201);
    } catch (\Exception $e) {
        // Jika gagal, kirim pesan error spesifik agar bisa dibaca di tab Network Chrome
        return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
    }
}

public function getPending()
{
    $pending = Reservation::where('reservation_status', 'booked')->get();
    return response()->json(['status' => 'success', 'data' => $pending]);
}

public function checkIn(Request $request, $id)
{
    $reservation = Reservation::findOrFail($id);
    
    $reservation->update([
        'reservation_status' => 'occupied',
        'payment_method' => $request->payment_method,
        'is_paid' => true
    ]);

    $room = Room::find($reservation->room_id);
    if ($room) {
        $room->update(['status' => 'Occupied']);
    }

    return response()->json(['status' => 'success', 'message' => 'Check-in Berhasil!']);
}

public function index() {
    $reservations = Reservation::with('room')->latest()->get();
    return response()->json(['status' => 'success', 'data' => $reservations]);
}

public function update(Request $request, $id) {
    $reservation = Reservation::findOrFail($id);
    $reservation->update($request->all());
    return response()->json(['status' => 'success', 'message' => 'Data berhasil diubah!']);
}

public function destroy($id) {
    $reservation = Reservation::findOrFail($id);
    
    $room = \App\Models\Room::find($reservation->room_id);
    if ($room) {
        $room->update(['status' => 'Available']);
    }

    $reservation->delete();
    return response()->json(['status' => 'success', 'message' => 'Reservasi dibatalkan!']);
}
}
