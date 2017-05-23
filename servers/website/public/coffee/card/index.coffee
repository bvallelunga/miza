$ ->
  title = document.title.split(" | ")[0].split(" ").join("_")
  Stripe.setPublishableKey(config.stripe_key)

  $(".form.card").card({
    container: '.card-wrapper'
    placeholders: {
      number: '**** **** **** ****',
      name: 'Tony Stark',
      expiry: '** / ****',
      cvc: '***'
    }
  })
  
  $("form:not(.loading)").on "submit", (e)->
    e.preventDefault()
    e.stopPropagation()
    
    form = $(this)
    hint = form.find(".error").text("").hide()
    button = form.find("button")
    original = button.text()
    error_handler = (message)->
      hint.text(message).show()
      button.text(original).removeClass "loading"
    
    button.addClass("loading").text("sending")
    
    Stripe.card.createToken form, (status, response)->
      if response.error?
        return error_handler response.error.message
        
      response._csrf = config.csrf
      response.next = config.next
      $.post form.attr("action"), response, (response)->
        if response.message?
          alert response.message
        
        mixpanel.track "WEB.Form.#{title}", {
          success: true
        }
        
        Intercom "trackEvent", "WEB.Form.#{title}", {
          success: true
        }
        
        window.location.href = response.next
        
      .fail (error)->
        json = error.responseJSON
        error_handler json.message
        form.find(".csrf").val json.csrf
        
        Intercom "trackEvent", "WEB.Form.#{title}", {
          success: false
          error: json.message
        }
        
        mixpanel.track "WEB.Form.#{title}", {
          success: false
          error: json.message
        }
