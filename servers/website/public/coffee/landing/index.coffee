$ ->
  in_view $("#features"), go_events
  in_view $("#customers"), go_quotes
  
  
  $(".products .product").click ->
    $(".products .product").removeClass "active"
    $(this).addClass "active"
    $(".products .information").slideDown 500
    $(".products .information .section").hide()
    $(".products .information .#{$(this).data "product"}").show()
  
    
  $(".products .information .close").click ->
    $(".products .product").removeClass "active"
    $(".products .information").slideUp 500
  

go_events = ->
  if window.events_called?
    return
    
  window.events_called = true
  events = $(".ad-events .event")
      
  animator = (index)->        
    events.eq(index).css({
      marginTop: "-100px"
      display: "block"
      opacity: 0
      zIndex: events.length - index
    }).animate({
      opacity: 1
      marginTop: "15px"
    }, 800)
    
    if index <= events.length
      setTimeout ->
        animator ++index
      
      , random_int(800, 3000)
      
  animator 0
  
  
random_int = (min, max)->
  return Math.floor(Math.random() * (max - min + 1)) + min;

  
go_quotes = ->  
  if window.quotes_called?
    return
    
  window.quotes_called = true
  quotes = $(".customers .view")
  index = 0
  
  if quotes.length < 2
    return
  
  setInterval ->
    index++
    
    if index == quotes.length
      index = 0
      
    quotes.fadeOut 500
    
    setTimeout ->
      quotes.eq(index).fadeIn 500
      
    , 500
    
  , 5000
  
  
in_view = ($element, callback)->  
  check = ->
    hT = $element.offset().top
    hH = $element.outerHeight()
    wH = $(window).height()
    wS = $(this).scrollTop()
    
    if wS > (hT+hH-wH)
      callback()
      
  $(window).scroll check
  check()