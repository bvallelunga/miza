module.exports = ->
  routes = {
    core: require "./core"
    network: require "./network"
    proxy: require "./proxy"
  }
  
  routes.router = (req, res, next)->
    req._routes = routes
    next()
    
  return routes