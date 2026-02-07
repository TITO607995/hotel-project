<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Room;

class RoomSeeder extends Seeder
{
    public function run(): void
    {
        // Konfigurasi kamar sesuai permintaanmu
        $roomConfigs = [
            ['type' => 'Standard', 'count' => 15, 'price' => 300000, 'prefix' => '1'],
            ['type' => 'Suite', 'count' => 10, 'price' => 850000, 'prefix' => '3'],
            ['type' => 'Executive', 'count' => 8, 'price' => 1200000, 'prefix' => '4'],
            ['type' => 'Deluxe', 'count' => 5, 'price' => 500000, 'prefix' => '2'],
        ];

        foreach ($roomConfigs as $config) {
            for ($i = 1; $i <= $config['count']; $i++) {
                Room::create([
                    // Format nomor kamar: prefix + urutan (contoh: 101, 102, dst)
                    'room_number' => $config['prefix'] . str_pad($i, 2, '0', STR_PAD_LEFT),
                    'type' => $config['type'],
                    'price' => $config['price'],
                    'status' => 'Available',
                ]);
            }
        }
    }
}