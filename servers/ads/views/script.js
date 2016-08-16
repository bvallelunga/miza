(function(window) {
  var API = window["<%= publisher.key %>"] = {}
  
  <% networks.forEach(function(network) { %>
    window["<%= publisher.key %>_<%= network.id %>"] = <%= network.entry_js %>
  <% }) %>
  
  API.s_init = function() {
    API.s_id = "<%= publisher.key %>" 
    API.s_base = "//<%= publisher.endpoint %>/" 
    API.s_prod = <%= CONFIG.isProd %>
    API.s_window = window
    API.s_head = document.head
    API.s_targets = {}
    API.s_targets_list = []
    API.s_natives = {}
    API.s_attribute_params = ""
    API.s_attributes = {
      "battery": {},
      "demensions": {},
      "plugins": [],
      "languages": [],
      "components": [],
      "do_not_track": false,
      "protected": false,
      "random": "<%= random_slug %>"
    }
    
    <% networks.forEach(function(network) { %>
      var target = new RegExp("<%= network.targets %>")
      API.s_targets[target] = "<%= network.id %>"
      API.s_targets_list.push(target)
    <% }) %>
    
    <% if(enabled) { %> 
      API.s_listeners(window.document)
      API.s_overrides(window)
    <% } %>
    
    API.s_fetch_attributes(window, API.s_start)
  }
  
  API.s_start = function() {
    <% networks.forEach(function(network) { %> 
      var script = API.s_script()
      
      <% if(enabled) { %>
        script.src = API.s_url("<%= network.entry_url %>", false, "<%= network.id %>")
      <% } else { %>
        script.src = "<%= network.entry_raw_url %>"
      <% } %>
      
      API.s_head.appendChild(script)
    <% }) %>
    
    API.s_status("p")
  }
  
  API.s_overrides = function(w) {       
    [
      [w.Element.prototype, "appendChild"],
      [w.Element.prototype, "insertBefore"],
      [w.Document.prototype, "appendChild"],
      [w.Document.prototype, "insertBefore"],
      [w.Document.prototype, "writeln"],
      [w.Document.prototype, "write"],
      [w.document, "appendChild"],
      [w.document, "insertBefore"],
      [w.document, "writeln"],
      [w.document, "write"]
    ].forEach(function(override) {
      var method = API.s_natives[override[1]] = API.s_natives[override[1]] || override[0][override[1]]
      override[0][override[1]] = API.s_method_override(w, method)
    }) 
  }
  
  API.s_method_override = function(window, method) {
    return function(content) {      
      if(["writeln", "write"].indexOf(method.name) > -1) {
        return API.s_override_writeln(window, this, content, method) 
      }
      
      for(var i = 0; i < arguments.length; i++) {
        node = arguments[i]
        
        if(node instanceof Element) {
          arguments[i] = API.s_migrator(window.document, node, false)
        }
      }
    
      return method.apply(this, arguments)
    }
  }
  
  API.s_override_writeln = function(window, document, content, method) {  
    if(navigator.userAgent.toLowerCase().indexOf('firefox') > -1){
      return method.apply(document, [content])
    }
    
    if(method.name == "write") {
      API.s_natives.write.apply(document, [""])
      API.s_listeners(document)
      API.s_overrides(window)
    }
      
    var out = API.s_cleaner(document, content)
    API.s_natives.writeln.apply(document, [out[0]])
    document.head.appendChild(out[1])
    
    API.s_children(document).forEach(function(element) {
      API.s_migrator(document, element)
    })
  } 
  
  API.s_fetch_attributes = function(window, callback) {
    var attributes = Object.keys(API.s_attributes)
     
    attributes.forEach(function(key, i) {
      switch(key) {        
        case "battery":
          if(!window.navigator.getBattery) break
          
          window.navigator.getBattery().then(function(battery) {
            API.s_attributes[key] = {
              charging: battery.charging,
              charging_time: battery.chargingTime,
              level: battery.level
            }
          })
          
          break
          
        case "demensions":
          API.s_attributes[key] = {
            width: window.innerWidth,
            height: window.innerHeight
          }
          break
      
        case "protected":
          API.s_blocker_check(window, function(value) {
            API.s_attributes[key] = value
          })
          break
          
        case "plugins":
          API.s_attributes[key] = Object.keys(window.navigator.plugins || []).map(function(id) {  
            var plugin = navigator.plugins[id]
            
            return {
              filename: plugin.filename,
              description: plugin.description,
              name: plugin.name
            }
          }) 
          break
          
        case "languages":
          API.s_attributes[key] = window.navigator.languages || []
          break
          
        case "components":
          if(!window.navigator.mediaDevices) break
        
          window.navigator.mediaDevices.enumerateDevices().then(function(devices) {
            API.s_attributes[key] = devices.map(function(device) {
              return {
                device_id: device.deviceId,
                group_id: device.groupId,
                kind: device.kind,
                label: device.label
              }
            })
          })
          break
          
        case "do_not_track":
          API.s_attributes[key] = window.navigator.doNotTrack == "1"
          break
      }
      
      if(i == attributes.length-1) {
        setTimeout(function() {
          API.s_attribute_params = API.s_serialize(API.s_attributes)
          callback()
        }, 500)
      } 
    })
  }
  
  API.s_serialize = function(obj, prefix) {
    var str = [];
    for(var p in obj) {
      if (obj.hasOwnProperty(p)) {
        var k = prefix ? prefix + "[" + p + "]" : p, v = obj[p];
        str.push(typeof v == "object" ?
          API.s_serialize(v, k) :
          encodeURIComponent(k) + "=" + encodeURIComponent(v));
      }
    }
    return str.join("&");
  }
    
  API.s_listeners = function(document) {
    if(!document) return
    
    document.addEventListener('DOMNodeInserted', function(event) {
      API.s_migrator(document, event.target) 
    })
  }
  
  API.s_url = function(url, encode, network) {    
    var encoded = (encode != false) ? btoa(url) : url
  
    return (
      API.s_base + encoded + "?" + API.s_attribute_params +
      (network ? ("&network=" + network) : "")
    )
  }
  
  API.s_script = function() {
    var script = document.createElement('script')
    script.async = true
    script.setAttribute('type', 'text/javascript')
    return script
  }
	  
  API.s_cleaner = function(document, text) {         
    var script = API.s_script()
    var cleaned = text.replace(/<script(.*?)>([\s\S]*?)<\/script>/gi, function() {
      if(arguments[1].indexOf("src") > -1) 
        return arguments[0]
      
      script.text += arguments[2] + ';'
      return ''
    });

    return [cleaned, script]
  }
  
  API.s_blocker_check = function(window, callback) {
    var test = document.createElement('div')
    test.innerHTML = '&nbsp;'
    test.className = 'adsbox'
    window.document.body.appendChild(test)
    
    window.setTimeout(function() {
      callback(test.offsetHeight == 0)
      test.remove()
    }, 100)
  }
  
  API.s_status = function(status, network) {
    var img = document.createElement('img')
    img.src = API.s_url(status, false, network)
    img.style.display = "none"
    document.body.appendChild(img)
    img.onload = function() {
      img.remove()
    }
  }
  
  API.s_fetch_target = function(src) {  
    if(!src) return null
      
    for(var i = 0; i < API.s_targets_list.length; i++) {
      var tester = API.s_targets_list[i]
      
      if(tester.test(src)) {
        return API.s_targets[tester]
      }
    }
    
    return null
  }
  
  API.s_children = function(element) {
    return Array().slice.call(element.getElementsByTagName("*"))
  } 
  
  API.s_migrator = function(document, element, to_replace) {     
    var path = element.src ? "src" : "href"
    var src = element.src || element.href
    var tagName = (element.tagName || "").toLowerCase()
    var network = API.s_fetch_target(src)
    
    if (network != null) {      
      var orginal = element
      element = (tagName == "script") ? API.s_script() : element
      element.async = orginal.async
      element.type = orginal.type
      element[path] = API.s_url(src, true, network)
      
      if(tagName == "a") {
        element[path] += "&link=true"
        API.s_status("i", network)
      }
      
      if(to_replace != false) {
        if(orginal.parentNode) {
          orginal.parentNode.replaceChild(element, orginal)
        } else {
          API.s_natives.appendChild.apply(document.body, [element])
          
          if(tagName == "script") {
            orginal.remove()
          }
        } 
      }
    }
    
    if(tagName == "iframe" && element.contentDocument != null) {    
      API.s_listeners(element.contentDocument)
      API.s_overrides(element.contentWindow)
    }
    
    API.s_children(element).forEach(function(element) {
      API.s_migrator(document, element)
    })
    
    return element
  }
  
  API.s_init()
})(window)