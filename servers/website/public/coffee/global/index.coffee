$ ->
  $("input.number").each ->
    $(@).number true, Number($(@).data("number") or 0)