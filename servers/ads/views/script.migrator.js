API.migrator = function(element, parent, network) {  
  var attributes = element.attributes || {}
  var path = element.src ? "src" : "href"
  var src = (attributes[path] || {}).value || element[path]
  var network = network || API.fetch_network(src)
  var tag_name = API.tag_name(element)
  var url_type = API.url_type(src)
  
  if (!network || !url_type) return element
    
  var orginal = element
  var url = API.url(src, true, network, false, url_type)
  
  if(tag_name == "a") {
    url += "&link=true"
    API.status("i", network)
  }

  if(tag_name == "iframe") {
    url += "&frame=" + encodeURI(API.raw_base)
  }    
  
  if(tag_name == "script" || tag_name == "link") {
    element = element.cloneNode(false) 
  }

  element[path] = url
  
  if(tag_name == "link" || tag_name == "script") {
    if(orginal.parentNode) {
      orginal.parentNode.replaceChild(element, orginal)
    } else {
      parent.appendChild(element)
      orginal.remove()
    } 
  }
  
  return element
}