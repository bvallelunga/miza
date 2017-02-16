analyticsLogs = ->
  $.get("#{location.pathname}/logs", {
    date: new Date()
  }).done (logs)->
    now = new Date()
    setTimeout analyticsLogs, 5000
    
    $(".logs-table-message")
      .toggle(logs.length == 0)
      .text "We don't have any logs yet for your account."
    
    $(".logs-table tbody").html logs.map (log)->
      created = new Date log.created_at
          
      return $("""
        <tr>
          <td>#{log.type}</td>
          <td>#{log.browser}</td>
          <td>#{log.os}</td>
          <td>#{moment.duration(created - now).humanize(true)}</td>
        </tr>
      """)

      
class ReportsDashboard

  override: null
  start: null
  end: null

  metrics: (start, end, clear=true)->
    @start = start
    @end = end
    days = moment.duration(end-start).asDays()
    today = new Date()
    
    if clear
      @clear_metrics()
      
    $(".metrics-warning").toggle days < 2
    $(".fa-calendar").hide()
    $(".fa-refresh").show()

    $.get("#{location.pathname}/metrics", {
      start_date: start
      end_date: end
    }).done (data)=>
      $(".fa-calendar").show()
      $(".fa-refresh").hide()
      
      @display_metrics data

  
  clear_metrics: ->
    $(".ctr-metric").text "---"
    $(".impressions-metric").text "---"
    $(".clicks-metric").text "---"
    $(".views-metric").text "---"
    $(".blocked-metric").text "---"

  
  display_metrics: (metrics)->
    $(".ctr-metric").text metrics.ctr
    $(".impressions-metric").text metrics.impressions
    $(".clicks-metric").text metrics.clicks
    $(".views-metric").text metrics.views
    $(".blocked-metric").text metrics.blocked
  
  
  load_default: ->
    $(".range-display .text").text "This Month"
    @start = moment().startOf("month").toDate()
    @end = moment().endOf("day").toDate()
    @metrics @start, @end
    
    setInterval =>
      @metrics @start, @end, false
    , 30000
  
  
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
      endDate: moment().format "MMM DD, YYYY"
      extraClass: "date-dropdown"
      container: ".analytics-dashboard"
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
  analyticsLogs()
  
