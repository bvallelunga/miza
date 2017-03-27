$ ->
  simulator_update = ->
    $simulator = $(".simulator")
    img = $(".simulator-image").val()
    text = $(".simulator-description").val()
      .replace(/&/g, '&amp;')
      .replace(/>/g, '&gt;')
      .replace(/</g, '&lt;')
      .replace(/\n/g, '<br>')
  
    $simulator.find("strong").toggle (text or img) == ""
    $simulator.find("a").attr "href", $(".simulator-link").val() or "#"
    $simulator.find("div").html(text).toggle(text.length > 0)
    $simulator.find("img").attr("src", img).toggle(img.length > 0)
    
  
  if $("[role=uploadcare-uploader]").length > 0
    uploadcare.Widget('[role=uploadcare-uploader]').onChange (file)->
      simulator_update()
        
    uploadcare.Widget('[role=uploadcare-uploader]').onUploadComplete (file)->
      simulator_update()
  
    $(".simulator-watch").on "keyup", ->
      simulator_update()