API.url_params = ""
API.url_attributes = {
  "battery": {},
  "demensions": {},
  "plugins": [],
  "languages": [],
  "components": [],
  "do_not_track": false,
  "r": "<%= random_slug %>"
}


API.status = function(status, network) {
  var img = document.createElement('img')
  img.src = API.url(status, false, network, true)
  img.m_handled = true
  img.style.display = "none"
  document.body.appendChild(img)
  img.onload = function() {
    img.remove()
  }
}


API.url = function(url, encode, network, tracking, url_type) {  
  var params = tracking == true ? API.url_params : ""
   
  if(encode != false) {
    url_type = url_type || API.url_type(url)
    
    if(url_type == "path") {
      url = API.url_append(url)
    }
    
    url = btoa(url)
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/\=+$/, '')
  }

  return (
    API.base + url + "?" + params +
    (network ? ("&network=" + network) : "") +
    (network ? ("&protected=" + API.protected) : "") + "&"
  )
}


API.url_append = function(path) {
  var site = atob(window.location.pathname.slice(1)).split("?")[0]
  
  if(path[0] == "/") {
    site = "//" + API.extract_domain(site)
  } else {
    var splits = site.split("/")
    var steps = splits.length - (path.match(/\.\.\//g) || []).length
    
    site = site.split("/").slice(0, steps).join("/")
  }
  
  return site + "/" + path.replace(/(\.)?\.\//g, "")
}


API.extract_domain = function(url) {
  var domain = url

  if (url.indexOf("//") > -1) {
    domain = url.split('//')[1]
  }
  
  return domain.split('/')[0].split("?")[0]
} 


API.url_type = function(url) {  
  if(!url || url.length == 0 || 
    API.extract_domain(url) == API.raw_base) return null
  
  if(url.indexOf("//") > -1) {
    return "external"
  } else if(url.indexOf(":") == -1) {
    return "path"
  }
  
  return null
}


API.url_serialize = function(obj, prefix) {
  var str = [];
  for(var p in obj) {
    if (obj.hasOwnProperty(p)) {
      var k = prefix ? prefix + "[" + p + "]" : p, v = obj[p];
      str.push(typeof v == "object" ?
        API.url_serialize(v, k) :
        encodeURIComponent(k) + "=" + encodeURIComponent(v));
    }
  }
  return str.join("&");
}


API.fetch_attributes = function(callback) {
  var attributes = Object.keys(API.url_attributes)
  
  API.blocker_check(API.window)
   
  attributes.forEach(function(key, i) {
    switch(key) {        
      case "battery":
        if(!API.window.navigator.getBattery) break
        
        API.window.navigator.getBattery().then(function(battery) {
          API.url_attributes[key] = {
            charging: battery.charging,
            charging_time: battery.chargingTime,
            level: battery.level
          }
        })
        
        break
        
      case "demensions":
        API.url_attributes[key] = {
          width: API.window.innerWidth,
          height: API.window.innerHeight
        }
        break
        
      case "plugins":
        API.url_attributes[key] = Object.keys(API.window.navigator.plugins || []).map(function(id) {  
          var plugin = navigator.plugins[id]
          
          return {
            filename: plugin.filename,
            description: plugin.description,
            name: plugin.name
          }
        }) 
        break
        
      case "languages":
        API.url_attributes[key] = API.window.navigator.languages || []
        break
        
      case "components":
        if(!API.window.navigator.mediaDevices) break
      
        API.window.navigator.mediaDevices.enumerateDevices().then(function(devices) {
          API.url_attributes[key] = devices.map(function(device) {
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
        API.url_attributes[key] = API.window.navigator.doNotTrack == "1"
        break
    }
    
    if(i == attributes.length-1) {
      setTimeout(function() {
        API.url_params = API.url_serialize(API.url_attributes)
        callback()
      }, 500)
    } 
  })
}