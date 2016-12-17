module.exports = {
  
  pixel_tracker: new Buffer("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7", "base64")
  random_slug: Math.random().toString(36).substr(2, 20)
  url_safe_decoder: (str)->
    str = (str + '===').slice(0, str.length + (str.length % 4));
    return str.replace(/-/g, '+').replace(/_/g, '/');
}