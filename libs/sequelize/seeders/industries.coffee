module.exports.up = (sequelize, models)->
  
  Promise.all [
    create_industry models, "Automotive", "cpc", 1.57
    create_industry models, "Education", "cpc", 4.3
    create_industry models, "Financial", "cpc", 2.61
    create_industry models, "Health", "cpc", 2.16
    create_industry models, "Home & Garden", "cpc", 1.3
    create_industry models, "Shopping", "cpc", 0.77
    create_industry models, "Telecom", "cpc", 1.35
    create_industry models, "Health", "cpc", 0.91
    create_industry models, "Other", "cpc", 0
  ]
    
  
create_industry = (models, name, type, cost)->
  models.Industry.findOrCreate({
    where: {
      name: name
    },
    defaults: {
      type: type
      cost: cost
    }
  })
