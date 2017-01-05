$ ->
  
  quotes = $(".customers .view")
  index = 0
  
  setInterval ->
    index++
    
    if index == quotes.length
      index = 0
      
    quotes.fadeOut 500
    
    setTimeout ->
      quotes.eq(index).fadeIn 500
      
    , 500
    
  , 5000