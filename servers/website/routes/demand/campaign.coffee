moment = require "moment"
numeral = require "numeral"
request = require "request"

module.exports.fetch = (req, res, next)->  
  LIBS.models.Campaign.findOne({
    where: {
      id: req.subdashboard or req.params.campaign
      advertiser_id: req.advertiser.id
    }
    include: [{
      model: LIBS.models.Creative
      as: "creatives"
    }]
  }).then (campaign)->
    if not campaign?
      return res.redirect "/demand/#{req.advertiser.key}/campaigns"
  
    if req.data?
      req.data.dashboard_width = "large"
      req.data.campaign = campaign
      req.data.js.push "keen", "data-table", "tooltip"
      req.data.css.push "keen", "data-table", "tooltip"
  
    req.campaign = campaign
    req.subdashboard = null
    res.locals.config.campaign = campaign.id
    next()
    
  .catch next
  

module.exports.post_update = (req, res, next)->
  Promise.resolve().then ->
    if req.body.action == "delete"
      return req.campaign.destroy()
      
    if req.campaign.status == "queued"
      if req.body.action == "running"
        req.campaign.start_at = new Date()
        
      else if req.body.action == "paused"
        return Promise.reject "Queued campaigns can not be paused"
      
    req.campaign.status = req.body.action
    req.campaign.save()
  
  .then ->
    res.json {
      success: true
    }
  
  .catch next
  

module.exports.get_industries = (req, res, next)->
  req.campaign.getIndustries({
    sort: "name ASC"
  }).then (industries)->
    res.json {
      success: true
      results: industries
    }
  
  .catch next
  
  
module.exports.get_publishers = (req, res, next)->
  end_date = req.campaign.end_at or new Date()
  months = Math.max 1, moment.duration(end_date - req.campaign.start_at).months()
  month_timeframe = "this_#{months}_months"
  
  query = (query_name)->
    LIBS.keen.fetchDataset(query_name, {
      index_by: String(req.campaign.id)
      timeframe: month_timeframe
    }).then (response)->
      return response.result.map (data)-> data.value
  
  Promise.props({
    impressions: query "campaign-publisher-impression-count"
    clicks: query "campaign-publisher-click-count"
  }).then (data)->
    metrics = {
      impressions: {}
      clicks: {}
    }
    
    for name, intervals of data    
      for interval in intervals
        for publishers in interval
          key = publishers["publisher.key"]
          if not metrics[name][key]?
            metrics[name][key] = 0
            
          metrics[name][key] += publishers["result"]
        
    return metrics
    
  .then (metrics)->
    req.campaign.getIndustries().then (industries)->
      targeting = industries[0].targeting
      end_date = req.campaign.end_at or new Date()
    
      LIBS.models.Publisher.findAll({
        where: {
          is_activated: true
        }
        order: "name ASC"
        include: [{
          model: LIBS.models.Industry
          as: "industry"
        }]
      }).map (publisher)->
        impressions = metrics.impressions[publisher.key] or 0
        clicks = metrics.clicks[publisher.key] or 0
      
        if not targeting.blocked_publishers?
          targeting.blocked_publishers = []
      
        if targeting.blocked_publishers.indexOf(publisher.key) == -1
          status = "Enabled"
        else
          status = "Blocked"
                  
        return {
          id: publisher.key
          name: publisher.name
          status: status
          industry: publisher.industry.name
          metrics: {
            impressions: numeral(impressions).format("1[,]000")
            clicks: numeral(clicks).format("1[,]000")
            ctr: numeral(clicks/(impressions or 1)).format("0.00%")
          }
        }
    
  .then (publishers)->
    res.json {
      success: true
      results: publishers
    }
      
  .catch next
  

module.exports.get_charts = (req, res, next)->
  end_date = req.campaign.end_at or new Date()
  month_timeframe = JSON.stringify({
    start: moment.utc(req.campaign.start_at).startOf("day").toISOString()
    end: moment.utc(end_date).add(2, "day").startOf("day").toISOString()
  })
  
  query = (query_name)->
    LIBS.keen.fetchDataset(query_name, {
      index_by: String(req.campaign.id)
      timeframe: month_timeframe
    }).catch (error)->
      LIBS.bugsnag.notify error
      console.log error
      return LIBS.keen.errors.DATA
  
  Promise.props({
    impressions_chart: Promise.all([
      query "campaign-impression-chart"
      query "campaign-click-chart"
    ])
  }).then (charts)->  
    res.json(charts) 
  
  .catch next
  
  
  
module.exports.post_industries = (req, res, next)->
  Promise.resolve().then ->
    if not req.campaign.active
      return Promise.reject """
        Campaign must be running to modify a specific industry.
      """
      
    LIBS.models.CampaignIndustry.findAll({
      where: {
        advertiser_id: req.advertiser.id
        campaign_id: req.campaign.id
        id: {
          $in: req.body.selected
        }
      }
    }).each (industry)->
      industry.update({
        status: req.body.action
      })
  
  .then ->
    res.json {
      success: true
    }
  
  .catch next
  
  
module.exports.post_publishers = (req, res, next)->
  Promise.resolve().then ->    
    LIBS.models.CampaignIndustry.findAll({
      where: {
        advertiser_id: req.advertiser.id
        campaign_id: req.campaign.id
      }
    }).each (industry)->
      targeting = industry.targeting
    
      if not targeting.blocked_publishers?
        targeting.blocked_publishers = []
    
      for publisher in req.body.selected
        index = targeting.blocked_publishers.indexOf(publisher)
        
        if index > -1
          targeting.blocked_publishers.splice(index, 1)
          
        if req.body.action == "block"
          targeting.blocked_publishers.push publisher
      
      industry.update({
        targeting: targeting
      })
  
  .then ->
    res.json {
      success: true
    }
  
  .catch next
