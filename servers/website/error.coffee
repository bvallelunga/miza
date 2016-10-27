module.exports = (err, req, res, next)->
  message = err.message or err
  csrf_token = ""
  send_bug = true
  
  if req.csrfToken?
    csrf_token = req.csrfToken()
  
  if err.code == 'EBADCSRFTOKEN'
    message = "Invalid CSRF token!"
    send_bug = false
    
  if err.errors?
    message = err.errors.map (error)->
      if error.type == "unique violation"
        send_bug = false
        return "#{error.path} is already in use"
      
      return error.message
    
    .join "\n"

  if send_bug
    if CONFIG.is_prod
      LIBS.bugsnag.notify err
    
    else
      console.error err.stack or err
  
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
  