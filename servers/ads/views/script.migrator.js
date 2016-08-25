API.migrator = function(element, parent, network) {  
  var src = element.src || element.href
  var network = network || API.fetch_network(src)
  var path = element.src ? "src" : "href"
  var tagName = API.tag_name(element)
  var url_type = API.url_type(src)
  
  console.debug(API.network, "migrator", src, url_type, element) 
  
  if (!network || !url_type) return element
    
  var orginal = element
  var url = API.url(src, true, network, false, url_type)
  
  if(tagName == "a") {
    url += "&link=true"
    API.status("i", network)
  }

  if(tagName == "iframe") {
    url += "&frame=" + encodeURI(API.raw_base)
  }    
  
  if(tagName == "script" || tagName == "link") {
    element = element.cloneNode(false) 
  }

  element[path] = url
  
  if(tagName == "link" || tagName == "script") {
    if(orginal.parentNode) {
      orginal.parentNode.replaceChild(element, orginal)
    } else {
      parent.appendChild(element)
      orginal.remove()
    } 
  }
  
  return element
}