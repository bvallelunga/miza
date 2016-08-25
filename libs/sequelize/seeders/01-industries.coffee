module.exports.up = (sequelize, models)->
  
  Promise.all [
    create_industry models, "Automotive", 1, 4.50, 0.18
    create_industry models, "Consumer Package Goods", 2, 4.49, 0.25
    create_industry models, "E-commerce", 3, 7.84, 0.51
    create_industry models, "Education", 4, 5.61, 0.44
    create_industry models, "Entertainment", 5, 3.9, 0.16
    create_industry models, "Financial Services", 6, 9.43, 0.6
    create_industry models, "Food and Beverage", 7, 3.99, 0.19
    create_industry models, "Gaming", 8, 4.97, 1.05
    create_industry models, "Professional Services", 9, 13.35, 1.01
    create_industry models, "Retail", 10, 5.21, 0.25
    create_industry models, "Technology", 11, 10.8, 0.67
    create_industry models, "Travel", 12, 9.66, 0.4
  ]
    
  
create_industry = (models, id, name, cpm, cpc)->
  models.Industry.findOrCreate({
    where: {
      id: id
    },
    defaults: {
      name: name
      cpm: cpm
      cpc: cpc
      fee: 0.3
    }
  })
