module.exports = {
  
  website: require("./website")
  
  sledge: {
    app: require("./sledge"),
    prefix: "/" + Math.random().toString(33).slice(2)
  }
  
  engine: (req, res, next)->
    subdomains = req.host.split(".")
  
    if subdomains.length >= 2 and subdomains[0] != "www"
      req.url =  "#{module.exports.sledge.prefix}/#{req.path.slice(1)}"
      
    next()
  
}