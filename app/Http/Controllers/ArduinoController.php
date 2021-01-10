<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\tabla_sensor;
use Illuminate\Support\Facades\DB;

class ArduinoController extends Controller
{
  public function showIndex()
    {
      $datos=tabla_sensor::select("tabla_sensors.id","tabla_sensors.temperatura","tabla_sensors.humedad","tabla_sensors.luz","tabla_sensors.fecha_hora")
          ->selectRaw("DATE_FORMAT(fecha_hora,'%d/%m/%Y') as fecha_hora")
          ->orderBy("tabla_sensors.id","desc")->paginate(10);
        return view("Tabla.index",['datos' => $datos]);
    }
}
