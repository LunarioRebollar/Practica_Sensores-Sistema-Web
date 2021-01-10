<?php

namespace Database\Factories;

use App\Models\tabla_sensors;
use Illuminate\Database\Eloquent\Factories\Factory;

class ArduinoFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = tabla_sensors::class;

    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        return [
            //
        ];
    }
}
