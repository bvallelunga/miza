moment = require "moment"
numeral = require "numeral"

module.exports.scrape = (req, res, next)->
  scraper = null

  switch req.body.format
    when "instagram_profile"
      scraper = LIBS.scrapers.instagram.profile

    when "instagram_post"
      scraper = LIBS.scrapers.instagram.post

    when "twitter_account"
      scraper = LIBS.scrapers.twitter.account

    when "amazon_product"
      scraper = LIBS.scrapers.amazon.product

    when "etsy_product"
      scraper = LIBS.scrapers.etsy.product

    when "soundcloud"
      scraper = LIBS.scrapers.soundcloud

    when "kickstarter_project"
      scraper = LIBS.scrapers.kickstarter

    when "indiegogo_project"
      scraper = LIBS.scrapers.indiegogo

    else
      return next "Invalid campaign format type: #{req.body.format}"

  if req.body.scrape_url.indexOf("http://") == -1 and req.body.scrape_url.indexOf("https://") == -1
    req.body.scrape_url = "http://#{req.body.scrape_url}"

  scraper(req.body.scrape_url).then (response)->
    res.json(response)
  .catch(next)


module.exports.create = (req, res, next)->
  if req.body.creative.format == "300 x 250" and not req.body.creative.image_url.length > 0
    return next "Please make sure you have uploaded an image for your creative"

  if not req.body.creative.link.length > 0
    return next "Please make sure you have a click link for your creative"

  Promise.resolve().then ->
    query = {
      private: false
      max_impressions: {
        $gt: 0
      }
    }

    if req.body.industries? and req.body.industries.length > 0
      query = {
        id: {
          $in: req.body.industries.map (id)-> Number id
        }
      }

    LIBS.models.Industry.findAll({
      where: query
    })
  .then (targeting)->
    bid = parseFloat req.body.bid
    budget = parseFloat req.body.budget
    daily_budget = parseFloat(req.body.daily_budget) or 0
    creative_config = {}

    try
      creative_config = JSON.parse(req.body.creative.config)

    if req.body.creative.config? and creative_config.images.length == 0
      return Promise.reject "Please make sure you have selected at least 1 image."

    if bid == NaN
      return Promise.reject "Please make sure you entered a valid bid"

    if bid < 0.02
      return Promise.reject "Please make sure your bid is at least $0.02"

    if budget == NaN
      return Promise.reject "Please make sure you entered a valid budget"

    if budget < 2
      return Promise.reject "Please make sure your total budget is at least $2"

    if budget < daily_budget
      return Promise.reject "Please make sure your total budget is greater than your daily budget"

    if daily_budget > 0 and daily_budget < 2
      return Promise.reject "Please make sure your daily budget is at least $2"

    start_date = moment(req.body.start_date, "MM-DD-YYYY")
    start_date = if start_date.isValid() then start_date.startOf("day").toDate() else null

    end_date = moment(req.body.end_date, "MM-DD-YYYY")
    end_date = if end_date.isValid() then end_date.endOf("day").toDate() else null

    is_house = req.body.is_house == "true" and req.user.is_admin
    temp_bid = if req.body.model == "cpm" then bid/1000 else bid
    quantity_requested = Math.floor(budget/temp_bid)
    quantity_daily_requested = Math.floor(daily_budget/temp_bid)
    bid = if is_house then 0 else bid
    credits = budget
    status = "pending"

    if quantity_daily_requested <= 0
      quantity_daily_requested = null

    if quantity_requested <= 0
      return Promise.reject "Please increase your budget by at least #{numeral(temp_bid - budget).format("$0.00")}"

    if credits > req.advertiser.credits
      credits = req.advertiser.credits

    if req.user.is_admin
      if start_date?
        status = "queued"

      else
        status = "running"
        start_date = new Date()

    LIBS.models.sequelize.transaction (t)->
      LIBS.models.Campaign.create({
        name: req.body.name
        type: req.body.model
        status: status
        start_at: start_date
        end_at: end_date
        advertiser_id: req.advertiser.id
        amount: bid
        credits: credits
        quantity_needed: quantity_requested
        quantity_requested: quantity_requested
        quantity_daily_needed: quantity_daily_requested
        quantity_daily_requested: quantity_daily_requested
        targeting: req.body.targeting or {}
        config: {
          is_house: is_house
        }
      }, {transaction: t}).then (campaign)->
        req.advertiser.update({
          is_activated: true
          credits: Math.max(0, req.advertiser.credits - credits)
        }, {transaction: t}).then ->
          Promise.map targeting, (industry)->
            LIBS.models.CampaignIndustry.create({
              type: req.body.model
              status: campaign.status
              active: campaign.active
              advertiser_id: req.advertiser.id
              campaign_id: campaign.id
              industry_id: industry.id
              name: industry.name
              amount: bid
              targeting: req.body.targeting or {}
              config: {
                is_house: is_house
              }
            }, {transaction: t})

        .then ->
          Promise.resolve().then ->
            if req.body.creative.image_url.length > 0
              return LIBS.models.Creative.fetch_image(req.body.creative.image_url)

            return new Buffer(1)
          .then (image)->
            trackers = req.body.creative.trackers.split("\n")
            size = req.body.creative.size or null

            if req.user.is_admin and req.body.creative.disable_incentive.length > 0
              creative_config.disable_incentive = Number req.body.creative.disable_incentive

            if trackers.length == 1 and trackers[0].length == 0
              trackers = []

            LIBS.models.Creative.create({
              advertiser_id: req.advertiser.id
              campaign_id: campaign.id
              link: campaign.utm_link(req.body.creative.link)
              trackers: req.body.creative.trackers.split("\n")
              format: req.body.creative.format
              size: size
              image: image
              config: creative_config
            }, {transaction: t})

        .then ->
          return campaign

  .then (campaign)->
    next_dashboard = "campaign"

    if req.advertiser.owner.id == req.user.id and not req.advertiser.owner.stripe_card?
      next_dashboard = "add_card"

    res.json({
      success: true
      next: "/m/dashboard/demand/#{req.advertiser.key}/#{next_dashboard}/#{campaign.id}"
    })

  .catch next
