<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'Admin Hotel',
            'email' => 'admin@gmail.com',
            'password' => Hash::make('password123'),
        ]);
    }
}