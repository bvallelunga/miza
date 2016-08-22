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
    callback(test.offsetHeight == 0)
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


API.children = function(element) {
  return Array().slice.call(element.getElementsByTagName("*"))
} 