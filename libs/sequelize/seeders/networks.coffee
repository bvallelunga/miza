module.exports.up = (sequelize, models)->
  
  Promise.map [
    {
      name: "Double Click"
      slug: "dfp"
      is_enabled: true
      entry_js: "window.googletag"
      entry_raw_url: "http://www.googletagservices.com/tag/js/gpt.js"
      domains: [
        "googlesyndication", "googleadservices",
        "doubleclick", "googleads.g.doubleclick.net"
      ]
    },
    {
      name: "AdSense"
      slug: "adsense"
      is_enabled: false
      entry_raw_url: ""
      entry_js: "window.adsbygoogle"
      domains: []
    },
    {
      name: "Ad Roll"
      slug: "roll"
      is_enabled: false
      entry_raw_url: ""
      entry_js: ""
      domains: []
    },
    {
      name: "Live Rail"
      slug: "rail"
      is_enabled: false
      entry_raw_url: ""
      entry_js: ""
      domains: []
    },
    {
      name: "Carbon"
      slug: "carbon"
      is_enabled: false
      entry_raw_url: ""
      entry_js: ""
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
