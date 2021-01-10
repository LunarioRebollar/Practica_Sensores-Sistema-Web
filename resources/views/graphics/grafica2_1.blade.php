<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            Grafica de Humedad Arduino
        </h2>
    </x-slot>

    <div class="py-6">
        <div class="flex items-center">
            <a class="ml-4" href="{{ route('grafica2') }}" style="text-decoration: none;
              background-color: #34495e;
              color:#fff;
              padding: 8px;
              text-decoration:none;">
                {{ __('Gráfica general') }}
            </a>
        </div>
            <div class="py-12">
                <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    <div class="bg-white overflow-hidden shadow-xl sm:rounded-lg">
                        <center><div id="chart_div" style="width: 1000; height: 600px;"></div></center>
                  </div>
                </div>
            </div>
    </div>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(drawChart);

      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ['Fecha Registro', 'Humedad'],
          @foreach($data as $dir)
          ['{{$dir->fecha_hora}}',{{$dir->humedad}}],
          @endforeach
        ]);

        var options = {
            title: 'Reporte de Humedad con Arduino',
            curveType: 'function',
            legend: { position: 'center' }
          };

        var chart = new google.visualization.AreaChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>

</x-app-layout>
