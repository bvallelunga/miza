API.natives = {}

API.overrides = function(w) {    
  Array(
    [w.Element.prototype, "appendChild"],
    [w.Element.prototype, "insertBefore"],
    [w.Document.prototype, "appendChild"],
    [w.Document.prototype, "insertBefore"],
    [w.Document.prototype, "writeln"],
    [w.Document.prototype, "write"],
    [w.document, "appendChild"],
    [w.document, "insertBefore"],
    [w.document, "writeln"],
    [w.document, "write"]
  ).forEach(function(override) {
    var method = API.natives[override[1]] = API.natives[override[1]] || override[0][override[1]]
    override[0][override[1]] = API.method_override(w, method)
  }) 
}


API.method_override = function(window, method) {
  return function(content) {      
    if(["writeln", "write"].indexOf(method.name) > -1) {
      return API.override_writeln(window, this, content, method) 
    }
    
    for(var i = 0; i < arguments.length; i++) {
      node = arguments[i]
      
      if(node instanceof Element) {
        arguments[i] = API.migrator(window.document, node, false)
      }
    }
  
    return method.apply(this, arguments)
  }
}


API.override_writeln = function(window, document, content, method) {  
  content = content.replace(/(?:src|href)=["|']([^"]*)["|']/gi, function(match, url) {
    var network = API.fetch_target(url)
    
    if(!network) return match
    
    return match.replace(url, API.url(url, true, network))
  })
  
  if(navigator.userAgent.toLowerCase().indexOf('firefox') > -1){
    return method.apply(document, [content])
  }
  
  if(method.name == "write") {
    API.natives.write.apply(document, [""])
    API.listeners(document)
    API.overrides(window)
  }
    
  var out = API.cleaner(document, content)
  API.natives.writeln.apply(document, [out[0]])
  document.head.appendChild(out[1])
  
  API.children(document).forEach(function(element) {
    API.migrator(document, element)
  })
} 