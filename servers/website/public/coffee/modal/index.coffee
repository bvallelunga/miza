$ ->
  $("form").on "submit", (e)->
    e.preventDefault()
    e.stopPropagation()
  
    form = $(this)
    hint = form.find(".error")
  
    $.post(form.attr("action"), form.serialize(), (response)->  
      window.location.href = response.next
    
    ).fail (error)->
      hint.text error.responseJSON.message
      form.find("input").val ""