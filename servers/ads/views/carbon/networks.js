API.networks = [
  {
    id: "5",
    enabled: <%- enabled %>,
    entry_js: window["_carbonads"],
    entry_url: {
      query: "#_carbonads_js"
    },
    entry_css: {
      query: "#_carbonads_js",
      container: API.id + "_5_c",
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
    
    if(!API.network) { 
      API.status("p", network.id)
    }
  })
}


API.network_script = function(network) {
  var script = API.script()
  
  if(network.entry_url.query) {
    if(!network.enabled) return
    
    if(API.protected = !network.entry_js) {  
      var old_script = API.document.querySelector(network.entry_url.query)
      if(!old_script) {
        return API.network_fallback(network)
      }
      
      var src = old_script.src || old_script.attributes["data-rocketsrc"].value
      script.src = API.url(src, true, network.id) + "&script=true&" + src.split("?")[1]
      script.id = API.id + "_" + network.id + "_js"
      old_script.parentNode.replaceChild(script, old_script) 
    }
  } else {
    if(network.enabled) {
      script.src = API.url(network.entry_url.url, false, network.id)
      
    } else {
      script.src = atob(network.entry_url.url) 
    }
  
    API.head.appendChild(script)
  }
}


API.network_fallback = function(network) {
  var xmlHttp = new XMLHttpRequest()
  xmlHttp.onreadystatechange = function() { 
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
      var html = document.createElement('html')
      var script = API.script()
      
      html.innerHTML = xmlHttp.responseText
      var old_script = html.querySelector(network.entry_url.query)
      
      network.entry_css.parent = false
      network.entry_css.query = (
        "#" + old_script.parentNode.id + 
        API.to_array(old_script.parentNode.classList).join(".")
      )
      API.network_init(network)
      
      var parent_node = API.document.querySelector("." + network.entry_css.container)
      script.src = API.url(old_script.src, true, network.id) + "&script=true&" + old_script.src.split("?")[1]
      script.id = API.id + "_" + network.id + "_js"
      parent_node.appendChild(script)
    }
  }
  xmlHttp.open("GET", window.location.href, true)
  xmlHttp.send(null)
}


API.network_init = function(network) {
  var elements = API.document.querySelectorAll(network.entry_css.query)
  var elements_array = API.to_array(elements)
  
  elements_array.forEach(function(original) {
    if(network.entry_css.parent) {
      original = original.parentNode
    } 
    
    var span = document.createElement("span")
    span.innerHTML += '&nbsp;'
    original.appendChild(span)

    if(original.offsetHeight > 0) {
      span.remove()
      return API.observe(original, network.id)
    }
          
    var element = document.createElement("div")
  
    element.id = "" 
    element.className = network.entry_css.container
    
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