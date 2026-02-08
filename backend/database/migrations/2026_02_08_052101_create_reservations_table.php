<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
{
    Schema::create('reservations', function (Blueprint $table) {
        $table->id();
        $table->foreignId('room_id')->constrained('rooms');
        $table->string('guest_name');
        $table->string('country');
        $table->integer('num_guests');
        $table->string('city');
        $table->string('email');
        $table->string('phone');
        $table->date('arrival_date');
        $table->date('departure_date');
        $table->string('place_birth');
        $table->string('room_type');
        $table->string('payment_method');
        $table->enum('reservation_type', ['guaranteed', 'non-guaranteed'])->default('non-guaranteed');
        $table->enum('reservation_status', ['booked', 'occupied', 'cancelled'])->default('booked');
        $table->boolean('is_paid')->default(false);
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reservations');
    }
};
