module.exports = {
  
  pixel_tracker: new Buffer("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7", "base64")
  
  roots: {
    double_click: {
      raw: 'http://www.googletagservices.com/tag/js/gpt.js'
      encoded: new Buffer('www.googletagservices.com/tag/js/gpt.js').toString('base64')
    }
  }
  
  targets: [
    "googlesyndication", "googleadservices",
    "doubleclick", "googleads.g.doubleclick.net"
  ].map (target)->
    return "(#{target})"
  .join "|"
  
}