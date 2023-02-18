<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', [Controllers\DataController::class, 'index'])->name('index');
Route::get('/create', [Controllers\DataController::class, 'create'])->name('create');
Route::post('/create', [Controllers\DataController::class, 'create']);
Route::get('/update/{id}', [Controllers\DataController::class, 'update'])->name('update');
Route::post('/update/{id}', [Controllers\DataController::class, 'update']);
Route::get('/delete/{id}', [Controllers\DataController::class, 'delete'])->name('delete');