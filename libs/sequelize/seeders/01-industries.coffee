module.exports.up = (sequelize, models)->
  
  Promise.map [
    {
      name: "Technology"
      id: 1
      cpm: 2.25
      cpc: 1
      max_impressions: 100000
      private: true
    }
  ], (data)->
    models.Industry.findOrCreate({
      where: {
        name: data.name
      },
      defaults: data
    })