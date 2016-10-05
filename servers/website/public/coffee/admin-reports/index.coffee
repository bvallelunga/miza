class ReportsDashboard

  metrics: (start, end)->
    @clear_metrics()

    $.get("/admin/reports/metrics", {
      start_date: start
      end_date: end
      days: moment.duration(end-start).asDays()
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
    $(".impressions-metric").html "---"
    $(".clicks-metric").html "---"
    $(".owed-metric").html "---"
    $(".ctr-metric").html "---"
    $(".protected-metric").html "---"
    $("tr.publisher .data").html "---"

  
$ ->  
  dashboard = new ReportsDashboard() 
  default_start = moment().startOf("day")
  default_end = moment().endOf("day")
  dashboard.metrics default_start.toDate(), default_end.toDate()

  $(".range-display").dateRangePicker({
    showShortcuts: true
    showTopbar: false
    autoClose: true
    format: 'MMM DD, YYYY'
    separator: ' <strong>to</strong> '
    startOfWeek: 'monday'
    language:'en'
    customOpenAnimation: (cb)->
      $(this).fadeIn(0, cb)
    
    customCloseAnimation: (cb)->
      $(this).fadeOut(0, cb)
    
    setValue: (value)->
      $(this).find(".text").html value
    
    customShortcuts: [
      {
        name: "Last Year"
        dates: ->
          [
            moment().add(-1, "year").startOf("year").toDate()
            moment().add(-1, "year").endOf("year").toDate()
          ]
      }
      {
        name: "Last Month"
        dates: ->
          [
            moment().add(-1, "month").startOf("month").toDate()
            moment().add(-1, "month").endOf("month").toDate()
          ]
      }
      {
        name: "Last Week"
        dates: ->
          [
            moment().add(-1, "week").isoWeekday(1).startOf("isoweek").toDate()
            moment().add(-1, "week").isoWeekday(1).endOf("isoweek").toDate()
          ]
      }
      {
        name: "Yesterday"
        dates: ->
          [
            moment().add(-1, "day").startOf("day").toDate()
            moment().endOf("day").toDate()
          ]
      }
      {
        name: "Today"
        dates: ->
          [
            moment().startOf("day").toDate()
            moment().endOf("day").toDate()
          ]
      }
      {
        name: "Week"
        dates: ->
          [
            moment().isoWeekday(1).startOf("isoweek").toDate()
            moment().isoWeekday(1).endOf("isoweek").toDate()
          ]
      }
      {
        name: "Month"
        dates: ->
          [
            moment().startOf("month").toDate()
            moment().endOf("month").toDate()
          ]
      }
      {
        name: "Year"
        dates: ->
          [
            moment().startOf("year").toDate()
            moment().endOf("year").toDate()
          ]
      }
    ]
  }).bind 'datepicker-open', (event, obj)->    
    $(".range-display").addClass "open"
  
  .bind 'datepicker-close', (event, obj)->   
    $(".range-display").removeClass "open"
  
  .bind 'datepicker-change', (event, obj)->    
    start = moment(obj.date1).startOf("day").toDate()
    end = moment(obj.date2).endOf("day").toDate()
    dashboard.metrics start, end
    
  .data("dateRangePicker").setDateRange(
    default_start.format('MMM DD, YYYY'), 
    default_end.format('MMM DD, YYYY')
  )
