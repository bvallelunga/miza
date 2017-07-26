module.exports = {
  
  errors: require "./errors"
  utils: require "./utils"
  miza: require "./miza"
  indeed: require "./indeed"
  video: require "./video"
  examples: require "./examples"
      
}

module.exports.fetch = (req, res)->
  waterfall = [
    LIBS.exchanges.override
    LIBS.exchanges.mobile
    LIBS.exchanges.miza
    LIBS.exchanges.indeed
    LIBS.exchanges.video
  ]
  
  new Promise (res, rej)->
    response = null
  
    Promise.mapSeries waterfall, (func)->
      if response? then return null
    
      func(req, res).then (result)->
        response = result
        
      .catch (error)->        
        if LIBS.exchanges.errors.is_valid(error)
          console.log error
          LIBS.bugsnag.notify error
        
    .then ->    
      if response?
        return res response
            
      return rej LIBS.exchanges.errors.AD_NOT_FOUND


module.exports.mobile = (req, res)->  
  if not req.mobile_frame
    return Promise.reject LIBS.exchanges.errors.AD_NOT_FOUND
  
  return LIBS.exchanges.video(req, res)


module.exports.override = (req, res)->
  creative_override = req.query.creative_override or ""

  if creative_override == "indeed"
    return LIBS.exchanges.indeed(req, res)
    
  if creative_override == "video"
    return LIBS.exchanges.video(req, res)
  
  if creative_override.indexOf("example_") > -1
    return LIBS.exchanges.examples(req, res)
    
  return Promise.reject LIBS.exchanges.errors.AD_NOT_FOUND
