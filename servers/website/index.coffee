express = require 'express'
session = require 'express-session'
routes = require "./routes"
Agendash = require "agendash"
app = express()


module.exports = (srv)->
  # 3rd Party Ignore Routes  
  scheduler_regex = new RegExp "^((?!#{[
    "/admin/vendor"
  ].join("|")})[\\s\\S])*$"


  # Express Setup
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'
  app.use require("compression")()
  app.use require("cookie-parser")()
  app.use scheduler_regex, require("csurf")({ cookie: true })
  app.use require('express-session')(CONFIG.cookies.session session, LIBS.redis)
  app.use LIBS.bugsnag.requestHandler

  # Public Routes
  require("./assets")(app, srv,  __dirname + '/public')
  app.use "/imgs", express.static __dirname + '/public/images'
  
  
  # Load User & Locals
  app.use routes.auth.load_user
  app.use require "./locals"
  
  
  # Landing Routes
  app.get  "/", routes.auth.not_authenticated, routes.landing.get_root
  app.get  "/about", routes.auth.not_authenticated, routes.landing.get_about
  app.get  "/monetize", routes.auth.not_authenticated, routes.landing.get_monetize
  app.get  "/optout", routes.auth.not_authenticated, routes.landing.get_optout
  app.get  "/legal/:document", routes.landing.get_legal
  app.get  "/#{CONFIG.loader_io}", routes.landing.get_loader_io
  app.get  "/demo", routes.auth.not_authenticated, routes.landing.demo.get_root
  app.get  "/demo/:demo", routes.landing.demo.get_miza
  app.get  "/demo/:demo/:product", routes.landing.demo.get_miza
  app.post "/optout", routes.auth.not_authenticated, routes.landing.post_optout
  app.post "/access/request", routes.auth.not_authenticated, routes.landing.post_beta
  
  
  # Auth Routes
  app.get  "/login", routes.auth.not_authenticated, routes.auth.login.get
  app.get  "/register", routes.auth.not_authenticated, routes.auth.register.get
  app.get  "/logout", routes.auth.logout.get
  app.get  "/forgot", routes.auth.not_authenticated, routes.auth.forgot.get
  app.get  "/reset/:key", routes.auth.not_authenticated, routes.auth.forgot.reset_get
  app.post "/login", routes.auth.not_authenticated, routes.auth.login.post
  app.post "/register", routes.auth.not_authenticated, routes.auth.register.post
  app.post "/forgot", routes.auth.not_authenticated, routes.auth.forgot.post
  app.post "/reset/:key", routes.auth.not_authenticated, routes.auth.forgot.reset_post
  
  
  # Account Routes
  app.get  "/account", routes.auth.is_authenticated, routes.account.get_root
  app.get  "/account/:dashboard", routes.auth.is_authenticated, routes.account.get_root
  app.post "/account/profile", routes.auth.is_authenticated, routes.account.profile.post
  app.post "/account/notifications", routes.auth.is_authenticated, routes.account.notifications.post
  app.post "/account/password", routes.auth.is_authenticated, routes.account.password.post
  app.post "/account/billing", routes.auth.is_authenticated, routes.account.billing.post
  
  
  # Admin 3rd Party Dashboards
  admin_router = express.Router()
  admin_router.use "/scheduler", routes.auth.is_admin, Agendash(LIBS.agenda, CONFIG.agenda_dash)
  
  
  # Admin Routes
  app.get  "/admin", routes.auth.is_admin, routes.admin.get_root
  app.get  "/admin/invites", routes.auth.is_admin, routes.admin.invites.get
  app.get  "/admin/invites/remove/:invite", routes.auth.is_admin, routes.admin.invites.remove
  app.get  "/admin/reports", routes.auth.is_admin, routes.admin.reports.get
  app.get  "/admin/reports/metrics", routes.auth.is_admin, routes.admin.reports.metrics
  app.get  "/admin/industries", routes.auth.is_admin, routes.admin.industries.get
  app.get  "/admin/users", routes.auth.is_admin, routes.admin.users.get
  app.get  "/admin/users/:user/simulate", routes.auth.is_admin, routes.admin.users.simulate
  app.get  "/admin/publishers", routes.auth.is_admin, routes.admin.publishers.get
  app.get  "/admin/scheduler", routes.auth.is_admin, routes.admin.scheduler.get
  app.get  "/admin/emails", routes.auth.is_admin, routes.admin.emails.get
  app.get  "/admin/emails/:template", routes.auth.is_admin, routes.admin.emails.email
  app.get  "/admin/payouts", routes.auth.is_admin, routes.admin.payouts.get_root
  app.get  "/admin/payouts/:payout", routes.auth.is_admin, routes.admin.payouts.has_payout, routes.admin.payouts.get_create
  app.get  "/admin/payouts/:payout/delete", routes.auth.is_admin, routes.admin.payouts.has_payout, routes.admin.payouts.get_delete
  app.post "/admin/payouts/create", routes.auth.is_admin, routes.admin.payouts.post_create
  app.post "/admin/payouts/:payout", routes.auth.is_admin, routes.admin.payouts.has_payout, routes.admin.payouts.post_update
  app.post "/admin/payouts/:payout/transfer", routes.auth.is_admin, routes.admin.payouts.has_payout, routes.admin.payouts.post_transfer
  app.post "/admin/invites", routes.auth.is_admin, routes.admin.invites.post
  app.post "/admin/industries/update", routes.auth.is_admin, routes.admin.industries.update
  app.post "/admin/industries/create", routes.auth.is_admin, routes.admin.industries.create
  app.post "/admin/publishers", routes.auth.is_admin, routes.admin.publishers.post
  app.use  "/admin/vendor", admin_router
  
  
  # Dashboard Routes
  app.get "/dashboard", routes.auth.is_authenticated, routes.landing.get_dashboard
  
  
  # Publisher Routes
  app.get  "/publisher", routes.auth.is_authenticated, routes.publisher.get_root
  app.get  "/publisher/new", routes.auth.is_authenticated, routes.publisher.create.get
  app.get  "/publisher/:publisher", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.get_root
  app.get  "/publisher/:publisher/:dashboard", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.get_dashboard
  app.get  "/publisher/:publisher/billing/logs", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.billing.logs
  app.get  "/publisher/:publisher/billing/metrics", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.billing.metrics
  app.get  "/publisher/:publisher/analytics/logs", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.analytics.logs
  app.get  "/publisher/:publisher/analytics/metrics", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.analytics.metrics
  app.get  "/publisher/:publisher/members/invite/:invite/remove", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.members.remove_invite
  app.get  "/publisher/:publisher/members/member/:member/remove", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.members.remove_member
  app.post "/publisher/new", routes.auth.is_authenticated, routes.publisher.create.post
  app.post "/publisher/:publisher/members/add", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.members.add
  app.post "/publisher/:publisher/settings", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.settings.post
  app.post "/publisher/:publisher/abtest", routes.auth.is_authenticated, routes.auth.has_publisher, routes.publisher.abtest.post
  
  
  # Error Handlers
  app.get "*", routes.landing.get_not_found
  
  if CONFIG.is_prod
    app.use LIBS.bugsnag.errorHandler
  
  app.use require("./error")
  
  
  # Export
  return app
