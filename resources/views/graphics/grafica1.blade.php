<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            Grafica de Temperatura Arduino
        </h2>
    </x-slot>
    <div class="py-8">
        <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <form method="GET" action="{{ route('grafica1_1') }}" >
                <div class="input-group">
                    <div class="form-group">
                        <label class="control-label">{{'Fecha Inicial'}}</label>
                        <input type="date" name="fecha_inicio" class="form-control" placeholder="Fecha inicial" id="fecha_inicio">
                    </div>
                    <div class="form-group">
                        <label class="control-label">{{'Fecha Final'}}</label>
                        <input type="date" name="fecha_final" class="form-control" placeholder="Fecha final" id="fecha_final">
                    </div>
                </div>
                <button type="submit" class="btn btn-success mb-2" name="buscar" id="buscar">Consultar</button>
            </form>
            <div class="bg-white overflow-hidden shadow-xl sm:rounded-lg">
                <center><div id="chart_div" style="width: 1000; height: 600px;"></div></center>
          </div>
    </div>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load("current", {packages:["corechart"]});
      google.charts.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([
          ['Fecha registro', 'Temperatura'],
          @foreach($data as $dir)
          ['{{$dir->fecha_hora}}', {{$dir->temperatura}}],
          @endforeach
          ]);

        var options = {
          title: 'Reporte de Temperatura Con Arduino',
          legend: { position: 'center',
        name: 'Temperatura' },
        };

        var chart = new google.visualization.Histogram(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
</x-app-layout>
