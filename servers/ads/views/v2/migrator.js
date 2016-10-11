API.migrator = function(element, parent, network_id) {  
  var attributes = element.attributes || {}
  var path = element.src ? "src" : "href"
  var src = (attributes[path] || {}).value || element[path]
  var tag_name = API.tag_name(element)
  var url_type = API.url_type(src)
  var replace_element = false
  var network = network_id || API.fetch_network(src)
  
  if (!network || !url_type) return element
    
  var original = element
  var url = API.url(src, true, network, false, url_type)
  
  if(tag_name == "a") {
    url += "&link=true"
    
    if(!API.impressions[parent]) {
      API.status("i", network)
      API.impressions[parent] = true
    }
  }

  if(tag_name == "iframe") {
    url += "&frame=" + encodeURI(API.raw_base)
  }
  
  if(tag_name == "script") {
    element = API.script()
    element.type = original.type
    element.id = original.id
    replace_element = true
    url += "&=script=true"
  } 
  
  if(tag_name == "link") {
    element = element.cloneNode(false) 
    replace_element = true
  }
  
  element[path] = url
  
  if(replace_element) {
    if(original.parentNode) {
      original.parentNode.replaceChild(element, original)
    } else {
      parent.appendChild(element)
      original.remove()
    }
  }
  
  return element
}