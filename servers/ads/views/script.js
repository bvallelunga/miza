(function(window, API) {
  API.s_init = function() {
    API.s_prod = <%= LIBS.isProd %>
    API.s_head = document.getElementsByTagName('head')[0]
    API.s_natives = {}
    API.s_has_blocker = false
    
    API.s_listeners(window.document)
    API.s_overrides(window)
    API.s_blocker_check(window, function() {
      API.s_start()
    })
  }
  
  API.s_start = function() {
    var script = API.s_script()
    script.src = API.s_url("<%= root_script %>", false)
    API.s_head.appendChild(script)
  }
  
  API.s_overrides = function(window, prototype) {
    [
      [window.Element.prototype, "appendChild"],
      [window.Element.prototype, "insertBefore"],
      [window.Document.prototype, "write"],
      [window.Document.prototype, "writeln"]
    ].forEach(function(override) {    
      var method = API.s_natives[override[1]]
      
      if(prototype != false) {
        method = API.s_natives[override[1]] = override[0][override[1]]
        override[0][override[1]] = API.s_override_method(method) 
      }
      
      window.document[override[1]] = API.s_override_method(method)
    }) 
  }
  
  API.s_override_method = function(override) {
    return function(element) {            
      if(typeof element == "string")
        return API.s_override_write(this, element, override) 
      
      var node = API.s_migrator(element, false)
      override.apply(this, arguments)
    }
  }
  
  API.s_override_write = function(document, content, method) {
    var out = API.s_cleaner(content)

    if(method.name == "write") {
      method.apply(document, [""])
      API.s_listeners(document)
      API.s_overrides(document.parentWindow || document.defaultView, false)
    }     
    
    API.s_natives.writeln.apply(document, [out[0]])
    document.getElementsByTagName('head')[0].appendChild(out[1])
    API.s_migrator(document)
  } 
    
  API.s_listeners = function(document) {
    document.addEventListener('DOMNodeInserted', function(event) {
      API.s_migrator(event.target)
    })
  }
  
  API.s_url = function(url, encode) {
    var encoded = (encode != false) ? btoa(url) : url
    var random = "&r=" + Math.random()
    return (
      API.s_base + encoded + "?blocker=" + API.s_has_blocker +
      (!API.s_prod ? random : "") 
    )
  }
  
  API.s_script = function() {
    var script = document.createElement('script')
    script.setAttribute('type', 'text/javascript')
    return script
  }
	  
  API.s_cleaner = function(text) {         
    var script = API.s_script()
    var cleaned = text.replace(/<script(.*?)>([\s\S]*?)<\/script>/gi, function() {
      if(arguments[1].indexOf("src") > -1) 
        return arguments[0]
      
      script.text += arguments[2] + ";"
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
      if (test.offsetHeight === 0) {
        API.s_has_blocker = true
      }
      
      test.remove()
      callback()
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
    var targets = new RegExp("<%= targets %>")
    return !!src && targets.test(src)
  }
  
  API.s_migrator = function(element, to_replace, from_parent) {    
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
    
    if(from_parent != true) {
      element.querySelectorAll("*").forEach(function(element) {
        API.s_migrator(element, true, true)
      })
    }
      
    return element
  }
  
  API.s_init()
})(window, <%= publisher.key %>)