module.exports = (err, req, res, next)->
  console.error err.stack or err
  message = err.message or err
  csrf_token = ""
  
  if req.csrfToken?
    csrf_token = req.csrfToken()
  
  if err.code == 'EBADCSRFTOKEN'
    message = "Invalid CSRF token!"
    
  if err.errors?
    message = err.errors.map (error)->
      if error.type == "unique violation"
        return "#{error.path} is already in use"
      
      return error.message
    
    .join "\n"
  
  res.status(403)
  
  if req.xhr
    return res.json {
      success: false
      message: message
      csrf: csrf_token
    }
  
  res.render "landing/error", {
    js: req.js.renderTags "modal"
    css: req.css.renderTags "modal"
    error: """
    An error has occurred 😱 but don't fret, our team has been notified.
    """
  }
  