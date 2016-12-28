API.observers = {}

API.observe = function(element, network) {
  element = element.isProxyNode ? element.proxiedNode : element
  var observer = API.observers[(network || {}).id] || API.observer(element, network)
  API.observers[(network || {}).id] = observer
    
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
        if(!network) {
          return API.observer_element(element, parent, network)
        }
        
        API.network_duplicates_check(element, network, function() {
          API.observer_element(element, parent, network)
        })
      })
    })
  })
}

API.observer_iframe = function(element, network) {  
  if(API.url_type(element.src)) return
 
  API.observe_init(element.contentWindow)
  API.observe(element.contentDocument, network)
  API.observer_element(element.contentDocument, element, network, false)
  
  element.addEventListener('load', function() {
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
