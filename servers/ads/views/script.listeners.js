API.listeners = function(element, network) {  
  element.addEventListener('DOMNodeInserted', function(event) {
    event.stopImmediatePropagation()
    if(event.target == element) return 
    API.migrator(element, event.target, network)
  })
}