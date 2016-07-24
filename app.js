// Imports
var express = require('express')
var bodyParser = require('body-parser')
var morgan = require("morgan")
var sledge = require("./express/routes/sledge")
var app = express()

// Express Setup
app.use(morgan(':method :url :response-time'))
app.set('views', './express/views')
app.set('view engine', 'ejs')
app.enable('trust proxy')
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({
  extended: true
}))

// Public
app.use(express.static(__dirname + '/public'))

// Sledge
app.get("/", sledge.identifier, sledge.script)
app.get("*", sledge.identifier, sledge.downloader, sledge.modifier)

// Listen 
app.listen(3030)
