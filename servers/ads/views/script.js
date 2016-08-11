(function(window, API) {
  API.s_init = function() {
    API.s_id = "<%= publisher.key %>" 
    API.s_prod = <%= CONFIG.isProd %>
    API.s_window = window
    API.s_head = document.getElementsByTagName('head')[0]
    API.s_targets = new RegExp("<%= targets %>")
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

    API.s_listeners(window.document)
    API.s_overrides(window)
    API.s_fetch_attributes(window, API.s_start)
  }
  
  API.s_start = function() {
    var script = API.s_script()
    script.src = API.s_url("<%= root_script %>", false)
    API.s_head.appendChild(script)
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
          arguments[i] = API.s_migrator(node, false)
        }
      }
    
      return method.apply(this, arguments)
    }
  }
  
  API.s_override_writeln = function(window, document, content, method) {  
    if(navigator.userAgent.toLowerCase().indexOf('firefox') > -1){
      return method.apply(document, [content])
    }
      
    var out = API.s_cleaner(document, content)
    document.body.innerHTML += out[0]
    document.getElementsByTagName('head')[0].appendChild(out[1])
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
        API.s_attribute_params = API.s_serialize(API.s_attributes)
        callback()
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
    
  API.s_listeners = function(element) {
    if(!element) return
    
    element.addEventListener('DOMNodeInserted', function(event) {
      API.s_migrator(event.target) 
    })
  }
  
  API.s_url = function(url, encode) {
    var encoded = (encode != false) ? btoa(url) : url
  
    return (
      API.s_base + encoded + "?" + API.s_attribute_params
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
  
  API.s_impression = function(element) {
    var img = document.createElement('img')
    img.src = API.s_url("i", false)
    img.style.display = "none"
    document.body.appendChild(img)
    img.onload = function() {
      img.remove()
    }
  }
  
  API.s_is_target = function(src) {
    return !!src && API.s_targets.test(src)
  }
  
  API.s_migrator = function(element, to_replace) {     
    var path = element.src ? "src" : "href"
    var src = element.src || element.href
    var tagName = (element.tagName || "").toLowerCase()
    
    if (API.s_is_target(src)) {      
      var orginal = element
      element = (tagName == "script") ? API.s_script() : element
      element.async = orginal.async
      element.type = orginal.type
      element[path] = API.s_url(src)
      
      if(tagName == "a") {
        element[path] += "&link=true"
        API.s_impression(orginal)
      }
      
      if(to_replace != false)
        orginal.parentNode.replaceChild(element, orginal)
    }
    
    if(tagName == "iframe" && element.contentDocument != null) {    
      API.s_listeners(element.contentDocument)
      API.s_overrides(element.contentWindow)
    }
        
    [].slice.call(element.childNodes).forEach(API.s_migrator)
    return element
  }
  
  API.s_init()
})(window, <%= publisher.key %>)