$ ->
  $(".stats span").click ->
    hasClass = $(this).hasClass "active"
    $(".stats span").removeClass "active"
    
    if hasClass
      return $("table tbody tr").show()
    
    $(this).addClass "active"
    filter = $(this).data "filter"
    
    $("table tbody tr").each ->
      $(this).toggle $(this).hasClass filter