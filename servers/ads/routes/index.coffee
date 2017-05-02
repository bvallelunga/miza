module.exports = ->
  routes = {
    core: require "./core"
    network: require "./network"
    proxy: require "./proxy"
    exchanges: require "./exchanges"
  }
  
  routes.router = (req, res, next)->
    req._routes = routes
    next()
    
  return routes