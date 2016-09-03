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
  
  
  # Public Routes
  require("../assets")(app, srv,  __dirname + '/public')
  app.use "/test", express.static __dirname + '/public/test'
  app.use "/imgs", express.static __dirname + '/public/images'  
  
  # Landing Routes
  app.get  "/", routes.auth.not_authenticated, routes.landing.get_root
  app.get  "/optout", routes.landing.get_optout
  app.get  "/legal/:document", routes.landing.get_legal
  app.get  "/#{CONFIG.loader_io}", routes.landing.get_loader_io
  app.post "/optout", routes.landing.post_optout
  app.post "/access/request", routes.auth.not_authenticated, routes.landing.post_beta
  
  
  # Auth Routes
  app.get  "/login", routes.auth.not_authenticated, routes.auth.get_login
  app.get  "/register", routes.auth.not_authenticated, routes.auth.get_register
  app.get  "/logout", routes.auth.get_logout
  app.post "/login", routes.auth.not_authenticated, routes.auth.post_login
  app.post "/register", routes.auth.not_authenticated, routes.auth.post_register
  

  # Account Routes
  app.get  "/account", routes.auth.is_authenticated, routes.account.get_root
  app.get  "/account/password", routes.auth.is_authenticated, routes.account.get_password
  app.get  "/account/card", routes.auth.is_authenticated, routes.account.get_card
  app.post "/account", routes.auth.is_authenticated, routes.account.post_root
  app.post "/account/password", routes.auth.is_authenticated, routes.account.post_password
  app.post "/account/card", routes.auth.is_authenticated, routes.account.post_card
  
  
  # Admin Routes
  app.get  "/admin", routes.auth.is_admin, routes.admin.get_root
  app.get  "/admin/access", routes.auth.is_admin, routes.admin.access.get
  app.get  "/admin/reports", routes.auth.is_admin, routes.admin.reports.get
  app.get  "/admin/reports/metrics", routes.auth.is_admin, routes.admin.reports.metrics
  app.get  "/admin/industries", routes.auth.is_admin, routes.admin.industries.get
  app.get  "/admin/publishers", routes.auth.is_admin, routes.admin.publishers.get
  app.post "/admin/access", routes.auth.is_admin, routes.admin.access.post
  app.post "/admin/industries", routes.auth.is_admin, routes.admin.industries.post
  
  
  # Dashboard Routes
  app.get  "/dashboard", routes.auth.is_authenticated, routes.dashboard.get_root
  app.get  "/dashboard/new", routes.auth.is_authenticated, routes.dashboard.create.get
  app.get  "/dashboard/:publisher", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.get_root
  app.get  "/dashboard/:publisher/:dashboard", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.get_dashboard
  app.get  "/dashboard/:publisher/billing/logs", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.billing.logs
  app.get  "/dashboard/:publisher/billing/metrics", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.billing.metrics
  app.get  "/dashboard/:publisher/analytics/logs", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.analytics.logs
  app.get  "/dashboard/:publisher/analytics/metrics", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.analytics.metrics
  app.post "/dashboard/new", routes.auth.is_authenticated, routes.dashboard.create.post
  app.post "/dashboard/:publisher/settings", routes.auth.is_authenticated, routes.auth.has_publisher, routes.dashboard.settings.post
  
  
  # Demo Routes
  app.get "/demo", routes.demo.set_user, routes.demo.get_root
  app.get "/demo/wordpress", routes.demo.get_wordpress
  app.get "/demo/miza", routes.demo.set_user, routes.demo.get_miza
  app.get "/demo/miza/:demo", routes.demo.set_user, routes.demo.get_miza
  
  
  # Error Handlers
  app.get  "*", routes.landing.get_not_found
  app.use  require("./error")
  
  
  # Export
  return app
