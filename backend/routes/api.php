<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\RoomController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->get('/rooms', [RoomController::class, 'index']);
Route::middleware('auth:sanctum')->post('/rooms/update-price', [RoomController::class, 'updatePrice']);
Route::middleware('auth:sanctum')->post('/rooms/update-status', [RoomController::class, 'updateStatus']);