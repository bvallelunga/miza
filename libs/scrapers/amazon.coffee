URL = require "url"

module.exports.product = (url)->
  url_parsed = URL.parse url
  hostname = url_parsed.hostname.split(".").slice(-2).join(".")
  
  if hostname != "amazon.com" or url_parsed.pathname.indexOf("dp") == -1
    return Promise.reject "Please provide an Amazon product url."
  
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
      size: "300x370"
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
          additional: $("#acrCustomerReviewText").eq(0).text()
        }
        site: "amazon"
      }
      images: images
    }
      
  .catch ->
    return Promise.reject "Please provide an amazon product url."
