module.exports.up = (sequelize, models)->
  
  Promise.map [
    {
      id: 1
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
      id: 2
      name: "AdSense"
      slug: "adsense"
      is_enabled: false
      entry_raw_url: ""
      entry_js: "window.adsbygoogle"
      domains: []
    },
    {
      id: 3
      name: "Ad Roll"
      slug: "roll"
      is_enabled: false
      entry_raw_url: ""
      entry_js: ""
      domains: []
    },
    {
      id: 4
      name: "Live Rail"
      slug: "rail"
      is_enabled: false
      entry_raw_url: ""
      entry_js: ""
      domains: []
    },
    {
      id: 5
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
