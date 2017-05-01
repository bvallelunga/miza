URL = require "url"

module.exports.product = (url)->
  url_parsed = URL.parse url
  hostname = url_parsed.hostname.split(".").slice(-2).join(".")
  
  if hostname != "etsy.com" or url_parsed.pathname.indexOf("listing") == -1
    return Promise.reject "Please provide an Etsy product url."
  
  LIBS.scrapers.scrape(url).then ($)->    
    images = ($("#image-carousel li").map ->
      return $(@).data("full-image-href")
    ).toArray()
  
    title = $("#listing-page-cart h1").text().trim()
    price = $("#listing-page-cart #listing-price").text().trim()
    
    if title.length > 50
      title = title.slice(0, 50) + "..."
    
    return {
      image_selection: false
      link: url
      format: "product"
      config: {
        action: "#{price} on Etsy"
        images: images
        product: {
          title: title
          price: price
          image: images[0]
          brand: {
            name: $(".shop-name a[itemprop=url] span").text().trim()
            url: $(".shop-name a[itemprop=url]").attr("href")
          }
          additional: $(".review-rating-count").text().replace(/\(|\)/g, "")
        }
        site: "etsy"
      }
      images: images
    }
      
  .catch (error)->
    return Promise.reject "Please provide an etsy product url."
