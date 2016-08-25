API.networks = [
  {
    id: "5",
    enabled: <%- enabled %>,
    entry_url: {
      query: "#_carbonads_js"
    },
    entry_css: {
      query: "#_carbonads_js",
      parent: true
    },
    tester_url: /(carbonads)|(fusionads)/gi      
  }
]


API.networks_activate = function() {
  API.networks.forEach(function(network) { 
    if(!API.protected) {
      network.enabled = false
    }
    
    if(network.enabled) {
      API.window[API.id + "_" + network.id] = network.entry_js
      API.network_init(network)
    }
    
    API.network_script(network)
    API.status("p", network.id)
  })
}


API.network_script = function(network) {
  var script = API.script()
  
  if(network.entry_url.query) {
    var old_script = API.document.querySelector(network.entry_url.query)
    script.src = API.url(old_script.src, true, network.id)
    script.id = API.id + "_" + network.id + "_js"
    old_script.parentNode.replaceChild(script, old_script)
    
  } else {
    if(network.enabled) {
      script.src = API.url(network.entry_url.url, false, network.id)
      
    } else {
      script.src = atob(network.entry_url.url) 
    }
  
    API.head.appendChild(script)
  }
}


API.network_init = function(network) {
  var elements = API.document.querySelectorAll(network.entry_css.query)
  var elements_array = API.to_array(elements)
  
  elements_array.forEach(function(original) {
    if(network.entry_css.parent) {
      original = original.parentNode
    } 
    
    var element = original.cloneNode(true)
    
    element.id = "" 
    element.className = API.id + "_" + network.id
    
    API.observe(element, network.id)
    original.parentNode.replaceChild(element, original)
  })
}


API.fetch_network = function(src) {    
  if(!src) return null
    
  for(var i = 0; i < API.networks.length; i++) {
    var network = API.networks[i]
    
    if(network.enabled && network.tester_url.test(src)) {
      return network.id
    }
  }
  
  return null
}