window.IMTS ||= {}

class HourlyGraph
  constructor: () ->

  updateResults: (device) ->  
    hours =
      _.map device.elapsed_hourly_utilization, (util, hour) ->
        hour
        
    utils =
      _.map device.elapsed_hourly_utilization, (util, hour) ->
        util    

    @chart.xAxis[0].setCategories(hours, false)
    @chart.series[0].setData(utils, true)

  documentReady: () ->
    @chart = new Highcharts.Chart(
      chart:
        renderTo: "hourly"
        type: "column"
        width: 400
        height: 295

      title:
        text: ""

      xAxis:
        categories: []
        title:
          text: "Hour"
      
      yAxis:
        min: 0
        max: 100
        tickInterval: 25
        title:
          text: "Percent"

      legend:
        enabled: false

      tooltip:
        formatter: ->
          "Utilization: " + @y + "%"

      plotOptions:
        column:
          pointPadding: 0.2
          borderWidth: 0
          animation: true        

      credits:
        enabled: false

      series: [
        name: "Utilization"
      ]
    )

window.IMTS.HourlyGraph = HourlyGraph