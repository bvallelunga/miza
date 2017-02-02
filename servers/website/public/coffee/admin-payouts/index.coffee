$ ->  
  $(".transfer-button").click ->
    $(".payouts-confirm").show()

  $(".range-picker").dateRangePicker({
    showShortcuts: false
    showTopbar: false
    autoClose: true
    format: 'MMM DD, YYYY'
    separator: '  -  '
    startOfWeek: 'monday'
    language:'en'
    extraClass: "date-dropdown"
    endDate: moment().format "MMM DD, YYYY"
    customOpenAnimation: (cb)->
      $(@).fadeIn(0, cb)
    
    customCloseAnimation: (cb)->
      $(@).fadeOut(0, cb)
    
    setValue: (value)->
      $(".form .name").val value
    
  }).bind 'datepicker-open', (event, obj)->    
    $(".range-display").addClass "open"
  
  .bind 'datepicker-close', (event, obj)->   
    $(".range-display").removeClass "open"
  
  .bind 'datepicker-change', (event, obj)=>    
    start = moment(obj.date1).startOf("day").toDate()
    end = moment(obj.date2).endOf("day").toDate()
    $(".form .start_date").val start
    $(".form .end_date").val end
