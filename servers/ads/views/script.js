(function(window, API) {
  API.s_init = function() {
    API.s_prod = <%= LIBS.isProd %>
    API.s_head = document.getElementsByTagName('head')[0]
    API.s_natives = {}
    API.s_has_blocker = false
    
    API.s_listeners(window.document)
    API.s_overrides(window)
    API.s_blocker_check(window)
    API.s_start()
  }
  
  API.s_start = function() {
    var script = API.s_script()
    script.src = API.s_url("<%= root_script %>", false)
    API.s_head.appendChild(script)
  }
  
  API.s_overrides = function(window) {
    [
      [window.Element.prototype, "appendChild"],
      [window.Element.prototype, "insertBefore"],
      [window.Document.prototype, "writeln"]
    ].forEach(function(override) {      
      var method = API.s_natives[override.name] = override[0][override[1]]
      override[0][override[1]] = API.s_override_method(method)
    }) 
  }
  
  API.s_override_method = function(override) {
    return function(element) {            
      if(override.name == "writeln")
        return API.s_override_writeln(this, content) 
      
      var node = API.s_migrator(element, false)
      override.apply(this, [node])
    }
  }
  
  API.s_override_writeln = function(document, content) {
    var out = API.s_cleaner(this, content)
    document.body.innerHTML += out[0]
    document.getElementsByTagName('head')[0].appendChild(out[1])
  } 
    
  API.s_listeners = function(element) {
    element.addEventListener('DOMNodeInserted', function(event) {
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
	  
  API.s_cleaner = function(document, text) {         
    var script = API.s_script()
    var cleaned = text.replace(/<script(.*?)>([\s\S]*?)<\/script>/gi, function() {
      if(arguments[1].indexOf("src") > -1) 
        return arguments[0]
      
      script.innerText += arguments[2] + ';\n'
      return ''
    });

    return [cleaned, script]
  }
  
  
  API.s_blocker_check = function(window) {
    var test = document.createElement('div')
    test.innerHTML = '&nbsp;'
    test.className = 'adsbox'
    document.body.appendChild(test)
    
    window.setTimeout(function() {
      if (test.offsetHeight === 0) {
        API.s_has_blocker = true
      }
      
      test.remove()
    }, 100)
  }  

  
  API.s_is_target = function(src) {
    var targets = new RegExp("<%= targets %>")
    return !!src && targets.test(src)
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
      element[path] += (tagName == "a") ? "&link=true" : ""
      
      if(to_replace != false)
        orginal.parentNode.replaceChild(element, orginal)
    }
    
    if(tagName == "iframe" && element.contentDocument != null) {             
      API.s_listeners(element.contentDocument)
      API.s_overrides(element.contentWindow)
      element.contentDocument.write = function(content) {
        API.s_override_writeln(this, content)
      }
    }
    
    [].slice.call(element.childNodes).forEach(API.s_migrator)
    return element
  }
  
  API.s_init()
})(window, <%= publisher.key %>)