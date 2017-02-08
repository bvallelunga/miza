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
  API.protected = false
  
  
  // Init Method
  API.init = function() {
    API.fetch_attributes(function() {                        
      if(!!API.frame) {
        API.impression()
      } else if(API.protected) {
        API.status("p")
        
        if(<%- enabled %>) {
          API.observe_init()
          API.impression_init()
        }
      }
    })
  }
  
  // Helper Methods
  <% include ./helpers.js %>
  <% include ./url.js %>
  <% include ./observe.js %>
  <% include ./impression.js %>
  
  
  // Init Miza
  API.init()
})(window)