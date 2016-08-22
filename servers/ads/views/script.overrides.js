API.natives = {}

API.overrides = function(window, network) {    
  Array(
    [window.Element.prototype, "appendChild"],
    [window.Element.prototype, "insertBefore"],
    [window.Document.prototype, "appendChild"],
    [window.Document.prototype, "insertBefore"],
    [window.Document.prototype, "writeln"],
    [window.Document.prototype, "write"],
    [window.document, "appendChild"],
    [window.document, "insertBefore"],
    [window.document, "writeln"],
    [window.document, "write"]
  ).forEach(function(override) {        
    var method = API.natives[override[1]] = API.natives[override[1]] || override[0][override[1]]
    
    if(network || ["writeln", "write"].indexOf(override[1]) == -1) {
      override[0][override[1]] = API.method_override(window, method, network)
    }
  }) 
}


API.method_override = function(window, method, network) {
  return function(content) {      
    if(["writeln", "write"].indexOf(method.name) > -1) {
      return API.override_writeln(window, this, content, method, network) 
    }
    
    for(var i = 0; i < arguments.length; i++) {
      node = arguments[i]
      
      if(node instanceof Element) {
        arguments[i] = API.migrator(window.document, node, network, false)
      }
    }
  
    return method.apply(this, arguments)
  }
}


API.override_writeln = function(window, document, content, method, network) {  
  content = content.replace(/(?:src|href)=["|']([^"]*)["|']/gi, function(match, url) {    
    return match.replace(url, API.url(url, true, network))
  })
  
  if(navigator.userAgent.toLowerCase().indexOf('firefox') > -1){
    return method.apply(document, [content])
  }
  
  if(method.name == "write") {
    API.natives.write.apply(document, ["<html><head></head><body></body></html>"])
    API.overrides(window, network)
  }
    
  var out = API.cleaner(document, content)
  API.natives.writeln.apply(document, [out[0]])
  document.head.appendChild(out[1])
} 