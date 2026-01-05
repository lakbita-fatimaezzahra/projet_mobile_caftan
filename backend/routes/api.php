<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\Admin\AuthController;
use App\Http\Controllers\API\Admin\DashboardController;
use App\Http\Controllers\API\Admin\AdminCaftanController;
use App\Http\Controllers\API\Admin\AdminRentalController;
use App\Http\Controllers\API\Admin\AdminCategoryController;
use App\Http\Controllers\API\Admin\AdminColorController;
use App\Http\Controllers\API\Admin\AdminSizeController;
use App\Http\Controllers\API\Admin\AdminClientController;
use App\Http\Controllers\API\Admin\AdminSettingController;
use App\Http\Middleware\IsAdmin;

Route::get('/health', function () {
    return ['status' => 'ok'];
});

Route::prefix('admin')->group(function () {
    // Auth
    Route::post('login', [AuthController::class, 'login']);

    // Routes protégées par Sanctum + middleware IsAdmin
    Route::middleware(['auth:sanctum', IsAdmin::class])->group(function () {
        Route::post('logout', [AuthController::class, 'logout']);
        Route::get('user', [AuthController::class, 'me']);

        // Dashboard
        Route::get('dashboard', [DashboardController::class, 'index']);

        // Caftans
        Route::get('caftans', [AdminCaftanController::class, 'index']);
        Route::post('caftans', [AdminCaftanController::class, 'store']);
        Route::get('caftans/{id}', [AdminCaftanController::class, 'show']);
        Route::put('caftans/{id}', [AdminCaftanController::class, 'update']);
        Route::delete('caftans/{id}', [AdminCaftanController::class, 'destroy']);
        Route::put('caftans/{id}/availability', [AdminCaftanController::class, 'updateAvailability']);
        Route::post('caftans/{id}/images', [AdminCaftanController::class, 'uploadImages']);

        // Rentals
        Route::get('rentals', [AdminRentalController::class, 'index']);
        Route::post('rentals', [AdminRentalController::class, 'store']);
        Route::get('rentals/{id}', [AdminRentalController::class, 'show']);
        Route::put('rentals/{id}', [AdminRentalController::class, 'update']);
        Route::delete('rentals/{id}', [AdminRentalController::class, 'destroy']);
        Route::put('rentals/{id}/status', [AdminRentalController::class, 'updateStatus']);
        Route::put('rentals/{id}/payment', [AdminRentalController::class, 'updatePayment']);

        // Categories
        Route::get('categories', [AdminCategoryController::class, 'index']);
        Route::post('categories', [AdminCategoryController::class, 'store']);
        Route::get('categories/{id}', [AdminCategoryController::class, 'show']);
        Route::put('categories/{id}', [AdminCategoryController::class, 'update']);
        Route::delete('categories/{id}', [AdminCategoryController::class, 'destroy']);

        // Colors
        Route::get('colors', [AdminColorController::class, 'index']);
        Route::post('colors', [AdminColorController::class, 'store']);
        Route::get('colors/{id}', [AdminColorController::class, 'show']);
        Route::put('colors/{id}', [AdminColorController::class, 'update']);
        Route::delete('colors/{id}', [AdminColorController::class, 'destroy']);

        // Sizes
        Route::get('sizes', [AdminSizeController::class, 'index']);
        Route::post('sizes', [AdminSizeController::class, 'store']);
        Route::get('sizes/{id}', [AdminSizeController::class, 'show']);
        Route::put('sizes/{id}', [AdminSizeController::class, 'update']);
        Route::delete('sizes/{id}', [AdminSizeController::class, 'destroy']);

        // Clients
        Route::get('clients', [AdminClientController::class, 'index']);
        Route::post('clients', [AdminClientController::class, 'store']);
        Route::get('clients/{id}', [AdminClientController::class, 'show']);
        Route::put('clients/{id}', [AdminClientController::class, 'update']);
        Route::delete('clients/{id}', [AdminClientController::class, 'destroy']);

        // Settings
        Route::get('settings', [AdminSettingController::class, 'show']);
        Route::put('settings', [AdminSettingController::class, 'update']);
    });
});
