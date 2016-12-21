moment = require "moment"

module.exports = require("../template") {
  intervals: [
    ["alerts.publisher_deactivated", "0 10 * * *"]
  ]
  config: {
    priority: "medium" 
  }
}, (job)->  
  end_date = moment().subtract(3, "day")
    .startOf("day")
    .toDate()
 
  LIBS.models.Publisher.findAll({
    where: {
      is_activated: true
      is_demo: false
    }
  }).each (publisher)->           
    publisher.reports({
      interval: "day"
      created_at: {
        $gte: end_date
      }
    }, {
      limit: 2
    }).then (reports)->      
      if reports.all.length < 2
        return Promise.resolve()
    
      day1 = reports.all[1].impressions
      day2 = reports.all[0].impressions
      change_pct = ((day2 - day1) / day1) * 100
    
      if change_pct < -70
        LIBS.slack.message {
          text: "ALERT: #{publisher.name} had #{Math.floor Math.abs change_pct}% less impressions yesterday. Something may be wrong! <#{CONFIG.web_server.host}/dashboard/#{publisher.key}/analytics|Publisher Analytics>"
        }