request = require "request-promise"
JSDOM = require('jsdom').jsdom

module.exports = {
  instagram: require "./instagram"
  scrape: (url)->
    request({
      uri: url
      transform: (response)->
        new Promise (res, rej)->
          dom = new JSDOM(response, { runScripts: "dangerously" })
          setTimeout (-> res dom), 15000
    })
  
}