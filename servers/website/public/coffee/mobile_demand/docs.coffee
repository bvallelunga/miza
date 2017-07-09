$ ->
  if not $(".container").hasClass "docs-dashboard"
    return false
    
  check = ->    
    $(".display .section").each ->
      if $(@).visible(true)
        $(".sidebar ul li").removeClass("active")
        $(".sidebar-#{$(@).attr("id")}").addClass("active")
        return false
        
  $(window).scroll check
  check()