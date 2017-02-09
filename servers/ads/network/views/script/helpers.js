API.iframes = []

API.iframe = function(element) {
  var parent = element.parentNode || {}
  var width = element.offsetWidth || parent.offsetWidth
  var height = element.offsetHeight || parent.offsetHeight
  
  if(width == 0 || height == 0) {
    var classNames = API.to_array(parent.classList)
    
    classNames.forEach(function(className) {     
      var dems = new RegExp("([0-9]+)x([0-9]+)", "i").exec(className) || []
      
      if(dems.length == 3) {
        width = dems[1]
        height = dems[2]
      }
    })
  }
  
  var iframe = document.createElement('iframe')
  var random = "f" + Math.random().toString(36).substring(7)
  
  iframe.style.outline = "none";
  iframe.style.border = "none";
  iframe.style.display = "none";
  iframe.style.borderRadius = "4px";
  iframe.style.border = "solid 1px #E2E2E2";
  iframe.style.overflow = "hidden";
  iframe.className = random
  iframe.src = API.url("a", false, false, {
    width: width,
    height: height,
    frame: random,
    referrer: "<%= referrer %>" || window.location.href
  })
  
  API.iframes.push(iframe)
  return iframe
}

API.blocker_check = function(window, callback) {
  var test = document.createElement('div')
  test.innerHTML = '&nbsp;'
  test.className = 'adsbox googleads carbonads adsbygoogle'
  window.document.body.appendChild(test)
  
  window.setTimeout(function() {
    var ghostry = API.document.querySelector("#ghostery-box")
    API.protected = test.offsetHeight == 0 || !!ghostry
    test.remove()
    if(callback) callback(API.protected)
  }, 300)
}


API.tag_name = function(element) {
  return (element.tagName || "").toLowerCase()
}


API.to_array = function(array_like) {
  return Array().slice.call(array_like || [])
}

API.script_match = function(element) {
  for(var i = 0; i < API.observables.scripts.length; i++) {
    var script = API.observables.scripts[i]
    
    if(element.innerHTML.indexOf(script) > -1) {
      return true
    }
  }
  
  return false
}  


API.element_matches = function(element) {  
  if(typeof element.matches == 'function') {
    if(element.matches(API.observables.query)) {
      return true
    }
  }

  if(typeof element.matchesSelector == 'function') {
    if(element.matchesSelector(API.observables.query)) {
      return true
    }
  }
  
  if((element.tagName || "").toLowerCase() == "script" && !element.src) {    
    if(API.script_match(element)) {
      return true
    }
  }

  var matches = (element.document || element.ownerDocument).querySelectorAll(API.observables.query)
  var i = 0

  while (matches[i] && matches[i] !== element) {
    i++
  }

  return matches[i] ? true : false
}