module.exports = {
  
  errors: require "./errors"
  utils: require "./utils"
  miza: require "./miza"
  indeed: require "./indeed"
  video: require "./video"
  examples: require "./examples"
  fetch: (req, res)->
    creative_override = req.query.creative_override or ""
  
    if creative_override == "indeed"
      return LIBS.exchanges.indeed(req, res)
      
    if creative_override == "video"
      return LIBS.exchanges.video(req, res)
    
    if creative_override.indexOf("example_") > -1
      return LIBS.exchanges.examples(req, res)
  
    return LIBS.exchanges.miza(req, res).catch ->
      return LIBS.exchanges.indeed(req, res)

}