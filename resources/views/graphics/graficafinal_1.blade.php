<x-app-layout>
    <x-slot name="header">
        <h2 class="font-semibold text-xl text-gray-800 leading-tight">
            Grafica de Humedad Arduino
        </h2>
    </x-slot>
    <div class="py-6">
        <div class="flex items-center">
            <a class="ml-4" href="{{ route('grafica3') }}" style="text-decoration: none;
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
    <script type="text/javascript">
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(drawVisualization);

      function drawVisualization() {
        // Some raw data (not necessarily accurate)
        var data = google.visualization.arrayToDataTable([
          ['Fecha Registro', 'Temperatura', 'Humedad', 'Proximidad'],
          @foreach($data as $dir)
          ['{{$dir->fecha_hora}}',{{$dir->temperatura}},{{$dir->humedad}},{{$dir->luz}}],
          @endforeach
        ]);

        var options = {
          title : 'Reporte de Temperatura,Humedad,Proximidad con Arduino',
          vAxis: {title: 'Valores Generales'},
          hAxis: {title: 'Fecha de registro'},
          seriesType: 'bars',
          series: {4: {type: 'bars'}}
        };

        var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));
        chart.draw(data, options);
      }
    </script>
</x-app-layout>
