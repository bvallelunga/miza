$ ->
  $(".selectors .select").click ->
    $(".preselect").fadeOut 250
    
    if $(this).data("select") == "network"
      $("form .publisher_industry").remove()
      
    $("form .select_value").val $(this).data("select")
    
    setTimeout ->    
      $(".container").removeClass("large-2")
      $("form").fadeIn 250
    , 300