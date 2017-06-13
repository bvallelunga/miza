module.exports = ->
  routes = {
    landing:    require "./landing"
    auth:       require "./auth"
    supply:     require "./supply"
    admin:      require "./admin"
    account:    require "./account"
    demand:     require "./demand"
    api:        require "./api"
  }
  
  routes.router = (req, res, next)->
    req._routes = routes
    next()
    
  return routes