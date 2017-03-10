$ ->  
  $(".payouts.actions .action").click (e)=>    
    $spinner = $(e.currentTarget).find(".fa-spin").show()
    $original = $(e.currentTarget).find(":not(.fa-spin)").hide()  
    action = $(e.currentTarget).data("action")
    
    debugger
    
    $.post("/admin/payouts/#{config.payout}/#{action}", {
      _csrf: config.csrf
    }).done (data)->
      window.location.href = data.next
      
    .fail (error)->
      $spinner.hide()
      $original.show()
      message = error.responseJSON.message
      
      $(".container").prepend(
        "<div class='warning orange'>#{message}</div>"
      )
      
      window.scrollTo(0,0);

  if $(".range-picker").dateRangePicker?
    $(".range-picker").dateRangePicker({
      showShortcuts: false
      showTopbar: false
      autoClose: true
      format: 'MMM D, YYYY'
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
