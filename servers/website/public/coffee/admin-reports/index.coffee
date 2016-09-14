class ReportsDashboard

  metrics: (range)->
    @clear_metrics()

    $.get("/admin/reports/metrics", {
      range: range
      date: new Date()
    }).done (data)->
      display_totals data.totals
      data.publishers.forEach display_publisher
   
  
  display_publisher = (publisher)->
    $publisher = $("tr.#{publisher.id}").toggleClass "inactive", not publisher.active
    $publisher.find(".protected").text publisher.protected
    $publisher.find(".owed").text publisher.owed
    $publisher.find(".cpm").text publisher.cpm
    $publisher.find(".impressions").text publisher.impressions
    $publisher.find(".clicks").text publisher.clicks
        
        
  display_totals = (totals)->     
    $(".impressions-metric").html totals.impressions
    $(".clicks-metric").html totals.clicks
    $(".owed-metric").html totals.owed
    $(".ctr-metric").html totals.ctr
    $(".protected-metric").html totals.protected


  clear_metrics: ->
    $(".impressions-metric").html "&nbsp;"
    $(".clicks-metric").html "&nbsp;"
    $(".owed-metric").html "&nbsp;"
    $(".revenue-metric").html "&nbsp;"
    $(".protected-metric").html "&nbsp;"
    $("tr.publisher .data").text ""

  
$ ->
  dashboard = new ReportsDashboard()
  dashboard.metrics $(".range-toggle .active").data("range")
  
  $(".range-toggle div").click ->
    $(".range-toggle div").removeClass "active"
    $(this).addClass "active"
    dashboard.metrics $(".range-toggle .active").data("range")

