window.QuotesSlider = class QuotesSlider 
  
  constructor: ->
    @quotes = $(".customers .view")
    @shortcuts = $(".customers .shortcut")
    @timeout = null
    @delay = 15000
    
    if @quotes.length > 1
      @next_timer 1  
    
    @shortcuts.click (e)=>
      @next $(e.target).index()
      
  
  next: (index)->    
    if index >= @quotes.length
      index = 0
      
    if @timeout?
      clearTimeout @timeout 
      
    @quotes.fadeOut 500
    @shortcuts.removeClass "active"
    
    setTimeout =>
      @quotes.eq(index).fadeIn 500
      @shortcuts.eq(index).addClass "active"
      
    , 500
    
    @next_timer index + 1
    
    
  next_timer: (index)->
    @timeout = setTimeout =>
      @next(index)
    , @delay
