$ ->
  $(".stats span").click ->
    $(".stats span").removeClass "active"
    $(this).addClass "active"
    filter = $(this).data "filter"
    
    if filter == "all"
      return $("table tbody tr").show()
    
    $("table tbody tr").each ->
      $(this).toggle $(this).hasClass filter