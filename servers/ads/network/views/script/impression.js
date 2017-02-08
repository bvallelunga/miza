API.impression_init = function() {  
  window.onfocus = function() {
    API.iframes.forEach(function(iframe) {
      iframe.contentWindow.postMessage({
        name: "parent.impression"
      }, "*")
    })
  }
}

API.impression = function() { 
  API.impressed = false
  
  window.parent.window.postMessage({
    name: "frame.focused",
    frame: API.frame
  }, "*")
  
  window.addEventListener("message", function(event) {    
    if(event.data.name == "parent.impression" && !API.impressed) {
      API.status("i")
      API.impressed = true
    }
  })
}