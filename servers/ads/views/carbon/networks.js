API.networks = [
  {
    id: "<%= network.id %>",
    enabled: <%- enabled %>,
    entry_js: window["_carbonads"],
    entry_url: {
      query: "#_carbonads_js"
    },
    entry_css: {
      query: "#_carbonads_js",
      container: API.id + "_<%= network.id %>_c",
      container_flush: "#carbonads",
      parent: true,
      duplicates: new RegExp(API.id + "_<%= network.id %>_[0-9]")
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
    var is_shadow_blocking = document.querySelector(network.entry_css.query)
      .parentNode.querySelector("[hidden]")
    
    if(!network.enabled || (!!network.entry_js && !is_shadow_blocking)) return
    API.protected = true
    
    if(is_shadow_blocking) {
      var to_flush = document.querySelector(network.entry_css.container_flush)
    
      if(!!to_flush) {
        to_flush.remove()
      }
    }
    
    var old_script = API.document.querySelector(network.entry_url.query)
    
    if(!old_script) {
      return API.network_fallback(network)
    }
    
    var src = old_script.src || old_script.attributes["data-rocketsrc"].value
    script.src = API.url(src, true, network.id) + "&script=true&" + src.split("?")[1]
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
}


API.network_duplicates_check = function(element, network, callback) {
  if(!network.entry_css) return callback()
  
  if(network.entry_css.duplicates.test(element.id)) {
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
      return network.id
    }
  }
  
  return null
}