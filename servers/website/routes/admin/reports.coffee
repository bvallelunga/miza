numeral = require "numeral"
  

module.exports.get = (req, res, next)->
  LIBS.models.Publisher.findAll({
    where: {
      is_demo: false
    }
    include: [{
      model: LIBS.models.Industry
      as: "industry"
    }]
    order: [
      ['name', 'ASC']
    ]
  }).then (publishers)->      
    res.render "admin/reports", {
      js: req.js.renderTags "admin-reports"
      css: req.css.renderTags "admin", "dashboard-analytics"
      title: "Admin Reporting"
      publishers: publishers
      config: {
        publishers: publishers
        mixpanel_secret: CONFIG.mixpanel.secret
      }
    }
    
  .catch next
  
