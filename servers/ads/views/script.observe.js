API.observers = {}

API.observe = function(element, network) {
  var observer = API.observers[network] || API.observer(element, network)
  API.observers[network] = observer
    
  observer.observe(element, { 
    attributes: true,
    childList: true,
    subtree: !!network
  })
}

API.observe_init = function(window) {
  window.Document.prototype.m_handled = false
  window.Element.prototype.m_handled = false
}

API.observer = function(parent, network) {
  return new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {      
      API.to_array(mutation.addedNodes).forEach(function(element) {
        API.observer_element(element, parent, network)
      })
    })
  })
}

API.observer_iframe = function(element, network) {  
  if(API.url_type(element.src)) return
 
  API.observe_init(element.contentWindow)
  API.observe(element.contentDocument, network)
  API.observer_element(element.contentDocument, element, network, false)
  
  console.debug(API.network, "iframe", element) 
  
  element.addEventListener('load', function() {
    console.debug(API.network, "loaded", element)
    API.observer_iframe(element, network)
  })
} 

API.observer_element = function(element, parent, network, from_observer) {
  if(element.m_handled) return
  
  if(API.tag_name(element) == "iframe") {     
    if(from_observer != true) { 
      API.observer_iframe(element, network)
    }
  } else {
    element.m_handled = true
  }
  
  API.migrator(element, parent, network)
  
  API.to_array(element.children).forEach(function(child) {
    API.observer_element(child, element, network)
  })
}
