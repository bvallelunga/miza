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
    
  $(".selection-shortcut").click ->
    $parent = $("##{$(@).data("for")}")
    value = $parent.find(".option").addClass("active").map ->
      return $(@).data("value")
    
    .get().join(",")
    $parent.find("input").val value
  
  
  $(".selection .option").click ->
    $option = $(this)
    $parent = $option.parents(".selection")
    type = $parent.data("select")
    
    if type == "single"
      $parent.find("input").val $option.data("value")
      $parent.find(".option").removeClass "active"
      $option.addClass "active"
      
    else if type == "multi"
      $option.toggleClass "active"      
      value = $parent.find(".option.active").map ->
        return $(@).data("value")
      
      .get().join(",")
      $parent.find("input").val value