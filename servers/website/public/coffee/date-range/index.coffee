window.DatePicker = class DatePicker

  override: null
  start: null
  end: null
  callback: null
  
  constructor: (container, callback)->
    @callback = callback
    @load_default()
    @configure_datepicker(container)


  metrics: (start, end)->
    @start = start
    @end = end
    
    if @callback?
      $(".range-display .fa-calendar").hide()
      $(".range-display .fa-refresh").show()
  
      @callback {
        start: start, 
        end: end
      }, ->
        $(".range-display .fa-calendar").show()
        $(".range-display .fa-refresh").hide()
  
  
  load_default: ->
    $(".range-display .text").text "This Month"
    @start = moment().startOf("month").toDate()
    @end = moment().endOf("month").toDate()
    @metrics @start, @end
  
  
  build_shortcut: (name, formatted, ranges)->
    {
      name: name
      dates: =>
        @override = formatted
        return ranges
    }
    
  
  configure_datepicker: (container)->
    _this = @
    
    console.log $(".range-display").data("endAt")
  
    $(".range-display").dateRangePicker({
      container: container
      showShortcuts: true
      showTopbar: false
      autoClose: true
      format: 'MMM DD, YYYY'
      separator: ' <strong>to</strong> '
      startOfWeek: 'monday'
      language:'en'
      extraClass: "date-dropdown"
      startDate: $(".range-display").data("start-date") or null
      endDate: $(".range-display").data("end-date") or null
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
          moment().endOf("week").toDate()
        ]
        
        @build_shortcut "Month", "This Month", [
          moment().startOf("month").toDate()
          moment().endOf("month").toDate()
        ]
        
        @build_shortcut "Year", "This Year", [
          moment().startOf("year").toDate()
          moment().endOf("year").toDate()
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
  
