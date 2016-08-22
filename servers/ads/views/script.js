(function(window) {
  var API = {}
  
  // Global Variables
  API.id = "<%= publisher.key %>" 
  API.base = "//<%= publisher.endpoint %>/"
  API.window = window
  API.document = window.document
  API.head = API.document.head
  
  
  // Init Method
  API.init = function() {
    API.fetch_attributes(function() {
      API.overrides(API.window)
      //API.listeners(API.document)
      API.networks_activate()
    })
  }
  
  
  // Helper Methods
  <% include ./script.networks.js %>
  <% include ./script.helpers.js %>
  <% include ./script.url.js %>
  <% include ./script.overrides.js %>
  <% include ./script.listeners.js %>
  <% include ./script.migrator.js %>
  
  
  // Init Miza
  API.init()
  
  
  // Expose Miza
  <% if(!CONFIG.is_prod) { %>
    window[API.id] = API
  <% } %>
})(window)