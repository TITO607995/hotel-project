<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Room;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    /**
     * Mengambil statistik kamar dinamis untuk Dashboard.
     */
    public function index(): JsonResponse
    {
        // 1. Ambil semua tipe kamar unik yang ada di database
        $roomTypes = Room::select('type')->distinct()->pluck('type');

        $stats = [];
        foreach ($roomTypes as $type) {
            // Hitung total kamar per tipe
            $total = Room::where('type', $type)->count();
            
            // Hitung sisa (hanya yang statusnya 'Available')
            // Sesuai logika: sisa = total - (Booking + Terisi + oo/os)
            $sisa = Room::where('type', $type)->where('status', 'Available')->count();

            $stats[] = [
                'type' => $type,
                'total' => $total,
                'sisa' => $sisa,
            ];
        }

        // 2. Ambil seluruh data kamar untuk tabel dashboard
        // Kita ambil semua agar Flutter bisa memfilter mana yang muncul di tabel aktivitas
        $allRooms = Room::all();

        return response()->json([
            'status' => 'success',
            'data' => [
                'stats' => $stats, // Data untuk kartu statistik atas
                'rooms' => $allRooms // Data untuk tabel bawah
            ]
        ]);
    }
}