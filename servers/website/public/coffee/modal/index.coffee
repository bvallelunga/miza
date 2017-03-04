$ ->
  title = document.title.split(" | ")[0].split(" ").join("_")

  $("form:not(.ignore)").on "submit", (e)->
    e.preventDefault()
    e.stopPropagation()
  
    form = $(this)
    hint = form.find(".error").text("").hide()
    button = form.find("button")
    original = button.html()
    waiting = button.data("waiting") or "sending"
    
    button.addClass("loading").html(waiting)
  
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
      window.config.csrf = json.csrf
      hint.text(json.message).show()
      form.find(".password").val ""
      form.find(".csrf").val json.csrf
      button.html(original).removeClass "loading"
      
      Intercom "trackEvent", "WEB.Form.#{title}", {
        success: false
        error: json.message
      }
      
      mixpanel.track "WEB.Form.#{title}", {
        success: false
        error: json.message
      }