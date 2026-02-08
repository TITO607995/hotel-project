<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ReservationController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->get('/rooms', [RoomController::class, 'index']);
Route::middleware('auth:sanctum')->post('/rooms/update-price', [RoomController::class, 'updatePrice']);
Route::middleware('auth:sanctum')->post('/rooms/update-status', [RoomController::class, 'updateStatus']);
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/dashboard/stats', [DashboardController::class, 'index']);
});
Route::post('/reservations', [ReservationController::class, 'store']);
    Route::get('/reservations', [ReservationController::class, 'index']);
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/rooms/available', [RoomController::class, 'getAvailableRooms']);
});
