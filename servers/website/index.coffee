express = require 'express'
session = require 'express-session'
routes = require("./routes")()
Agendash = require "agendash"
app = express()


module.exports = (srv)->
  # 3rd Party Ignore Routes  
  auth_ignore_regex = new RegExp "^((?!#{[
    "/admin/vendor"
  ].join("|")})[\\s\\S])*$"


  # Express Setup
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'
  app.use require("compression")()
  app.use require("cookie-parser")()
  app.use auth_ignore_regex, require("csurf")({ cookie: true })
  app.use require('express-session')(CONFIG.cookies.session session, LIBS.redis.redis)
  app.use LIBS.bugsnag.requestHandler

  # Public Routes
  require("./assets")(app, srv,  __dirname + '/public')
  app.use "/imgs", express.static __dirname + '/public/images'
  
  
  # Load User & Locals
  app.use routes.router
  app.use routes.auth.load_user
  app.use require "./locals"
  
  
  # Landing Routes
  app.get  "/", routes.landing.get_root
  app.get  "/supply", routes.landing.supply.get_root
  app.get  "/supply/monetize", routes.landing.supply.get_monetize
  app.get  "/supply/demo", routes.landing.supply.get_demo
  app.get  "/supply/demo/:demo", routes.landing.supply.get_demo_ad
  app.get  "/demand", routes.landing.demand.get_root
  app.get  "/demand/social", routes.landing.demand.get_social
  app.get  "/demand/music", routes.landing.demand.get_music
  app.get  "/demand/commerce", routes.landing.demand.get_commerce
  app.get  "/demand/enterprise", routes.landing.demand.get_enterprise
  app.get  "/about", routes.landing.get_about
  app.get  "/optout", routes.auth.not_authenticated, routes.landing.get_optout
  app.get  "/legal/:document", routes.landing.get_legal
  app.get  "/decks/:deck", routes.landing.get_deck
  app.get  "/#{CONFIG.loader_io}", routes.landing.get_loader_io
  app.get  "/s/:key", routes.landing.get_shortener
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
  app.get  "/admin/industries", routes.auth.is_admin, routes.admin.industries.get
  app.get  "/admin/users", routes.auth.is_admin, routes.admin.users.get
  app.get  "/admin/users/:user/simulate", routes.auth.is_admin, routes.admin.users.simulate
  app.get  "/admin/publishers", routes.auth.is_admin, routes.admin.publishers.get
  app.get  "/admin/advertisers", routes.auth.is_admin, routes.admin.advertisers.get
  app.get  "/admin/scheduler", routes.auth.is_admin, routes.admin.scheduler.get
  app.get  "/admin/demo", routes.auth.is_admin, routes.admin.demo.get
  app.get  "/admin/payouts", routes.auth.is_admin, routes.admin.payouts.get_root
  app.get  "/admin/pending_campaigns", routes.auth.is_admin, routes.admin.pending_campaigns.get
  app.get  "/admin/payouts/:payout", routes.auth.is_admin, routes.admin.payouts.has_payout, routes.admin.payouts.get_create
  app.post "/admin/pending_campaigns", routes.auth.is_admin, routes.admin.pending_campaigns.post
  app.post  "/admin/demo", routes.auth.is_admin, routes.admin.demo.post
  app.post "/admin/payouts/:payout/delete", routes.auth.is_admin, routes.admin.payouts.has_payout, routes.admin.payouts.post_delete
  app.post "/admin/payouts/create", routes.auth.is_admin, routes.admin.payouts.post_create
  app.post "/admin/payouts/:payout", routes.auth.is_admin, routes.admin.payouts.has_payout, routes.admin.payouts.post_update
  app.post "/admin/payouts/:payout/transfer", routes.auth.is_admin, routes.admin.payouts.has_payout, routes.admin.payouts.post_transfer
  app.post "/admin/invites", routes.auth.is_admin, routes.admin.invites.post
  app.post "/admin/industries/update", routes.auth.is_admin, routes.admin.industries.update
  app.post "/admin/industries/create", routes.auth.is_admin, routes.admin.industries.create
  app.post "/admin/publishers", routes.auth.is_admin, routes.admin.publishers.post
  app.post "/admin/advertisers", routes.auth.is_admin, routes.admin.advertisers.post
  app.use  "/admin/vendor", admin_router
  
  
  # Dashboard Routes
  app.get "/dashboard", routes.auth.is_authenticated, routes.landing.get_dashboard
  
  
  # Demand Partner Routes
  app.get  "/dashboard/demand", routes.auth.is_authenticated, routes.demand.get_root
  app.get  "/dashboard/demand/new", routes.auth.is_authenticated, routes.demand.create.get
  app.get  "/dashboard/demand/:advertiser", routes.auth.is_authenticated, routes.demand.auth, routes.demand.get_root
  app.get  "/dashboard/demand/:advertiser/:dashboard", routes.auth.is_authenticated, routes.demand.auth, routes.demand.fetch_data, routes.demand.get_dashboard
  app.get  "/dashboard/demand/:advertiser/campaign/:campaign/industries", routes.auth.is_authenticated, routes.demand.auth, routes.demand.campaign.fetch, routes.demand.campaign.get_industries
  app.get  "/dashboard/demand/:advertiser/campaign/:campaign/publishers", routes.auth.is_admin, routes.demand.auth, routes.demand.campaign.fetch, routes.demand.campaign.get_publishers
  app.get  "/dashboard/demand/:advertiser/members/invite/:invite/remove", routes.auth.is_authenticated, routes.demand.auth, routes.demand.members.remove_invite
  app.get  "/dashboard/demand/:advertiser/members/member/:member/remove", routes.auth.is_authenticated, routes.demand.auth, routes.demand.members.remove_member
  app.get  "/dashboard/demand/:advertiser/members/member/:member/owner", routes.auth.is_authenticated, routes.demand.auth, routes.demand.members.owner_member
  app.get  "/dashboard/demand/:advertiser/campaign/:campaign/charts", routes.auth.is_authenticated, routes.demand.auth, routes.demand.campaign.fetch, routes.demand.campaign.get_charts
  app.get  "/dashboard/demand/:advertiser/:dashboard/:subdashboard", routes.auth.is_authenticated, routes.demand.auth, routes.demand.fetch_data, routes.demand.get_dashboard
  app.post "/dashboard/demand/new", routes.auth.is_authenticated, routes.demand.create.post
  app.post "/dashboard/demand/:advertiser/campaigns/create", routes.auth.is_authenticated, routes.demand.auth, routes.demand.campaigns.builder.create
  app.post "/dashboard/demand/:advertiser/campaigns/create/scrape", routes.auth.is_authenticated, routes.demand.auth, routes.demand.campaigns.builder.scrape
  app.post "/dashboard/demand/:advertiser/campaigns/list", routes.auth.is_authenticated, routes.demand.auth, routes.demand.campaigns.post_list
  app.post "/dashboard/demand/:advertiser/campaigns/update", routes.auth.is_authenticated, routes.demand.auth, routes.demand.campaigns.post_updates
  app.post "/dashboard/demand/:advertiser/campaign/:campaign", routes.auth.is_authenticated, routes.demand.auth, routes.demand.campaign.fetch, routes.demand.campaign.post_update
  app.post "/dashboard/demand/:advertiser/campaign/:campaign/industries", routes.auth.is_authenticated, routes.demand.auth, routes.demand.campaign.fetch, routes.demand.campaign.post_industries
  app.post "/dashboard/demand/:advertiser/campaign/:campaign/publishers", routes.auth.is_admin, routes.demand.auth, routes.demand.campaign.fetch, routes.demand.campaign.post_publishers
  app.post "/dashboard/demand/:advertiser/billing/charges", routes.auth.is_authenticated, routes.demand.auth, routes.demand.billing.post_charges
  app.post "/dashboard/demand/:advertiser/settings", routes.auth.is_authenticated, routes.demand.auth, routes.demand.settings.post_update
  app.post "/dashboard/demand/:advertiser/members/add", routes.auth.is_authenticated, routes.demand.auth, routes.demand.members.post_add
  
  
  # Publisher Routes
  app.get  "/dashboard/supply", routes.auth.is_authenticated, routes.supply.get_root
  app.get  "/dashboard/supply/new", routes.auth.is_authenticated, routes.supply.create.get
  app.get  "/dashboard/supply/:publisher", routes.auth.is_authenticated, routes.supply.auth, routes.supply.get_root
  app.get  "/dashboard/supply/:publisher/:dashboard", routes.auth.is_authenticated, routes.supply.auth, routes.supply.get_dashboard
  app.get  "/dashboard/supply/:publisher/analytics/metrics", routes.auth.is_authenticated, routes.supply.auth, routes.supply.analytics.get
  app.get  "/dashboard/supply/:publisher/members/invite/:invite/remove", routes.auth.is_authenticated, routes.supply.auth, routes.supply.members.remove_invite
  app.get  "/dashboard/supply/:publisher/members/member/:member/remove", routes.auth.is_authenticated, routes.supply.auth, routes.supply.members.remove_member
  app.get  "/dashboard/supply/:publisher/members/member/:member/owner", routes.auth.is_authenticated, routes.supply.auth, routes.supply.members.owner_member
  app.post "/dashboard/supply/new", routes.auth.is_authenticated, routes.supply.create.post
  app.post "/dashboard/supply/:publisher/members/add", routes.auth.is_authenticated, routes.supply.auth, routes.supply.members.add
  app.post "/dashboard/supply/:publisher/settings", routes.auth.is_authenticated, routes.supply.auth, routes.supply.settings.post
  
  
  # Error Handlers
  app.get "*", routes.landing.get_not_found
  
  if CONFIG.is_prod
    app.use LIBS.bugsnag.errorHandler
  
  app.use require("./error")
  
  
  # Export
  return app
