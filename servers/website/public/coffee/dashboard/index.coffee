$ ->
  $(".publisher:not(.disabled)").click ->
    $(".publisher, .guide").removeClass "active"
    guide = $(this).addClass("active").data "guide"
    $(".guide.#{guide}").addClass "active"