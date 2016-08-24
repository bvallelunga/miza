API.script = function() {
  var script = document.createElement('script')
  script.async = true
  script.setAttribute('type', 'text/javascript')
  return script
}


API.blocker_check = function(window, callback) {
  var test = document.createElement('div')
  test.innerHTML = '&nbsp;'
  test.className = 'adsbox'
  window.document.body.appendChild(test)
  
  window.setTimeout(function() {
    callback(API.protected = test.offsetHeight == 0)
    test.remove()
  }, 100)
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

API.tag_name = function(element) {
  return (element.tagName || "").toLowerCase()
}


API.to_array = function(array_like) {
  return Array().slice.call(array_like || [])
} 

API.is_url = function isURL(url) {  
  return url.indexOf("//") > -1
}