class Dashboard  
  
  constructor: ->         
    $(".billing.actions .action").click (e)->   
      $spinner = $(@).find(".fa-spin").show()
      $original = $(@).find(":not(.fa-spin)").hide()
          
      $.post("/demand/#{config.advertiser}/billing/charges", {
        _csrf: config.csrf
        action: $(@).data("action")
      }).done ->
        window.location.reload()
        
      .fail (error)->
        message = error.responseJSON.message
        
        $(".container").prepend(
          "<div class='warning orange'>#{message}</div>"
        )
        
        window.scrollTo(0,0);

     
$ ->
  if not $(".container").hasClass "billing-dashboard"
    return

  dashboard = new Dashboard()