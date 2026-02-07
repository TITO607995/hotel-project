<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Room extends Model
{
    // Pastikan 'status' ada di sini, bro!
    protected $fillable = [
        'room_number', 
        'type', 
        'price', 
        'status', 
        'image'
    ];
}