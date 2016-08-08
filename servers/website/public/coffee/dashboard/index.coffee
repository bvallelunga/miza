$ ->
  $(".network:not(.disabled)").click ->
    $(".network, .guide").removeClass "active"
    guide = $(this).addClass("active").data "guide"
    $(".guide.#{guide}").addClass "active"