API.networks = [
  {
    id: "1",
    enabled: <%- enabled %>,
    entry_js: API.window["adsbygoogle"],
    entry_url: "aHR0cDovL3BhZ2VhZDIuZ29vZ2xlc3luZGljYXRpb24uY29tL3BhZ2VhZC9qcy9hZHNieWdvb2dsZS5qcw==",
    entry_css: ".adsbygoogle",
    tester_url: /(googlesyndication)|(googleadservices)|(doubleclick)|(googleads.g.doubleclick.net)/gi       
  }
]


API.networks_activate = function() {
  API.networks.forEach(function(network) {
    API.window[API.id + "_" + network.id] = network.entry_js
    API.network_init(network)
    API.network_script(network)
  })
}


API.network_script = function(network) {
  var script = API.script()
  script.src = API.url(network.entry_url, false, network.id)
  
  if(!network.enabled) {
    script.src = atob(network.entry_url) 
  }
  
  API.head.appendChild(script)
}


API.network_init = function(network) {
  var elements = API.window.document.querySelectorAll(network.entry_css)
  var elements_array = API.to_array(elements)
  
  elements_array.forEach(function(original) {
    var element = original.cloneNode(true);  
    
    //element.id = "" 
    //element.className = API.id + "_" + network.id
    
    API.observe(element, network.id)
    original.parentNode.replaceChild(element, original)
  })
}


API.fetch_network = function(src) {    
  if(!src) return null
    
  for(var i = 0; i < API.networks.length; i++) {
    var network = API.networks[i]
    
    if(network.tester_url.test(src)) {
      return network.id
    }
  }
  
  return null
}