API.observables = {
  query: [
    ".adsbygoogle", ".dp-ad-chrome iframe", "#_carbonads_js",
    'div[id*="div-gpt-ad-"]', '.ad-tag[data-ad-size*="300x250"]',
    '.proper-ad-unit', 'div[id*="crt-"]', ".adswidget", ".adblock_awareness",
    ".rec_container .rec_article"
  ].join(","),
  xpaths: [
    "//body//script[contains(., 'OA_show')]/parent::*",
    "//body//script[contains(., 'Criteo.DisplayAd')]"
  ].join(" | "),
  scripts: [
    "OA_show", "Criteo.DisplayAd"
  ]
}

API.observe_init = function() {
  API.fetch_current()
  API.start_observing()
  
  window.onfocus = function() {
    API.refresh_iframes()
  }
}

API.fetch_xpath = function() {
  if(!API.observables.xpaths)  return []
  
  var elements = []
  var nodes = document.evaluate(API.observables.xpaths, document.body, null, XPathResult.ANY_TYPE, null)
  var result = nodes.iterateNext()
  
  while (result) {
    elements.push(result)
    result = nodes.iterateNext()
  } 
  
  return elements;
}

API.fetch_scripts = function() {
  var scripts = API.to_array(API.document.querySelectorAll("body script"))
  return scripts.filter(API.script_match)
}


API.fetch_current = function() {
  var query_elements = API.to_array(API.document.querySelectorAll(API.observables.query))
  var xpath_elements = API.fetch_xpath()
  var script_elements = API.fetch_scripts()
  var elements = query_elements.concat(xpath_elements, script_elements);
  
  elements.filter(function(element) {
    if(element.attributes["m"]) {
      return false
    }
    element.setAttribute("m", true)
    return !element.attributes["m-ignore"]
  }).forEach(API.migrate)
}


API.start_observing = function() {
  var observer = API.observer()
  
  observer.observe(API.document.body, { 
    attributes: true,
    childList: true,
    subtree: true
  })
  
  setInterval(function() {
    API.fetch_current()
  }, 1000)
  
  window.addEventListener("message", function(event) {
    var element = API.document.querySelector("." + event.data.frame)
    
    if(event.data.name == "frame.remove") {
      var publisher_callback = API.window["<%= publisher.key %>_callback"]
      var parentNode = element.parentNode.parentNode
      parentNode.removeChild(element.parentNode)
      
      if(!!publisher_callback) {
        publisher_callback(parentNode)
      }
    }
    
    if(event.data.name == "frame.show") {
      var parent = element.parentNode
      parent.parentNode.style.display = "block !important"
      parent.style.position = "relative"
      parent.style.minHeight = event.data.height + "px"
      parent.style.minWidth = event.data.width + "px"
      parent.style.width = "100%"
      parent.style.height = "100%"
      element.style.position = "absolute"
      element.style.top = "50%"
      element.style.left = "50%"
      element.style.marginTop = "-" + event.data.height/2 + "px"
      element.style.marginLeft = "-" + event.data.width/2 + "px"
      element.width = event.data.width
      element.height = event.data.height
      element.style.display = "block"
      
      if(parent.offsetHeight > parent.offsetWidth && parent.style.height == "100%") {
        parent.style.height = event.data.height + "px"
      }
    }
    
    if(event.data.name == "frame.reload") {
      API.iframes_refresh.push(element)
      
      if(window.document.hasFocus()) {
        API.refresh_iframes()
      }
    }
    
    if(event.data.name == "frame.impression") {
      API.impression_check(element)
    }
  }, false);
}


API.observer = function() {
  return new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {      
      API.to_array(mutation.addedNodes).forEach(function(element) {        
        if(API.element_matches(element)) {
          API.migrate(element)
        }        
      })
    })
  })
}


API.migrate = function(element) {
  var iframe_length = API.iframes.length
  var width = API.width_parser(element)
  
  // TODO: Move WIDTH cap logic to server side
  if(width > 500 || !API.hash_value("m-creative") && iframe_length > 0 && <%- publisher.config.ad_coverage %> < Math.random()) {
    return element.parentNode.removeChild(element)
  }
  
  var iframe = API.iframe(element);
  var div = API.document.createElement("div")
  div.appendChild(iframe)
  
  setTimeout(function() {
    element.parentNode.replaceChild(div, element)
  }, iframe_length * 1000)
}