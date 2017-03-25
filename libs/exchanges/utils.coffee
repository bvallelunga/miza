# Imports
useragent = new require 'express-useragent'
geoip = require 'geoip-lite'

module.exports.profile = (req)->
  agent = useragent.parse(req.headers['user-agent'])  
  
  return {
    devices: LIBS.exchanges.utils.device(agent)
    os: LIBS.exchanges.utils.os(agent)
    browsers: LIBS.exchanges.utils.browser(agent)
    countries: LIBS.exchanges.utils.country(req)
    agent: agent
  }
  
  
module.exports.device = (agent)->  
  if agent.isSmartTV
    return "tv"

  if agent.isDesktop
    return "desktop"
    
  if agent.isTablet
    return "tablet"
    
  if agent.isMobile
    return "mobile"
    
  if agent.isBot
    return "bot"

  return null
  
  
module.exports.os = (agent)->
  if agent.isWindowsPhone
    return "windows phone"

  if agent.isWindows
    return "windows"
    
  if agent.isiPhone or agent.isiPod or agent.isiPad 
    return "ios"
    
  if agent.isMac
    return "osx"
    
  if agent.isLinux
    return "linux"
    
  if agent.isAndroid
    return "android"
    
  if agent.isBlackberry
    return "blackberry"

  return null

  
module.exports.browser = (agent)->
  if agent.isOpera
    return "opera"
    
  if agent.isSafari
    return "safari"
    
  if agent.isFirefox
    return "firefox"
    
  if agent.isChrome
    return "chrome"
    
  if agent.isEdge
    return "edge"
    
  if agent.isIE
    return "ie"

  return null
  
  
module.exports.country = (req)->
  ip = req.headers["CF-Connecting-IP"] or req.ip or req.ips
  lookup = geoip.lookup(ip)
  
  if lookup? and lookup.country?
    return lookup.country.toLowerCase()
  
  return null
