module.exports = {
  
  errors: require "./errors"
  utils: require "./utils"
  miza: require "./miza"
  indeed: require "./indeed"
  fetch: (req)->
    return LIBS.exchanges.miza(req)# .catch ->
#       return LIBS.exchanges.indeed(req)

}