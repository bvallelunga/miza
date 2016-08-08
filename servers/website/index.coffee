express = require 'express'
session = require 'express-session'
routes = require "./routes"
app = express()


module.exports = (srv)->
  # Express Setup
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'
  app.use require("compression")()
  app.use require("cookie-parser")()
  app.use require("csurf")({ cookie: true })
  app.use require('express-session')(CONFIG.cookies.session session, LIBS.redis)
  app.use routes.auth.load_user
  app.use require "./locals"
  
  
  # Public
  require("../assets")(app, srv,  __dirname + '/public')
  app.use "/test", express.static __dirname + '/public/test'
  app.use "/imgs", express.static __dirname + '/public/images'
  
  
  # Routes
  app.get  "/", routes.landing.get_root
  app.post "/access/request", routes.landing.post_beta
  
  app.get  "/login", routes.auth.not_authenticated, routes.auth.get_login
  app.get  "/register", routes.auth.not_authenticated, routes.auth.get_register
  app.get  "/user/access", routes.auth.is_admin, routes.auth.get_user_access
  app.get  "/logout", routes.auth.get_logout
  app.post "/login", routes.auth.not_authenticated, routes.auth.post_login
  app.post "/register", routes.auth.not_authenticated, routes.auth.post_register
  app.post "/user/access", routes.auth.is_admin, routes.auth.post_user_access
  
  app.get  "/dashboard", routes.auth.is_authenticated, routes.dashboard.get_root
  app.get  "/dashboard/new", routes.auth.is_authenticated, routes.dashboard.get_new
  app.get  "/dashboard/:publisher", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.get_dashboard
  app.get  "/dashboard/:publisher/:dashboard", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.get_dashboard
  app.get  "/dashboard/:publisher/billing/logs", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.get_billing_logs
  app.get  "/dashboard/:publisher/billing/metrics", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.get_billing_metrics
  app.get  "/dashboard/:publisher/analytics/logs", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.get_analytics_logs
  app.get  "/dashboard/:publisher/analytics/metrics", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.get_analytics_metrics
  app.post "/dashboard/new", routes.auth.is_authenticated, routes.dashboard.post_new
  app.post  "/dashboard/:publisher/settings", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.post_settings
  
  
  if not CONFIG.isProd
    app.get "/demo", routes.demo.publisher, routes.demo.get_root
    app.get "/demo/:demo", routes.demo.publisher, routes.demo.get_root
  
  
  # Error Handlers
  app.get  "*", routes.landing.get_not_found
  app.use  require("./error")
  
  
  # Export
  return app
