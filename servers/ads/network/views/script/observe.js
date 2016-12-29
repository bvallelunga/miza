API.observables = [
  ".adsbygoogle", ".dp-ad-chrome iframe", "#_carbonads_js"
].join(",")


API.observe_init = function() {
  API.fetch_current()
  API.start_observing()
}


API.fetch_current = function() {
  var elements = API.to_array(API.document.querySelectorAll(API.observables))
  elements.forEach(API.migrate)
}


API.start_observing = function() {
  var observer = API.observer()
  
  observer.observe(API.document.body, { 
    attributes: true,
    childList: true,
    subtree: true
  })
  
  window.addEventListener("message", function(event) {
    if(event.data.name == "frame.remove") {
      var element = API.document.querySelector("." + event.data.frame)
      element.parentNode.parentNode.removeChild(element.parentNode)
    }
    
    if(event.data.name == "frame.show") {
      var element = API.document.querySelector("." + event.data.frame)
      var parent = element.parentNode
      parent.style.width = element.width = event.data.width
      parent.style.height = element.height = event.data.height
      element.style.display = "block"
    }
  }, false);
}


API.observer = function() {
  return new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {      
      API.to_array(mutation.addedNodes).forEach(function(element) {
        if(API.element_matches(element, API.observables)) {
          API.migrate(element)
        }        
      })
    })
  })
}


API.migrate = function(element) {
  var iframe = API.iframe(element);
  element.parentNode.replaceChild(iframe, element);
}