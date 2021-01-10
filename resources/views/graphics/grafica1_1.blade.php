<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            Grafica de Temperatura Arduino
        </h2>
    </x-slot>
    <div class="py-6">
        <div class="flex items-center">
            <a class="ml-4" href="{{ route('grafica1') }}" style="text-decoration: none;
              background-color: #34495e;
              color:#fff;
              padding: 8px;
              text-decoration:none;">
                {{ __('Gráfica general') }}
            </a>
        </div>
            <br><br>
            <div class="py-12">
                <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    <div class="bg-white overflow-hidden shadow-xl sm:rounded-lg">
                        <center><div id="chart_div" style="width: 1000; height: 600px;"></div></center>
                  </div>
                </div>
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
