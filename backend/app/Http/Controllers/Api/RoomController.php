<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Room;
use Illuminate\Http\Request;

class RoomController extends Controller
{
    public function index()
    {
        // Mengambil semua data kamar
        $rooms = Room::all();

        return response()->json([
            'status' => 'success',
            'data' => $rooms
        ]);
    }

    public function updatePrice(Request $request)
{
    $request->validate([
        'type' => 'required|string',
        'price' => 'required|integer',
    ]);

    // Mengupdate semua kamar yang memiliki tipe tersebut
    \App\Models\Room::where('type', $request->type)->update(['price' => $request->price]);

    return response()->json([
        'status' => 'success',
        'message' => 'Harga kamar ' . $request->type . ' berhasil diperbarui'
    ]);
}

public function updateStatus(Request $request)
{
    $request->validate([
        'id' => 'required|exists:rooms,id',
        'status' => 'required|in:Available,oo,os', // Kita batasi statusnya
    ]);

    $room = Room::find($request->id);
    $room->update(['status' => $request->status]);

    return response()->json([
        'status' => 'success',
        'message' => 'Status Kamar ' . $room->room_number . ' berhasil diubah ke ' . $request->status
    ]);
}
}