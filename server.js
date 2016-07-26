// Imports
var express = require('express')
var bodyParser = require('body-parser')
var morgan = require("morgan")
var routers = require("./express/routers")
var app = express()

// Express Setup
app.use(morgan(':method :url :response-time'))
app.enable('trust proxy')
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({
  extended: true
}))

// Subdomain Router
var secret_sledge = "/" + Math.random().toString(36).slice(2)

app.use(function(req, res, next) {
  var subdomains = req.host.split(".")
  
  if(subdomains.length >= 2 && subdomains[0] != "www")
    req.url = secret_sledge + "/" + req.path.slice(1)
    
  next()
})

app.use(secret_sledge, routers.sledge)
app.use(routers.website)

// Listen 
app.listen(3030)
