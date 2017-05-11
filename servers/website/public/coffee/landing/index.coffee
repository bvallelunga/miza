$ ->
  go_quotes()
  old_product = ""
  
  
  $(".navigation .shortcuts .dynamic").mouseover ->
    $element = $(@) 
    modal_width = 580
    left = $element.offset().left + $element.outerWidth()/2 - modal_width/2
    
    $(".navigation-modal .dynamic").hide()
     
    $(".navigation-modal")
      .animate({
        "left": left
      }, 250)
      .fadeIn(250)
      .find(".#{$element.data("for")}").show()
  
    
  $(".navigation-modal").mouseleave ->
    $(@).fadeOut(250)
  
  
  if $(".hero").hasClass "demo"
    blocker true
  
  $(".products .product").click ->
    product = $(this).data("product")
  
    $(".products .product").removeClass "active"
    $(this).addClass "active"
    $(".products .information").removeClass old_product
    $(".products .information").addClass product
    $(".products .information").slideDown 500
    $(".products .information .section").hide()
    $(".products .information .#{product}").show()
    old_product = product
  
    
  $(".products .information .close").click ->
    $(".products .product").removeClass "active"
    $(".products .information").slideUp 500
  

blocker_status = null
blocker = (disable=false)->
  blocker_check (is_blocker)->
    if blocker_status != is_blocker
      $(".hero.demo .modal .title span")
        .text("#{ if is_blocker then "MIZA" else "ADSENSE"  }")
        .removeClass("enabled disabled")
        .addClass("#{ if is_blocker then "enabled" else "disabled"  }")
        
      if not disable
        $(".iframe").attr("src", $('.iframe').attr("src"))
      
    blocker_status = is_blocker
    setTimeout blocker, 500


go_quotes = ->  
  if window.quotes_called?
    return
    
  window.quotes_called = true
  quotes = new QuotesSlider()
  
  
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
  
  
blocker_check = (callback)->
  $.ajax({
    url: "https://pagead2.googlesyndication.com/pagead/osd.js"
    dataType: "jsonp"
  }).fail (error)->
    callback error.status != 200