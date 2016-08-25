(function(window) {
  var API = window["<%= publisher.key %>"] = {}
  
  <% networks.forEach(function(network) { %>
    window["<%= publisher.key %>_<%= network.id %>"] = <%= network.entry_js %>
  <% }) %>
  
  API.init = function() {
    API.id = "<%= publisher.key %>" 
    API.base = "//<%= publisher.endpoint %>/" 
    API.prod = <%= CONFIG.is_prod %>
    API.window = window
    API.head = document.head
    API.networks = []
    API.targets = {}
    API.targets_keys = []
    API.natives = {}
    API.attribute_params = ""
    API.attributes = {
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
      API.targets[target] = "<%= network.id %>"
      API.targets_keys.push(target)
      API.networks.push("<%= network.id %>")
    <% }) %>
    
    <% if(enabled) { %> 
      API.listeners(window.document)
      API.overrides(window)
    <% } %>
    
    API.fetch_attributes(window, API.start)
  }
  
  API.start = function() {
    <% networks.forEach(function(network) { %> 
      var script = API.script()
      
      <% if(enabled) { %>
        script.src = API.url("<%= network.entry_url %>", false, "<%= network.id %>")
      <% } else { %>
        script.src = "<%= network.entry_raw_url %>"
      <% } %>
      
      API.head.appendChild(script)
    <% }) %>
    
    API.status("p")
  }
  
  API.overrides = function(w) {    
    Array(
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
    ).forEach(function(override) {
      var method = API.natives[override[1]] = API.natives[override[1]] || override[0][override[1]]
      override[0][override[1]] = API.method_override(w, method)
    }) 
  }
  
  API.method_override = function(window, method) {
    return function(content) {      
      if(["writeln", "write"].indexOf(method.name) > -1) {
        return API.override_writeln(window, this, content, method) 
      }
      
      for(var i = 0; i < arguments.length; i++) {
        node = arguments[i]
        
        if(node instanceof Element) {
          arguments[i] = API.migrator(window.document, node, false)
        }
      }
    
      return method.apply(this, arguments)
    }
  }
  
  API.override_writeln = function(window, document, content, method) {  
    content = content.replace(/(?:src|href)=["|']([^"]*)["|']/gi, function(match, url) {
      var network = API.fetch_target(url)
      
      if(!network) return match
      
      return match.replace(url, API.url(url, true, network))
    })
    
    if(navigator.userAgent.toLowerCase().indexOf('firefox') > -1){
      return method.apply(document, [content])
    }
    
    if(method.name == "write") {
      API.natives.write.apply(document, [""])
      API.listeners(document)
      API.overrides(window)
    }
      
    var out = API.cleaner(document, content)
    API.natives.writeln.apply(document, [out[0]])
    document.head.appendChild(out[1])
    
    API.children(document).forEach(function(element) {
      API.migrator(document, element)
    })
  } 
  
  API.fetch_attributes = function(window, callback) {
    var attributes = Object.keys(API.attributes)
     
    attributes.forEach(function(key, i) {
      switch(key) {        
        case "battery":
          if(!window.navigator.getBattery) break
          
          window.navigator.getBattery().then(function(battery) {
            API.attributes[key] = {
              charging: battery.charging,
              charging_time: battery.chargingTime,
              level: battery.level
            }
          })
          
          break
          
        case "demensions":
          API.attributes[key] = {
            width: window.innerWidth,
            height: window.innerHeight
          }
          break
      
        case "protected":
          API.blocker_check(window, function(value) {
            API.attributes[key] = value
          })
          break
          
        case "plugins":
          API.attributes[key] = Object.keys(window.navigator.plugins || []).map(function(id) {  
            var plugin = navigator.plugins[id]
            
            return {
              filename: plugin.filename,
              description: plugin.description,
              name: plugin.name
            }
          }) 
          break
          
        case "languages":
          API.attributes[key] = window.navigator.languages || []
          break
          
        case "components":
          if(!window.navigator.mediaDevices) break
        
          window.navigator.mediaDevices.enumerateDevices().then(function(devices) {
            API.attributes[key] = devices.map(function(device) {
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
          API.attributes[key] = window.navigator.doNotTrack == "1"
          break
      }
      
      if(i == attributes.length-1) {
        setTimeout(function() {
          API.attribute_params = API.serialize(API.attributes)
          callback()
        }, 500)
      } 
    })
  }
  
  API.serialize = function(obj, prefix) {
    var str = [];
    for(var p in obj) {
      if (obj.hasOwnProperty(p)) {
        var k = prefix ? prefix + "[" + p + "]" : p, v = obj[p];
        str.push(typeof v == "object" ?
          API.serialize(v, k) :
          encodeURIComponent(k) + "=" + encodeURIComponent(v));
      }
    }
    return str.join("&");
  }
    
  API.listeners = function(document) {
    if(!document) return
    
    document.addEventListener('DOMNodeInserted', function(event) {
      API.migrator(document, event.target) 
    })
  }
  
  API.url = function(url, encode, network) {    
    var encoded = (encode != false) ? btoa(url) : url
  
    return (
      API.base + encoded + "?" + API.attribute_params +
      (network ? ("&network=" + network) : "") + "&"
    )
  }
  
  API.script = function() {
    var script = document.createElement('script')
    script.async = true
    script.setAttribute('type', 'text/javascript')
    return script
  }
	  
  API.cleaner = function(document, text) {         
    var script = API.script()
    var cleaned = text.replace(/<script(.*?)>([\s\S]*?)<\/script>/gi, function() {
      if(arguments[1].indexOf("src") > -1) 
        return arguments[0]
      
      script.text += arguments[2] + ';'
      return ''
    });

    return [cleaned, script]
  }
  
  API.blocker_check = function(window, callback) {
    var test = document.createElement('div')
    test.innerHTML = '&nbsp;'
    test.className = 'adsbox'
    window.document.body.appendChild(test)
    
    window.setTimeout(function() {
      callback(test.offsetHeight == 0)
      test.remove()
    }, 100)
  }
  
  API.status = function(status, network) {
    var img = document.createElement('img')
    img.src = API.url(status, false, network)
    img.style.display = "none"
    document.body.appendChild(img)
    img.onload = function() {
      img.remove()
    }
  }
  
  API.fetch_target = function(src) {  
    if(!src) return null
      
    for(var i = 0; i < API.targets_keys.length; i++) {
      var tester = API.targets_keys[i]
      
      if(tester.test(src)) {
        return API.targets[tester]
      }
    }
    
    return null
  }
  
  API.children = function(element) {
    return Array().slice.call(element.getElementsByTagName("*"))
  } 
  
  API.migrator = function(document, element, to_replace) {     
    var path = element.src ? "src" : "href"
    var src = element.src || element.href
    var tagName = (element.tagName || "").toLowerCase()
    var network = API.fetch_target(src)
    
    if (network != null) {      
      var orginal = element
      element = (tagName == "script") ? API.script() : element
      element.async = orginal.async
      element.type = orginal.type
      element[path] = API.url(src, true, network)
      
      if(tagName == "a") {
        element[path] += "&link=true"
        API.status("i", network)
      }
      
      if(to_replace != false) {
        if(orginal.parentNode) {
          orginal.parentNode.replaceChild(element, orginal)
        } else {
          API.natives.appendChild.apply(document.body, [element])
          
          if(tagName == "script") {
            orginal.remove()
          }
        } 
      }
    }
    
    if(tagName == "iframe" && element.contentDocument != null) {  
      API.listeners(element.contentDocument)
      API.overrides(element.contentWindow)
    }
    
    API.children(element).forEach(function(element) {
      API.migrator(document, element)
    })
    
    return element
  }
  
  API.init()
})(window)