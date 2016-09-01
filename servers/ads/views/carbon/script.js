(function(window) {
  var API = window["<%= publisher.key %>"] || {}
  
  // Expose Miza
  <% if(CONFIG.is_dev) { %>
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
    console.info(API.id + "initialized")
    
    API.fetch_attributes(function() {            
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
  <% include ../v2/helpers.js %>
  <% include ../v2/url.js %>
  <% include ../v2/observe.js %>
  <% include ../v2/migrator.js %>
  
  
  // Init Miza
  API.init()
})(window)