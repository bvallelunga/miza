$ ->
  if not $(".container").hasClass "campaigns-builder-dashboard"
    return

  $(".range-display").each ->
    $(this).dateRangePicker({
      container: ".container .display"
      showShortcuts: false
      showTopbar: false
      autoClose: true
      singleDate : true
      singleMonth: true
      format: 'MM-DD-YYYY'
      startOfWeek: 'monday'
      language:'en'
      startDate: moment().format('MM-DD-YYYY')
      extraClass: "date-dropdown"
    })
    
  
  $(".selection .option").click ->
    $option = $(this)
    $parent = $option.parents(".selection")
    $input = $parent.find("input").val $option.data("value")
    $parent.find(".option").removeClass "active"
    $option.addClass "active"