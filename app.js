// Imports
var express = require('express')
var bodyParser = require('body-parser')
var app = express()

// Express Setup
app.set('views', './express/views')
app.set('view engine', 'ejs')
app.enable('trust proxy')
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({
  extended: true
}))

// Public
app.use(express.static(__dirname + '/public'))


// Listen 
app.listen(3030)
