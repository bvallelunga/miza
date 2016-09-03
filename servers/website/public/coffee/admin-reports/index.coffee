$ ->
  metrics()

  $(".range-toggle div").click ->
    $(".range-toggle div").removeClass "active"
    $(this).addClass "active"
    metrics()

      
metrics = ->  
  $(".impressions-metric").html "&nbsp;"
  $(".clicks-metric").html "&nbsp;"
  $(".owed-metric").html "&nbsp;"
  $(".revenue-metric").html "&nbsp;"
  $(".protected-metric").html "&nbsp;"
  $("tr.publisher .data").text ""

  $.get("#{location.pathname}/metrics", {
    range: $(".range-toggle .active").data("range")
    date: new Date()
  }).done (metrics)->
    $(".protected-metric").html metrics.totals.protected
    $(".impressions-metric").text metrics.totals.impressions
    $(".clicks-metric").text metrics.totals.clicks
    $(".owed-metric").text metrics.totals.owe
    $(".revenue-metric").text metrics.totals.revenue
    
    metrics.publishers.forEach (publisher)->
      tr = $("tr.publisher.#{publisher.key}")
      tr.find(".protected").text publisher.protected
      tr.find(".revenue").text publisher.revenue
      tr.find(".owed").text publisher.owe