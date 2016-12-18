API.iframe = function(element) {
  var iframe = document.createElement('iframe')
  iframe.style.outline = "none";
  iframe.style.border = "solid 1px #ccc";
  iframe.width = "100%";
  iframe.height = "100%";
  iframe.src = API.url("a", false, true, {
    w: element.parentNode.offsetWidth,
    h: element.parentNode.offsetHeight
  })
  return iframe
}


API.blocker_check = function(window, callback) {
  var test = document.createElement('div')
  test.innerHTML = '&nbsp;'
  test.className = 'adsbox googleads carbonads'
  window.document.body.appendChild(test)
  
  window.setTimeout(function() {
    var ghostry = API.document.querySelector("#ghostery-box")
    API.protected = test.offsetHeight == 0 || !!ghostry
    if(callback) callback(API.protected)
    test.remove()
  }, 300)
}


API.tag_name = function(element) {
  return (element.tagName || "").toLowerCase()
}


API.to_array = function(array_like) {
  return Array().slice.call(array_like || [])
} 


API.element_matches = function(element,selector) {  
  if(typeof element.matches == 'function')
    return element.matches(selector)

  if(typeof element.matchesSelector == 'function')
    return element.matchesSelector(selector)

  var matches = (element.document || element.ownerDocument).querySelectorAll(selector)
  var i = 0

  while (matches[i] && matches[i] !== element) {
    i++
  }

  return matches[i] ? true : false
}