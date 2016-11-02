class ReportsDashboard

  override: null
  start: null
  end: null

  metrics: (start, end)->
    @clear_metrics()
    @start = start
    @end = end
    today = new Date()
    
    $(".fa-calendar").hide()
    $(".fa-refresh").show()

    $.get("/admin/reports/metrics", {
      start_date: start
      end_date: end
    }).done (data)=>
      $(".fa-calendar").show()
      $(".fa-refresh").hide()
    
      @display_totals data.totals
      data.publishers.forEach @display_publisher
   
  
  display_publisher: (publisher)->
    $publisher = $("tr.#{publisher.id}").toggleClass "inactive", not publisher.active
    $publisher.find(".protected").text publisher.protected
    $publisher.find(".owed").text publisher.owed
    $publisher.find(".cpm").text publisher.cpm
    $publisher.find(".impressions").text publisher.impressions
    $publisher.find(".clicks").text publisher.clicks
        
        
  display_totals: (totals)->     
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
  
  
  load_default: ->
    $(".range-display .text").text "Today"
    @start = moment().startOf("day").toDate()
    @end = moment().endOf("day").toDate()
    @metrics @start, @end
    
    setInterval =>
      @metrics @start, @end
    , 60000
  
  
  build_shortcut: (name, formatted, ranges)->
    {
      name: name
      dates: =>
        @override = formatted
        return ranges
    }
    
  
  configure_datepicker: ->
    _this = @
  
    $(".range-display").dateRangePicker({
      showShortcuts: true
      showTopbar: false
      autoClose: true
      format: 'MMM DD, YYYY'
      separator: ' <strong>to</strong> '
      startOfWeek: 'monday'
      language:'en'
      extraClass: "date-dropdown"
      endDate: moment().format "MMM DD, YYYY"
      customOpenAnimation: (cb)->
        $(@).fadeIn(0, cb)
      
      customCloseAnimation: (cb)->
        $(@).fadeOut(0, cb)
      
      setValue: (value)->
        $(@).find(".text").html _this.override or value
        _this.override = null
      
      customShortcuts: [
        @build_shortcut "Last Year", "Last Year", [
          moment().add(-1, "year").startOf("year").toDate()
          moment().add(-1, "year").endOf("year").toDate()
        ]
        
        @build_shortcut "Last Month", "Last Month", [
          moment().add(-1, "month").startOf("month").toDate()
          moment().add(-1, "month").endOf("month").toDate()
        ]
        
        @build_shortcut "Last Week", "Last Week", [
          moment().add(-1, "week").isoWeekday(1).startOf("isoweek").toDate()
          moment().add(-1, "week").isoWeekday(1).endOf("isoweek").toDate()
        ]
        
        @build_shortcut "Yesterday", "Yesterday", [
          moment().add(-1, "day").startOf("day").toDate()
          moment().add(-1, "day").endOf("day").toDate()
        ]
        
        @build_shortcut "Today", "Today", [
          moment().startOf("day").toDate()
          moment().endOf("day").toDate()
        ]
        
        @build_shortcut "Week", "This Week", [
          moment().isoWeekday(1).startOf("isoweek").toDate()
          moment().endOf("day").toDate()
        ]
        
        @build_shortcut "Month", "This Month", [
          moment().startOf("month").toDate()
          moment().endOf("day").toDate()
        ]
        
        @build_shortcut "Year", "This Year", [
          moment().startOf("year").toDate()
          moment().endOf("day").toDate()
        ]
      ]
    }).bind 'datepicker-open', (event, obj)->    
      $(".range-display").addClass "open"
    
    .bind 'datepicker-close', (event, obj)->   
      $(".range-display").removeClass "open"
    
    .bind 'datepicker-change', (event, obj)=>    
      start = moment(obj.date1).startOf("day").toDate()
      end = moment(obj.date2).endOf("day").toDate()
      @metrics start, end

  
$ ->  
  dashboard = new ReportsDashboard() 
  dashboard.load_default()
  dashboard.configure_datepicker()
  
