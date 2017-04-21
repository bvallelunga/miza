API.impression_parent_init = function() {
  window.onscroll = function() {
    API.iframes.forEach(function(iframe) { 
      API.impression_check(iframe)
    })
  }
}


API.impression_check = function(iframe) {  
  var buffer = -5
  var rect = iframe.getBoundingClientRect()
  var in_view = (
    rect.top >= buffer &&
    rect.left >= buffer &&
    ((window.innerHeight || document.documentElement.clientHeight) - rect.bottom) >= buffer &&
    ((window.innerWidth || document.documentElement.clientWidth) - rect.right) >= buffer
  )
  
  if(in_view && !!iframe.contentWindow) {
    iframe.contentWindow.postMessage({
      name: "frame.impression"
    }, "*")
  }
}


API.impression_frame_init = function() { 
  API.impression = false
  
  window.parent.window.postMessage({
    name: "frame.impression",
    frame: API.frame
  }, "*")
  
  window.addEventListener("message", function(event) {        
    if(event.data.name == "frame.impression" && !API.impression) {
      API.impression = true
      API.status("i")
    }
  })
}