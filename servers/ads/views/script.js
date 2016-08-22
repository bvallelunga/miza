(function(window) {
  var API = {}
  
  // Global Variables
  API.id = "<%= publisher.key %>" 
  API.base = "//<%= publisher.endpoint %>/"
  API.window = window
  
  
  // Init Method
  API.init = function() {
    
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