// Imports
var express = require('express')
var app = express()

// Express Setup
app.use(require("compression")())
app.set('views', __dirname + '/views')
app.set('view engine', 'ejs')

// Public
app.use(express.static(__dirname + '/public'))

// Routes
/*
app.get("/", sledge.identifier, sledge.script)
app.get("*", sledge.identifier, sledge.downloader, sledge.modifier)
*/

// Export
module.exports = app
