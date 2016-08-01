$ ->
  $("form").on "submit", (e)->
    e.preventDefault()
    e.stopPropagation()
  
    form = $(this)
    hint = form.find(".error")
    button = form.find("button").addClass("loading").text("sending")
  
    $.post(form.attr("action"), form.serialize(), (response)->  
      if response.message?
        alert response.message
      
      window.location.href = response.next
    
    ).fail (error)->
      json = error.responseJSON
      hint.text json.message
      form.find(".password").val ""
      form.find(".csrf").val json.csrf
      button.removeClass "loading"