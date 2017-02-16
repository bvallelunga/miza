$ ->
  $(".network:not(.disabled)").click ->
    $(".network, .guide").removeClass "active"
    guide = $(this).addClass("active").data "guide"
    $(".guide.#{guide}").addClass "active"
    
  
  $(".miza_guide .completed").click ->
    $(".miza_guide").fadeOut 250
    window.history.pushState null, "", window.location.pathname

  
  $(".publishers_list").on "keyup", ".publisher-search", ->
    value = $(@).val()
    
    $(".publishers_list .publisher-link").each ->
      item = $(@)
      name = item.text().toLowerCase()
      item.toggle name.indexOf(value) > -1