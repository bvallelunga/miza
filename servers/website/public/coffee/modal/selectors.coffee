$ ->
  $(".selectors .select").click ->
    $(".preselect").fadeOut 150
    is_protect = $(this).data("select") == "protect"
    
    $("form .publisher_industry").toggle is_protect
    $("form .select_value").val $(this).data("select")
    
    setTimeout ->    
      $(".container").removeClass("large-2")
      $(".finish").fadeIn 150
    , 200
    
 
  $(".select_back").click ->
    $(".finish").fadeOut 150
    
    setTimeout ->    
      $(".container").addClass("large-2")
      $(".preselect").fadeIn 150
    , 200