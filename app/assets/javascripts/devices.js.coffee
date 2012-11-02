# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


window.IMTS ||= {}


window.IMTS.fetch_hmi =  (device_id) ->
  $.get "/devices/#{device_id}/update_hmi", (response, status) ->
    $(".hmi").html(response)

window.IMTS.update_alarms =  (device_id) ->
  $.get "/devices/#{device_id}/update_alarms", (response, status) ->
    $("#alarms").html(response)

window.IMTS.update_activity =  (device_id) ->
  $.get "/devices/#{device_id}/update_activity", (response, status) ->
    $("#activity").html(response)

window.IMTS.draw_graphs = (device_id) ->
  $.getJSON "/devices/#{device_id}", (device, status) ->
    window.IMTS.daily_graph.updateResults(device)
    window.IMTS.hourly_graph.updateResults(device)

window.IMTS.fetch_timely = (device_id) ->
  window.setInterval(window.IMTS.fetch_hmi, 2000, device_id)
  window.setInterval(window.IMTS.update_activity, 2000, device_id)
  window.setInterval(window.IMTS.update_alarms, 10000, device_id)

$(document).ready ->
  $("ul.nav-tabs li:first a").click()

  if $(".hmi").length > 0
    device_id = $(".hmi").attr("data-id").split("_")[1]
    window.IMTS.fetch_timely(device_id)

  if $(".graph").length > 0
    device_id = $(".graph").attr("data-id").split("_")[1]
    window.IMTS.daily_graph = new window.IMTS.DailyGraph()
    window.IMTS.daily_graph.documentReady()
    
    window.IMTS.hourly_graph = new window.IMTS.HourlyGraph()
    window.IMTS.hourly_graph.documentReady()
    
    window.IMTS.draw_graphs(device_id)
        
    window.setInterval(window.IMTS.draw_graphs, 15000, device_id)
    
