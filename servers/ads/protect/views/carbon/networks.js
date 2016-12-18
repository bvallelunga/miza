API.networks = [
  {
    name: "carbon",
    enabled: <%- enabled %>,
    entry_js: window["_carbonads"],
    entry_url: {
      query: "#_carbonads_js"
    },
    entry_css: {
      base: "carbon",
      query: "#_carbonads_js",
      container: API.id + "_c",
      container_flush: "#carbonads",
      parent: true,
      duplicates_regex: new RegExp(API.id + "_[0-9]"),
      duplicates: "div[id*=" + API.id + "_], div#carbonads"
    },
    tester_url: /(carbon)|(fusionads)|(buysellads)|(adsafeprotected)/gi
  }
]


API.networks_activate = function() {  
  API.networks.forEach(function(network) {    
    if(!API.protected) {
      network.enabled = false
    }
    
    if(network.enabled) {
      API.window[API.id] = network.entry_js
      API.network_init(network)
      API.network_script(network)
    }
    
    if(!API.network) { 
      API.status("p", network)
    }
  })
}

API.network_flush = function(network) {
  var to_flush = API.document.querySelector(network.entry_css.container_flush)
  if(to_flush) to_flush.remove()
}


API.network_script = function(network) {
  var script = API.script()
  
  if(network.entry_url.query) {
    var is_shadow_blocking = false
    var tmp_script = document.querySelector(network.entry_css.query)
    
    if(!!tmp_script) {
      var elements = API.to_array(tmp_script.parentNode.getElementsByTagName("*"))
      
      for(var i = 0; i < elements.length; i++) {
        var element = elements[i]
        
        if(element.style.display == "none !important") {
          is_shadow_blocking = true
          break
        }
      }
    } else {
      is_shadow_blocking = true
    }
    
    if(is_shadow_blocking) {
      API.network_flush(network)
    }
    
    var old_script = API.document.querySelector(network.entry_url.query)
    
    if(!old_script) {
      API.network_flush(network)
      return API.network_fallback(network)
    }

    var src = old_script.src || old_script.attributes["data-rocketsrc"].value
    script.src = API.url(src, true) + "&script=true&" + src.split("?")[1]
    script.id = API.id + "_js"
    
    old_script.parentNode.replaceChild(script, old_script) 
  } else {
    if(network.enabled) {
      script.src = API.url(network.entry_url.url, false)
      
    } else {
      script.src = atob(network.entry_url.url) 
    }
  
    API.head.appendChild(script)
  }
}


API.network_fallback = function(network) {
  console.log("fallback used")
  
  var xmlHttp = new XMLHttpRequest()
  xmlHttp.onreadystatechange = function() { 
    if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
      var html = document.createElement('html')
      var script = API.script()
      
      html.innerHTML = xmlHttp.responseText
      var old_script = html.querySelector(network.entry_url.query)
      var old_path = ""
      var node = old_script.parentNode
      
      while(node.tagName.toLowerCase() != "body") {
        var selector = node.tagName
        
        if(!!node.id) selector += ("#" + node.id)
        if(!!node.className) selector += ("." + API.to_array(node.classList).join("."))
        
        old_path = selector + " " + old_path
        node = node.parentNode
      }
      
      var parent_node = API.document.querySelector(old_path)
      script.src = API.url(old_script.src, true) + "&script=true&" + old_script.src.split("?")[1]
      script.id = API.id + "_js"
      parent_node.appendChild(script)
      
      API.network_flush(network)
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
      return API.observe(original, network)
    } else {
      span.remove()
    }
          
    var element = original.cloneNode(true)
  
    element.id = "" 
    element.className = network.entry_css.container
    element.removeAttribute("hidden")
    element.style.display = ""
    
    API.observe(element, network)
    original.parentNode.replaceChild(element, original)
  })
  
  setInterval(function() {
    var elements = API.to_array(API.document.querySelectorAll(network.entry_css.duplicates))

    elements.forEach(function(element) {
      element.remove()
    })
  }, 100)
}


API.network_duplicates_check = function(element, network, callback) {
  if(network.entry_css.duplicates_regex.test(element.id)) {
    return element.remove()
  }
  
  callback()
}


API.fetch_network = function(src) {    
  if(!src) return null
  
  for(var i = 0; i < API.networks.length; i++) {
    var network = API.networks[i]
    var tester = new RegExp(network.tester_url)
    
    if(network.enabled && tester.test(src)) {
      return network
    }
  }
  
  return null
}