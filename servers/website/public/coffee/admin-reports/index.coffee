$ ->
  $(".range-toggle div").click ->
    $(".range-toggle div").removeClass "active"
    $(this).addClass "active"
    
    publisher_metrics()
    total_metrics()
    
  publisher_metrics()
  total_metrics()

      
publisher_metrics = ->
  $("tr.publisher").each ->
    tr = $(this)
    
    tr.find(".protected").text ""
    tr.find(".owed").text ""
    
    $.get("#{location.pathname}/#{tr.data("key")}", {
      range: $(".range-toggle .active").data("range")
      date: new Date()
    }).done (metrics)->      
      tr.find(".protected").text metrics.protected
      tr.find(".revenue").text metrics.revenue
      tr.find(".owed").text metrics.owe
      
      
total_metrics = ->  
  $(".impressions-metric").html "&nbsp;"
  $(".clicks-metric").html "&nbsp;"
  $(".owed-metric").html "&nbsp;"
  $(".revenue-metric").html "&nbsp;"
  $(".protected-metric").html "&nbsp;"

  $.get("#{location.pathname}/metrics", {
    range: $(".range-toggle .active").data("range")
    date: new Date()
  }).done (metrics)->
    $(".protected-metric").html metrics.protected
    $(".impressions-metric").text metrics.impressions
    $(".clicks-metric").text metrics.clicks
    $(".owed-metric").text metrics.owe
    $(".revenue-metric").text metrics.revenue