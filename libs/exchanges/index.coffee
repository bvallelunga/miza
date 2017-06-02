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
    LIBS.exchanges.miza
#     LIBS.exchanges.indeed
#     LIBS.exchanges.video
  ]
  
  new Promise (res, rej)->
    response = null
    reject = null
  
    Promise.mapSeries waterfall, (func)->
      if response? then return null
    
      func(req, res).then (result)->
        response = result
        
      .catch (error)->
        reject = error
        
    .then ->
      if response?
        return res response
        
      return rej reject or LIBS.exchanges.errors.NO_AD_FOUND


module.exports.override = (req, res)->
  creative_override = req.query.creative_override or ""

  if creative_override == "indeed"
    return LIBS.exchanges.indeed(req, res)
    
  if creative_override == "video"
    return LIBS.exchanges.video(req, res)
  
  if creative_override.indexOf("example_") > -1
    return LIBS.exchanges.examples(req, res)
    
  return Promise.reject LIBS.exchanges.errors.NO_AD_FOUND
