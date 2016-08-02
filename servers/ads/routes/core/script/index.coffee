module.exports = {
  
  roots: {
    double_click: new Buffer('www.googletagservices.com/tag/js/gpt.js').toString('base64')
  }
  
  targets: [
    "googlesyndication", "googleadservices",
    "doubleclick"
  ].map (target)->
    return "(#{target})"
  .join "|"
  
}