API.iframes_refresh = []

API.refresh_iframes = function() {  
  var iframe = API.iframes_refresh.pop()
  
  while(iframe != null) {
    iframe.contentWindow.postMessage({
      name: "frame.reload"
    }, "*")
    
    iframe = API.iframes_refresh.pop()
  }
}

API.refresh_init = function() { 
  window.setTimeout(function() {
    window.parent.window.postMessage({
      name: "frame.reload",
      frame: API.frame
    }, "*")
  }, <%- publisher.config.refresh.interval * 1000 %>)
  
  window.addEventListener("message", function(event) {    
    if(event.data.name == "frame.reload") {
      window.location.reload()
    }
  })
}