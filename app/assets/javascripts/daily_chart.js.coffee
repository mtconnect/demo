window.IMTS ||= {}

class DailyGraph
  constructor: () ->

  updateResults: (device) ->
    @chart.series[0].setData([device.elapsed_daily_utilization], true)
  
  documentReady: () ->
    @chart = new Highcharts.Chart(
      chart:
        renderTo: "daily",
        type: "bar",
        width: 400,
        height: 110

      title:
        text: ""

      xAxis:
        labels:
          enabled: false
        title:
          enabled: false

      yAxis:
        min: 0,
        max: 100,
        tickInterval: 20,
        title:
          text: "Percent"

      legend:
        enabled: false
    
      tooltip:
        formatter: ->
          "" + @series.name + ": " + @y + "%"

      plotOptions:
        series:
          stacking: "normal"
          animation: true

      credits:
        enabled: false

      series: [
        name: "Utilization"
      ]
    )

window.IMTS.DailyGraph = DailyGraph