<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\WebsiteController;

Route::get('/', [WebsiteController::class, 'index'])->name('home');
Route::get('/caftans', [WebsiteController::class, 'caftans'])->name('caftans.index');
Route::get('/caftans/{id}', [WebsiteController::class, 'caftanDetail'])->name('caftans.show');
Route::get('/about', [WebsiteController::class, 'about'])->name('about');
Route::get('/contact', [WebsiteController::class, 'contact'])->name('contact');
