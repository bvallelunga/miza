URL = require "url"
scraper = require 'product-scraper'


module.exports.product = (url)->
  url_parsed = URL.parse url
  hostname = url_parsed.hostname.split(".").slice(-2).join(".")
  
  if hostname != "amazon.com"
    return Promise.reject "Please provide an amazon product url."
  
  LIBS.scrapers.scrape(url).then ($)->  
    images = [
      $(".imgTagWrapper img").attr("src")
    ]
    title = $("#productTitle").text().trim()
    price = $("#priceblock_ourprice, #priceblock_saleprice").text().trim()
    
    if title.length > 50
      title = title.slice(0, 50) + "..."
    
    return {
      image_selection: false
      link: url
      format: "product"
      config: {
        action: "#{price} on Amazon"
        images: images
        product: {
          title: title
          price: price
          image: images[0]
          brand: {
            name: $("#bylineInfo_feature_div a").text().trim()
            url: $("#bylineInfo_feature_div a").attr("href")
          }
          reviews: parseInt $("#acrCustomerReviewText").text()
        }
        site: "amazon"
      }
      images: images
    }
      
  .catch ->
    return Promise.reject "Please provide an amazon product url."
