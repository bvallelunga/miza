$ ->
  $(".network:not(.disabled)").click ->
    $(".network, .guide").removeClass "active"
    guide = $(this).addClass("active").data "guide"
    $(".guide.#{guide}").addClass "active"
    
  
  $(".miza_guide .completed").click ->
    $(".miza_guide").remove()
    window.history.pushState null, "", window.location.pathname
