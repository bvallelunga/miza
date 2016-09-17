module.exports.up = (sequelize, models)->
  
  Promise.map [
    {
      id: 1
      name: "Double Click"
      slug: "dfp"
      is_enabled: true
    }
    {
      id: 2
      name: "AdSense"
      slug: "adsense"
      is_enabled: false
    }
    {
      id: 3
      name: "Carbon"
      slug: "carbon"
      is_enabled: true
    }
  ], (data)->
    models.Network.findOrCreate({
      individualHooks: true
      where: {
        slug: data.slug
      }
      defaults: data
    })
