API.listeners = function(document) {
  if(!document) return
  
  document.addEventListener('DOMNodeInserted', function(event) {
    API.migrator(document, event.target) 
  })
}