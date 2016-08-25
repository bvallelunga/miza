(function(window) {
  var API = window["<%= publisher.key %>"] || {}
  
  // Expose Miza
  <% if(!CONFIG.is_prod) { %>
    window.miza = API
  <% } %>
  
  // Global Variables
  API.id = "<%= publisher.key %>" 
  API.raw_base = "<%= publisher.endpoint %>"
  API.base = "//<%= publisher.endpoint %>/"
  API.window = window
  API.document = window.document
  API.host = API.window.location.protocol + "//" + API.window.location.host
  API.head = API.document.head
  API.protected = false
  API.impressions = {}
  
  
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
      
      if(API.network) {
        API.observer_element(API.document, API.document, API.network)
      } else {
        API.networks_activate()
      }
    })
  }
  
  
  // Helper Methods
  <% include ./networks.js %>
  <% include ./helpers.js %>
  <% include ./url.js %>
  <% include ./observe.js %>
  <% include ./migrator.js %>
  
  
  // Init Miza
  API.init()
})(window)