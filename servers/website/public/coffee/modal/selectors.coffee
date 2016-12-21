$ ->
  $(".selectors .select").click ->
    $(".preselect").fadeOut 250
    is_protect = $(this).data("select") == "protect"
    
    $("form .publisher_industry").toggle is_protect
    $("form .select_value").val $(this).data("select")
    
    setTimeout ->    
      $(".container").removeClass("large-2")
      $(".finish").fadeIn 250
    , 300
    
 
  $(".select_back").click ->
    $(".finish").fadeOut 250
    
    setTimeout ->    
      $(".container").addClass("large-2")
      $(".preselect").fadeIn 250
    , 300