module.exports.up = (sequelize, models)->
  
  Promise.all [
#     create_industry "Automotive", 1, 4.50
#     create_industry "Consumer Package Goods", 2, 4.49
#     create_industry "E-commerce", 3, 7.84
#     create_industry "Education", 4, 5.61
#     create_industry "Entertainment", 5, 3.9
#     create_industry "Financial Services", 6, 9.43
#     create_industry "Food and Beverage", 7, 3.99
#     create_industry "Gaming", 8, 4.97
#     create_industry "Professional Services", 9, 13.35
#     create_industry "Retail", 10, 5.21
#     create_industry "Technology", 11, 10.8
#     create_industry "Travel", 12, 9.66
    create_industry "Carbon: Business Circle", 13, 5
    create_industry "Carbon: Dev Circle", 14, 3.5
    create_industry "Carbon: Design Circle", 15, 3
  ]
    
  
  create_industry = (name, id, cpm)->
    models.Industry.findOrCreate({
      where: {
        name: name
      },
      defaults: {
        id: id
        cpm: cpm
      }
    })
