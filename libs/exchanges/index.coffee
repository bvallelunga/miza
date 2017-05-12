module.exports = {
  
  errors: require "./errors"
  utils: require "./utils"
  miza: require "./miza"
  indeed: require "./indeed"
  examples: require "./examples"
  fetch: (req, res)->
    creative_override = req.query.creative_override or ""
  
    if creative_override == "indeed"
      return LIBS.exchanges.indeed(req, res)
    
    if creative_override.indexOf("example_") > -1
      return LIBS.exchanges.examples(req, res)
  
    return LIBS.exchanges.miza(req, res)
    
# TODO: Renable Indeed when we have a formal CPC 
#       rate from them
#
#     return LIBS.exchanges.miza(req, res).catch ->
#       return LIBS.exchanges.indeed(req, res)

}