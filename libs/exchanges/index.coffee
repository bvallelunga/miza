module.exports = {
  
  errors: require "./errors"
  utils: require "./utils"
  miza: require "./miza"
  indeed: require "./indeed"
  fetch: (req, res)->
    return LIBS.exchanges.miza(req, res).catch ->
      return LIBS.exchanges.indeed(req, res)

}