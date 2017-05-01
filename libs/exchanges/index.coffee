module.exports = {
  
  errors: require "./errors"
  utils: require "./utils"
  miza: require "./miza"
  indeed: require "./indeed"
  fetch: (req, res)->
    return LIBS.exchanges.miza(req, res)
    
# TODO: Renable Indeed when we have a formal CPC 
#       rate from them
#
#     return LIBS.exchanges.miza(req, res).catch ->
#       return LIBS.exchanges.indeed(req, res)

}