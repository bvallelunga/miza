$ ->
  go_quotes()
  old_product = ""
  
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
    
    
  blocker_check (is_blocker)->
    $(".hero.demo .modal .title span")
      .text("#{ if is_blocker then "ENABLED" else "DISABLED"  }")
      .addClass("#{ if is_blocker then "enabled" else "disabled"  }")
  

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
  test = document.createElement('div')
  test.innerHTML = '&nbsp;'
  test.className = 'adsbox googleads carbonads adsbygoogle'
  document.body.appendChild(test)
  
  setTimeout ->
    ghostry = document.querySelector("#ghostery-box")
    callback test.offsetHeight == 0 or !!ghostry
    test.remove()
    
  , 300