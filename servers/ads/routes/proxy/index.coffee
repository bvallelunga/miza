path = require "./path"
downloader = require "./downloader"

module.exports = (req, res, next)->
  path(req.get('host'), req.path, req).then (path)->
    return downloader path, req.query, {
      referer: req.query.page_url
      "user-agent": req.get("user-agent")
      "X-Forwarded-For": req.ip_address
      "Miza-Network": "https://miza.io"
    }
    
  .then (data)-> 
    if data.media != "link"
      return data
      
    if req.query.campaign?
      clicked_campaigns = req.signedCookies.clicked_campaigns or []
      campaign = Number(req.query.campaign)
      
      if clicked_campaigns.indexOf(campaign) == -1
        clicked_campaigns.push Number(campaign)
        
      res.cookie "clicked_campaigns", clicked_campaigns, { 
        httpOnly: true
        signed: true 
        maxAge: 10000 * 60 * 1000
      }
     
    if req.query.creative? 
      LIBS.models.Creative.findById(req.query.creative).then (creative)->    
        if creative.config.disable_incentive?        
          res.cookie "optout", true, { 
            httpOnly: true
            signed: true 
            maxAge: creative.config.disable_incentive * 60 * 1000
          }
          
        return data
      
      .catch ->
        return data  
    
    else
      return data 
    
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
    LIBS.ads.event.track req, {
      type: if data.media == "link" then "click" else "asset"
      asset_url: data.href
    }
      
  
  .catch (error)->
    res.send ""
