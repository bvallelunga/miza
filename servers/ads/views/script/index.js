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
  API.limit = 10
  
  
  // Helper Methods
  <% include ./helpers.js %>
  <% include ./url.js %>
  <% include ./observe.js %>
  <% include ./refresh.js %>
  <% include ./impression.js %>
  
  
  // Init Method
  API.init = function() {
    API.fetch_attributes(function() {                        
      if(!!API.frame) {  
        API.impression_frame_init()
              
        if(<%- publisher.config.refresh.enabled %>) {
          API.refresh_init()
        }
      } else {
        API.status("p")
        API.impression_parent_init()
        
        if(API.protected && <%- enabled %>) {
          API.observe_init()
        }
      }
    })
  }
  
  // Init Miza
  API.init()
})(window)