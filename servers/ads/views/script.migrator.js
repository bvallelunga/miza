API.migrator = function(parent, element, network, to_replace) {     
  var path = element.src ? "src" : "href"
  var src = element.src || element.href
  var tagName = (element.tagName || "").toLowerCase()
  var network = network || API.fetch_network(src)
  
  console.log(network, src, element)
  
  if (!network) return element
    
  if(!!src && API.is_url(src)) {    
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
        API.natives.appendChild.apply(parent, [element])
        
        if(tagName == "script") {
          orginal.remove()
        }
      } 
    }
  }
  
  if(tagName == "iframe" && element.contentDocument != null) {    
    API.listeners(element.contentDocument, network)
    API.overrides(element.contentWindow, network)
    
    element.onload = function() {
      API.listeners(element.contentDocument, network)
    }
  }
  
  API.listeners(element, network)
  API.children(element).forEach(function(child) {
    API.migrator(element, child, network)
  }) 
  
  return element
}