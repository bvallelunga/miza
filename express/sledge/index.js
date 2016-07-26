// Imports
var express = require('express')
var routes = require("./routes")
var app = express()

// Express Setup
app.use(require("compression")())
app.set('views', __dirname + '/views')
app.set('view engine', 'ejs')

// Routes
app.get("/", routes.identifier, routes.script)
app.get("*", routes.identifier, routes.downloader, routes.modifier)

// Export
module.exports = app
