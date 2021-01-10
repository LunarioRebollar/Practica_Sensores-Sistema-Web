<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class tabla_sensor extends Model
{
    use HasFactory;
    protected $fillable=['id','humedad','temperatura','luz','fecha_hora'];
}
