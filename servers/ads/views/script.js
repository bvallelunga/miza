(function(window) {
  var API = window["<%= publisher.key %>"] || {}
  
  // Global Variables
  API.id = "<%= publisher.key %>" 
  API.base = "//<%= publisher.endpoint %>/"
  API.window = window
  API.document = window.document
  API.head = API.document.head
  API.protected = false
  
  
  // Init Method
  API.init = function() {
    API.fetch_attributes(function() {
      // TODO: remove when finished
      API.protected = true
      
      if(API.protected) {
        API.observe_init(API.window)
        API.observe(API.document.head, API.network)
        API.observe(API.document.body, API.network)
      }
      
      if(!API.network) {
        API.networks_activate()
      }
    })
  }
  
  
  // Helper Methods
  <% include ./script.networks.js %>
  <% include ./script.helpers.js %>
  <% include ./script.url.js %>
  <% include ./script.observe.js %>
  <% include ./script.migrator.js %>
  
  
  // Init Miza
  API.init()
  
  
  // Expose Miza
  <% if(!CONFIG.is_prod) { %>
    window[API.id] = API
  <% } %>
})(window)