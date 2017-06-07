geoip = require 'geoip-lite'
useragent = new require 'express-useragent'

module.exports.track = (req, data)->
  data.query = req.query
  data.publisher = req.publisher
  data.session = req.signedCookies.session
  data.headers = req.headers
  data.ip = req.ip
  data.ips = req.ips
  
  LIBS.queue.publish "visitor-queue", data


module.exports.build = (raw_data)->
  Promise.resolve().then ->
    data =  {
      device: raw_data.device
      publisher_id: raw_data.publisher.id
      data: {
        width: parseInt(raw_data.query.width) or undefined
        height: parseInt(raw_data.query.height) or undefined
      }
    }
    
    if data.device == "desktop"
      data.identifier = raw_data.session
      data.data = {
        ip: raw_data.headers["CF-Connecting-IP"] or raw_data.query.ip or raw_data.ip or raw_data.ips 
        user_agent: raw_data.headers["user-agent"]
        width: parseInt((raw_data.query.demensions or {}).width) or undefined
        height: parseInt((raw_data.query.demensions or {}).height) or undefined
      }
      data.desktop = {
        session: raw_data.session
        protected: raw_data.query.protected == "true"
      }   
      
      if data.data.user_agent?
        agent = useragent.parse(raw_data.headers['user-agent']) 
        data.desktop.os = LIBS.exchanges.utils.os(agent) 
        data.desktop.browser = LIBS.exchanges.utils.browser(agent) 
      
      if (lookup = geoip.lookup(data.data.ip))?       
        data.location = {
          lattitide: parseFloat(lookup.ll[0]) or undefined
          longitude: parseFloat(lookup.ll[1]) or undefined
          city: (lookup.city or "").toLowerCase() or undefined
          state: (lookup.region or "").toLowerCase() or undefined
          country_code: (lookup.country or "").toLowerCase() or undefined
        }
      
    if data.device == "mobile"
      data.identifier = raw_data.query.device_id
      data.data = {
        ip: raw_data.query.ip
        user_agent: raw_data.query.user_agent
        width: parseInt(raw_data.query.width) or undefined
        height: parseInt(raw_data.query.height) or undefined
      }
      data.mobile = {
        network_type: raw_data.query.network_type
        orientation: raw_data.query.orientation
        reftag: raw_data.query.reftag
        idfa: raw_data.query.idfa
        gpid: raw_data.query.gpid
        device_id: raw_data.query.device_id
        pub_id: raw_data.query.pub_id
        bundle_id: raw_data.query.bundle_id
        app_name: raw_data.query.app_name
      }
      data.user = {
        age: parseInt(raw_data.query.age) or undefined
        gender: raw_data.query.gender
      }
      data.location = {
        lattitide: parseFloat(raw_data.query.lattitide) or undefined
        longitude: parseFloat(raw_data.query.longitude) or undefined
        city: raw_data.query.city
        state: raw_data.query.state
        country_code: raw_data.query.country_code
      }
      
    return data


module.exports.send = (raw_data)->  
  LIBS.ads.visitor.build(raw_data).then (data)->    
    if not data.identifier?
      return Promise.resolve()
    
    LIBS.models.Visitor.upsert(data)
