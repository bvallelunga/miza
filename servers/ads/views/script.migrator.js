API.migrator = function(element, parent, network) {  
  var src = element.src || element.href
  var network = network || API.fetch_network(src)
  
  console.debug(API.network, "migrator", element.m_handled, element) 
  
  if (!network || !src || tagName != "iframe") return element
    
  var path = element.src ? "src" : "href"
  var tagName = API.tag_name(element)
  var orginal = element
  var url = API.url(src, true, network, false)
  
  if(tagName == "a") {
    url += "&link=true"
    API.status("i", network)
  }

  if(tagName == "iframe") {
    url += "&frame=" + encodeURI(API.base)
  }    
  
  if(tagName == "script" || tagName == "link") {
    element = element.cloneNode(false) 
  }

  element[path] = url
  
/*
    if(tagName == "script" || tagName == "link") {
      if(orginal.parentNode) {
        orginal.parentNode.replaceChild(element, orginal)
      } else {
        parent.appendChild(element)
        orginal.remove()
      } 
    }
*/
  
  return element
}