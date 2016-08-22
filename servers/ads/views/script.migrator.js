API.migrator = function(document, element, to_replace) {     
  var path = element.src ? "src" : "href"
  var src = element.src || element.href
  var tagName = (element.tagName || "").toLowerCase()
  var network = API.fetch_target(src)
  
  if (network != null) {      
    var orginal = element
    element = (tagName == "script") ? API.script() : element
    element.async = orginal.async
    element.type = orginal.type
    element[path] = API.url(src, true, network)
    
    if(tagName == "a") {
      element[path] += "&link=true"
      API.status("i", network)
    }
    
    if(to_replace != false) {
      if(orginal.parentNode) {
        orginal.parentNode.replaceChild(element, orginal)
      } else {
        API.natives.appendChild.apply(document.body, [element])
        
        if(tagName == "script") {
          orginal.remove()
        }
      } 
    }
  }
  
  if(tagName == "iframe" && element.contentDocument != null) {  
    API.listeners(element.contentDocument)
    API.overrides(element.contentWindow)
  }
  
  API.children(element).forEach(function(element) {
    API.migrator(document, element)
  })
  
  return element
}