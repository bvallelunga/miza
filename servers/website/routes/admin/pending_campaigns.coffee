module.exports.get = (req, res, next)->
  LIBS.models.Campaign.findAll({
    where: {
      status: "pending"
    }
    include: [{
      model: LIBS.models.Advertiser
      as: "advertiser"
    }]
    order: [
      ['created_at', 'DESC']
    ]
  }).then (campaigns)->  
    res.render "admin/pending_campaigns", {
      js: req.js.renderTags "modal", "admin-table", "fa"
      css: req.css.renderTags "modal", "admin"
      title: "Admin Pending Campaigns"
      campaigns: campaigns
      dashboard: "admin"
    }
    
  .catch next
  

module.exports.post = (req, res, next)->
  Promise.filter req.body.campaigns, (campaign)->
    return campaign.approved.length > 0
    
  .map (form)->
    form.approved = form.approved == "true"
    
    if not form.approved and not form.notes
      return Promise.reject "Please provide notes when rejecting a campaign!"
    
    return Promise.props {
      form: form
      campaign: LIBS.models.Campaign.findById(form.id)
    }
    
  .filter (data)->
    return data.campaign.status == "pending"

  .each (data)->
    status = "rejected"
    
    if data.form.approved
      status = if data.campaign.start_at? then "queued" else "running"
      
    else
      data.campaign.config.rejection_notes = data.form.notes
  
    data.campaign.admin_override = true
    return data.campaign.update({
      status: status
      config: data.campaign.config
    })
    
  .then ->
    res.json {
      success: true
      next: req.path
      message: "Campaigns have been updated!"
    }
    
  .catch next