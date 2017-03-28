path = require "./path"
downloader = require "./downloader"

module.exports = (req, res, next)->
  path(req.get('host'), req.path).then (path)->
    return downloader path, req.query, {
      referer: req.query.page_url
      "user-agent": req.get("user-agent")
      "X-Forwarded-For": req.headers["CF-Connecting-IP"] or req.ip or req.ips
      "Miza-Network": "https://miza.io"
    }
    
  .then (data)-> 
    if data.media == "link"
      res.redirect data.href
      
    else if not req.query["no-dl"]?
      res.set "Content-Type", data.content_type

      if data.media == "binary"
        res.end data.content, "binary"
      
      else
        res.send data.content
        
    else
      res.end req._routes.core.utils.pixel_tracker
      
    return data
      
  .then (data)->
    if data.to_cache
      LIBS.redis.set data.key, JSON.stringify data

    LIBS.ads.track req, {
      type: if data.media == "link" then "click" else "asset"
      asset_url: data.href
      publisher: req.publisher
    }
      
  
  .catch next
