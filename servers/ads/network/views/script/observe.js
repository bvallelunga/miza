API.observables = {
  query: [
    ".adsbygoogle", ".dp-ad-chrome iframe", "#_carbonads_js"
  ].join(","),
  xpaths: [
    "//body//script[contains(., 'OA_show')]/parent::*"
  ].join(" | ")
}


API.observe_init = function() {
  API.fetch_current()
  API.start_observing()
}

API.fetch_xpath = function() {
  if(!API.observables.xpaths)  return []
  
  var elements = []
  var nodes = document.evaluate(API.observables.xpaths, document, null, XPathResult.ANY_TYPE, null)
  var result = nodes.iterateNext()
  
  while (result) {
    elements.push(result)
    result = nodes.iterateNext()
  } 
  
  return elements;
}


API.fetch_current = function() {
  var query_elements = API.to_array(API.document.querySelectorAll(API.observables.query))
  var xpath_elements = API.fetch_xpath();
  var elements = query_elements.concat(xpath_elements);
  
  elements.filter(function(element) {
    return !element.attributes["m-ignore"]
  }).forEach(API.migrate)
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
      parent.style.position = "relative"
      parent.style.minHeight = event.data.height + "px"
      parent.style.minWidth = event.data.width + "px"
      element.style.position = "absolute"
      element.style.top = "50%"
      element.style.left = "50%"
      element.style.marginTop = "-" + event.data.height/2 + "px"
      element.style.marginLeft = "-" + event.data.width/2 + "px"
      element.width = event.data.width
      element.height = event.data.height
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