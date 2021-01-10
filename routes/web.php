<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ArduinoController;
use App\Http\Controllers\GraficaController;
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

Route::get('/', function () {
    return view('auth.login');
});

Route::middleware(['auth:sanctum', 'verified'])->get('/dashboard', function () {
    return view('dashboard');
})->name('dashboard');

Route::get("index", [\App\Http\Controllers\ArduinoController::class,'showIndex'])->name("index");
Route::get("grafica1", [\App\Http\Controllers\GraficaController::class,'showGraphic1'])->name("grafica1");
Route::get("grafica1_1", [\App\Http\Controllers\GraficaController::class,'showGraphic1_1'])->name("grafica1_1");
Route::get("grafica2", [\App\Http\Controllers\GraficaController::class,'showGraphic2'])->name("grafica2");
Route::get("grafica2_1", [\App\Http\Controllers\GraficaController::class,'showGraphic2_1'])->name("grafica2_1");
Route::get("grafica3", [\App\Http\Controllers\GraficaController::class,'showGraphic3'])->name("grafica3");
Route::get("grafica3_1", [\App\Http\Controllers\GraficaController::class,'showGraphic3_1'])->name("grafica3_1");
Route::get("graficafinal", [\App\Http\Controllers\GraficaController::class,'showGraphicFinal'])->name("graficafinal");
Route::get("graficafinal_1", [\App\Http\Controllers\GraficaController::class,'showGraphicFinal_1'])->name("graficafinal_1");
