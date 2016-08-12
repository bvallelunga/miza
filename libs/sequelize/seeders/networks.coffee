module.exports.up = (sequelize, models)->
  
  Promise.map [
    {
      name: "Double Click"
      slug: "dfp"
      is_enabled: true
      entry_raw_url: "http://www.googletagservices.com/tag/js/gpt.js"
      domains: [
        "googlesyndication", "googleadservices",
        "doubleclick", "googleads.g.doubleclick.net"
      ]
    },
    {
      name: "Google Adsense"
      slug: "sense"
      is_enabled: false
      entry_raw_url: ""
      domains: []
    },
    {
      name: "Ad Roll"
      slug: "roll"
      is_enabled: false
      entry_raw_url: ""
      domains: []
    },
    {
      name: "Live Rail"
      slug: "rail"
      is_enabled: false
      entry_raw_url: ""
      domains: []
    },
    {
      name: "Carbon"
      slug: "carbon"
      is_enabled: false
      entry_raw_url: ""
      domains: []
    }
  ], (data)->
    models.Network.findOrCreate({
      individualHooks: true
      where: {
        slug: data.slug
      }
      defaults: data
    }).then (networks)->
      networks[0].addPublishers [ 1 ]
