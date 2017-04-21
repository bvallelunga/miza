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
    
  $simulator = $(".simulator-iframe") 
  
  if $simulator.data("src") 
    $simulator.attr("src", $simulator.data("src")) 
  
  window.addEventListener("message", (event)->  
    element = document.querySelector(".simulator-iframe")
    
    if event.data.name == "frame.show"
      parent = element.parentNode
      parent.style.position = "relative"
      parent.style.minHeight = event.data.height + "px"
      parent.style.minWidth = event.data.width + "px"
      parent.style.width = "100%"
      parent.style.height = "100%"
      element.style.position = "absolute"
      element.style.top = "50%"
      element.style.left = "50%"
      element.style.marginTop = "-" + event.data.height/2 + "px"
      element.style.marginLeft = "-" + event.data.width/2 + "px"
      element.width = event.data.width
      element.height = event.data.height
      element.style.display = "block"
      
      if parent.offsetHeight > parent.offsetWidth and parent.style.height == "100%"
        parent.style.height = event.data.height + "px"
    
  , false)