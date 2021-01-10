<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\tabla_sensor;
use Illuminate\Support\Facades\DB;

class GraficaController extends Controller
{
  public function showGraphic1(Request $request){
        //$data=DB::select('select DATE_FORMAT(fecha_hora,"%d/%m/%Y") as fecha_hora,temperatura from tabla_sensors order by id asc ');
        $data=tabla_sensor::select("tabla_sensors.id","tabla_sensors.fecha_hora","tabla_sensors.temperatura")
        ->selectRaw("DATE_FORMAT(fecha_hora,'%d/%m/%Y') as fecha_hora")
        ->orderBy("tabla_sensors.id","asc")
        ->get();
        return view("graphics.grafica1",['data' => $data]);
    }

    public function showGraphic1_1(Request $request){
        $query=trim($request->get('fecha_inicio'));
        $fecha_f=trim($request->get('fecha_final'));
        if($request){
            //$data=DB::select('select DATE_FORMAT(fecha_hora,"%d/%m/%Y") as fecha_hora,temperatura from tabla_sensors order by id asc ')
            $data=tabla_sensor::select("tabla_sensors.id","tabla_sensors.fecha_hora","tabla_sensors.temperatura")
            ->selectRaw("DATE_FORMAT(fecha_hora,'%d/%m/%Y') as fecha_hora")
            ->whereBetween('fecha_hora',[$query, $fecha_f])
            ->orderBy(".tabla_sensors.id","asc")
            ->get();
            return view("graphics.grafica1_1",['data' => $data,"fecha_inicio"=>$query,"fecha_final"=>$fecha_f]);
        }
    }

    public function showGraphic2(){
        //$data=DB::select('select DATE_FORMAT(fecha_hora,"%d/%m/%Y") as fecha_hora,temperatura from tabla_sensors order by id asc ');
        $data=tabla_sensor::select("tabla_sensors.id","tabla_sensors.fecha_hora","tabla_sensors.humedad")
        ->selectRaw("DATE_FORMAT(fecha_hora,'%d/%m/%Y') as fecha_hora")
        ->orderBy("tabla_sensors.id","asc")
        ->get();
        return view("graphics.grafica2",['data' => $data]);
      }

      public function showGraphic2_1(Request $request){
        $query=trim($request->get('fecha_inicio'));
        $fecha_f=trim($request->get('fecha_final'));
        if($request){
            //$data=DB::select('select DATE_FORMAT(fecha_hora,"%d/%m/%Y") as fecha_hora,humedad from tabla_sensors order by id asc ')
            $data=tabla_sensor::select("tabla_sensors.id","tabla_sensors.fecha_hora","tabla_sensors.humedad")
            ->selectRaw("DATE_FORMAT(fecha_hora,'%d/%m/%Y') as fecha_hora")
            ->whereBetween('fecha_hora',[$query, $fecha_f])
            ->orderBy(".tabla_sensors.id","asc")
            ->get();
            return view("graphics.grafica2_1",['data' => $data,"fecha_inicio"=>$query,"fecha_final"=>$fecha_f]);
        }
      }

      public function showGraphic3(){
            //$data=DB::select('select DATE_FORMAT(fecha_hora,"%d/%m/%Y") as fecha_hora,temperatura from tabla_sensors order by id asc ');
            $data=tabla_sensor::select("tabla_sensors.id","tabla_sensors.fecha_hora","tabla_sensors.luz")
            ->selectRaw("DATE_FORMAT(fecha_hora,'%d/%m/%Y') as fecha_hora")
            ->orderBy("tabla_sensors.id","asc")
            ->get();
            return view("graphics.grafica3",['data' => $data]);
      }

      public function showGraphic3_1(Request $request){
        $query=trim($request->get('fecha_inicio'));
        $fecha_f=trim($request->get('fecha_final'));
        if($request){
            //$data=DB::select('select DATE_FORMAT(fecha_hora,"%d/%m/%Y") as fecha_hora,luz from tabla_sensors order by id asc ')
            $data=tabla_sensor::select("tabla_sensors.id","tabla_sensors.fecha_hora","tabla_sensors.luz")
            ->selectRaw("DATE_FORMAT(fecha_hora,'%d/%m/%Y') as fecha_hora")
            ->whereBetween('fecha_hora',[$query, $fecha_f])
            ->orderBy(".tabla_sensors.id","asc")
            ->get();
            return view("graphics.grafica3_1",['data' => $data,"fecha_inicio"=>$query,"fecha_final"=>$fecha_f]);
        }
    }

    public function showGraphicFinal(){
        //$data=DB::select('select DATE_FORMAT(fecha_hora,"%d/%m/%Y") as fecha_hora,temperatura from tabla_sensors order by id asc ');
         $data=tabla_sensor::select("tabla_sensors.id","tabla_sensors.fecha_hora","tabla_sensors.temperatura","tabla_sensors.humedad","tabla_sensors.luz")
         ->selectRaw("DATE_FORMAT(fecha_hora,'%d/%m/%Y') as fecha_hora")
         ->orderBy("tabla_sensors.id","asc")
         ->get();
        return view("graphics.graficafinal",['data' => $data]);
    }

    public function showGraphicFinal_1(Request $request){
        $query=trim($request->get('fecha_inicio'));
        $fecha_f=trim($request->get('fecha_final'));
        if($request){
            //$data=DB::select('select DATE_FORMAT(fecha_hora,"%d/%m/%Y") as fecha_hora,luz from tabla_sensors order by id asc ')
            $data=tabla_sensor::select("tabla_sensors.id","tabla_sensors.fecha_hora","tabla_sensors.temperatura","tabla_sensors.humedad","tabla_sensors.luz")
            ->selectRaw("DATE_FORMAT(fecha_hora,'%d/%m/%Y') as fecha_hora")
            ->whereBetween('fecha_hora',[$query, $fecha_f])
            ->orderBy(".tabla_sensors.id","asc")
            ->get();
            return view("graphics.graficafinal_1",['data' => $data,"fecha_inicio"=>$query,"fecha_final"=>$fecha_f]);
        }
    }
}
