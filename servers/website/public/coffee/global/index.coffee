$ ->
  $("input.number").each ->
    $(@).number true, Number($(@).data("number") or 0)

  $(".nav-button").click ->
    $(".menu").css("right", 0);
  $(".close-menu").click ->
    $(".menu").css("right", "-360px");
