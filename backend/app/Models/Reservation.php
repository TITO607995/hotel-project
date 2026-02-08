<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Reservation extends Model
{
    protected $fillable = [
    'room_id',
    'guest_name',
    'country',
    'num_guests',
    'city',
    'email',
    'phone',
    'arrival_date',
    'departure_date',
    'place_birth',
    'room_type',  
    'payment_method',
    'reservation_type',
    'reservation_status',
    'is_paid'
];
}
