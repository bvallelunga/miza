request = require "request-promise"
JSDOM = require('jsdom').jsdom

module.exports = {
  instagram: require "./instagram"
  twitter: require "./twitter"
  scrape: (url)->
    request({
      uri: url
      transform: (response)->
        new Promise (res, rej)->
          dom = new JSDOM(response, { runScripts: "dangerously" })
          setTimeout (-> res dom), 500
    })
  
}