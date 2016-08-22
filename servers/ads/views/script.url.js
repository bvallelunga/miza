API.url_params = ""
API.url_attributes = {
  "battery": {},
  "demensions": {},
  "plugins": [],
  "languages": [],
  "components": [],
  "do_not_track": false,
  "protected": false,
  "r": "<%= random_slug %>"
}


API.status = function(status, network) {
  var img = document.createElement('img')
  img.src = API.url(status, false, network)
  img.style.display = "none"
  document.body.appendChild(img)
  img.onload = function() {
    img.remove()
  }
}


API.url = function(url, encode, network) {    
  var encoded = (encode != false) ? btoa(url) : url

  return (
    API.base + encoded + "?" + API.attribute_params +
    (network ? ("&network=" + network) : "") + "&"
  )
}


API.serialize = function(obj, prefix) {
  var str = [];
  for(var p in obj) {
    if (obj.hasOwnProperty(p)) {
      var k = prefix ? prefix + "[" + p + "]" : p, v = obj[p];
      str.push(typeof v == "object" ?
        API.serialize(v, k) :
        encodeURIComponent(k) + "=" + encodeURIComponent(v));
    }
  }
  return str.join("&");
}


API.fetch_attributes = function(window, callback) {
  var attributes = Object.keys(API.attributes)
   
  attributes.forEach(function(key, i) {
    switch(key) {        
      case "battery":
        if(!window.navigator.getBattery) break
        
        window.navigator.getBattery().then(function(battery) {
          API.url_attributes[key] = {
            charging: battery.charging,
            charging_time: battery.chargingTime,
            level: battery.level
          }
        })
        
        break
        
      case "demensions":
        API.url_attributes[key] = {
          width: window.innerWidth,
          height: window.innerHeight
        }
        break
    
      case "protected":
        API.blocker_check(window, function(value) {
          API.url_attributes[key] = value
        })
        break
        
      case "plugins":
        API.url_attributes[key] = Object.keys(window.navigator.plugins || []).map(function(id) {  
          var plugin = navigator.plugins[id]
          
          return {
            filename: plugin.filename,
            description: plugin.description,
            name: plugin.name
          }
        }) 
        break
        
      case "languages":
        API.url_attributes[key] = window.navigator.languages || []
        break
        
      case "components":
        if(!window.navigator.mediaDevices) break
      
        window.navigator.mediaDevices.enumerateDevices().then(function(devices) {
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
        API.url_attributes[key] = window.navigator.doNotTrack == "1"
        break
    }
    
    if(i == attributes.length-1) {
      setTimeout(function() {
        API.url_params = API.serialize(API.url_attributes)
        callback()
      }, 500)
    } 
  })
}