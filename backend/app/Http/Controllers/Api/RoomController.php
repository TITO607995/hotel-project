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

        public function updateVisibility(Request $request)
        {
            $request->validate([
                'id' => 'required|exists:rooms,id',
                'visibility_mode' => 'required|in:Public,Incognito',
                'description' => 'nullable|string',
            ]);

            $room = Room::find($request->id);
            $room->update([
                'visibility_mode' => $request->visibility_mode,
                'visibility_description' => $request->description,
            ]);

            return response()->json(['status' => 'success', 'message' => 'Mode visibilitas diperbarui']);
        }

        // app/Http/Controllers/Api/RoomController.php
public function getAvailableRooms()
{
    // Hanya ambil nomor kamar yang statusnya 'Available'
    $rooms = Room::where('status', 'Available')->get();
    
    return response()->json([
        'status' => 'success',
        'data' => $rooms
    ]);
}

}