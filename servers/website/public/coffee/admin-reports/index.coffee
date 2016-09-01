$ ->
  $(".range-toggle div").click ->
    $(".range-toggle div").removeClass "active"
    $(this).addClass "active"
    publisher_metrics()
    
  publisher_metrics()
      
publisher_metrics = ->
  $("tr.publisher").each ->
    tr = $(this)
    
    $.get("#{location.pathname}/#{tr.data("key")}", {
      range: $(".range-toggle .active").data("range")
    }).done (response)->
      console.log response