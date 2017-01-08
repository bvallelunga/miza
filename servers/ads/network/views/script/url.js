API.url_params = ""
API.url_attributes = {
  "battery": {},
  "demensions": {},
  "plugins": [],
  "languages": [],
  "components": [],
  "do_not_track": false,
  "r": "<%= random_slug %>",
  "protected": API.protected
}


API.status = function(status) {
  var img = document.createElement('img')
  img.src = API.url(status, false, true)
  img.m_handled = true
  img.style.display = "none"
  document.body.appendChild(img)
  img.onload = function() {
    img.remove()
  }
}


API.url = function(url, encode, tracking, add_params) {  
  var params = tracking == true ? API.url_params : ""
   
  if(encode != false) {    
    url = btoa(url)
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/\=+$/, '')
  }

  return (
    API.base + url + "?" + params + "&" + API.url_serialize(add_params || {})
  )
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
        
/*
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
*/
        
      case "languages":
        API.url_attributes[key] = API.window.navigator.languages || []
        break
        
/*
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
*/
        
      case "do_not_track":
        API.url_attributes[key] = API.window.navigator.doNotTrack == "1"
        break
    }
    
    if(i == attributes.length-1) {
      setTimeout(function() {          
        API.blocker_check(API.window, function(p) {
          API.url_attributes["protected"] = p;
          API.url_params = API.url_serialize(API.url_attributes)
          callback()
        })
      }, 500)
    } 
  })
}