$ ->
  title = document.title.split(" | ")[0].split(" ").join("_")

  $("form").on "submit", (e)->
    e.preventDefault()
    e.stopPropagation()
  
    form = $(this)
    hint = form.find(".error").text ""
    button = form.find("button").addClass("loading")
    original = button.text()
    
    button.text("sending")
  
    $.post(form.attr("action"), form.serialize(), (response)->  
      if response.message?
        alert response.message
      
      mixpanel.track "WEB.Form.#{title}", {
        success: true
      }
      
      Intercom "trackEvent", "WEB.Form.#{title}", {
        success: true
      }
      
      window.location.href = response.next
    
    ).fail (error)->
      json = error.responseJSON
      hint.text json.message
      form.find(".password").val ""
      form.find(".csrf").val json.csrf
      button.text(original).removeClass "loading"
      
      Intercom "trackEvent", "WEB.Form.#{title}", {
        success: false
        error: json.message
      }
      
      mixpanel.track "WEB.Form.#{title}", {
        success: false
        error: json.message
      }