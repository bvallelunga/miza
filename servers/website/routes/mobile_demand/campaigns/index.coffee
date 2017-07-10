country_data = require 'country-data'
numeral = require "numeral"

module.exports.fetch = (req, res, next)->
  req.data.js.push("date-range")
  req.data.css.push("date-range")
  req.data.dashboard_width = "medium"
  req.data.config = {
    advertiser: req.advertiser.key
  }
  req.data.new_advertiser = req.query.new_advertiser? or req.session.new_advertiser
  req.session.new_advertiser = false

  if not req.subdashboard
    req.data.js.push("data-table")
    req.data.css.push("data-table")
    req.subdashboard = "listing"
    next()

  else if req.subdashboard == "create"
    req.subdashboard = "builder"
    req.data.css.push("chosen-select")
    req.data.js.push("modal", "chosen-select")
    req.data.models = ["cpm", "cpc"]
    req.data.model = "cpc"
    req.data.format = req.query.format or "image"
    req.data.country_data = country_data
    req.data.approved_countries = [
      "us", "ca", "mx", "de", "gb",
      "tr", "nz", "fr", "au", "se",
      "ph", "in", "cn", "jp", "no",
      "dk", "fi"
    ]

    Promise.props({
      industries: LIBS.models.Industry.listed(req.user.is_admin).then (industries)->
        req.data.industries = industries

      auto_bid_cpm: LIBS.models.Campaign.findAll({
        where: {
          status: {
            $ne: "completed"
          }
        }
      }).then (campaigns)->
        cpc = 0
        avg_ctr = 0.2

        for campaign in campaigns
          if campaign.type == "cpc"
            cpc += campaign.amount
          else if campaign.type == "cpm"
            cpc += 0.1 * campaign.amount / avg_ctr

        cpc = Math.max(0.45, cpc/(campaigns.length or 1))
        cpc += cpc * 0.1
        cpm = cpc * avg_ctr * 10

        req.data.auto_bid_cpm_min = numeral(cpm - (cpm * 0.25)).format("0.00")
        req.data.auto_bid_cpm_max = numeral(cpm + (cpm * 0.25)).format("0.00")
        req.data.auto_bid_cpm = numeral(cpm).format("0.00")

        req.data.auto_bid_cpc_min = numeral(cpc - (cpc * 0.25)).format("0.00")
        req.data.auto_bid_cpc_max = numeral(cpc + (cpc * 0.25)).format("0.00")
        req.data.auto_bid_cpc = numeral(cpc).format("0.00")

    }).then(-> next()).catch next

  else
    res.redirect "/m/dashboard/demand/#{req.advertiser.key}/campaigns"


module.exports.post_updates = (req, res, next)->
  Promise.resolve().then ->
    if req.body.action == "delete"
      return LIBS.models.Campaign.destroy({
        individualHooks: true
        where: {
          advertiser_id: req.advertiser.id
          id: {
            $in: req.body.campaigns
          }
        }
      })

    LIBS.models.Campaign.findAll({
      where: {
        advertiser_id: req.advertiser.id
        id: {
          $in: req.body.campaigns
        }
        status: {
          $notIn: ["completed", "rejected"]
        }
      }
    }).each (campaign)->
      if campaign.status == "pending" and req.body.action != "completed"
        return Promise.resolve()

      if campaign.status == "queued"
        if req.body.action == "running"
          campaign.start_at = new Date()

        else if req.body.action == "paused"
          return Promise.reject "Queued campaigns can not be paused"

      campaign.status = req.body.action
      campaign.save()

  .then ->
    res.json {
      success: true
    }

  .catch next


module.exports.post_list = (req, res, next)->
  req.advertiser.getCampaigns({
    where: {
      $or: [{
        start_at: {
          $gte: new Date req.body.dates.start
          $lte: new Date req.body.dates.end
        }
      }, {
        status: "running"
        start_at: {
          $lte: new Date req.body.dates.start
        }
      }, {
        status: "pending"
      }, {
        status: "rejected"
      }]
    }
    include: [{
      model: LIBS.models.CampaignIndustry
      as: "industries"
    }]
    order: [
      ["created_at", "DESC"]
    ]
  }).then (campaigns)->
    res.json {
      success: true
      results: campaigns
    }

  .catch next


module.exports.builder = require "./builder"
