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
    window.location.href = "#information"
  
    
  $(".products .information .close").click ->
    $(".products .product").removeClass "active"
    $(".products .information").slideUp 500
  

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