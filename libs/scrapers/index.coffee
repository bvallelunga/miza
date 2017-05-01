request = require "request-promise"
cheerio = require "cheerio"

module.exports = {
  
  instagram: require "./instagram"
  twitter: require "./twitter"
  amazon: require "./amazon"
  etsy: require "./etsy"
  soundcloud: require "./soundcloud"
  indiegogo: require "./indiegogo"
  kickstarter: require "./kickstarter"
  scrape: (url)->
    request(url).then (response)->
      return cheerio.load(response)

}