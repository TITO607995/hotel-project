<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::table('reservations', function (Blueprint $table) {
        // Hanya buat kolom jika belum ada di database
        if (!Schema::hasColumn('reservations', 'reservation_type')) {
            $table->string('reservation_type')->default('non-guaranteed')->after('payment_method');
        }
        if (!Schema::hasColumn('reservations', 'reservation_status')) {
            $table->string('reservation_status')->default('booked')->after('reservation_type');
        }
        if (!Schema::hasColumn('reservations', 'is_paid')) {
            $table->boolean('is_paid')->default(false)->after('reservation_status');
        }
    });
}

public function down(): void
{
    Schema::table('reservations', function (Blueprint $table) {
        $table->dropColumn(['reservation_type', 'reservation_status', 'is_paid']);
    });
}
};
