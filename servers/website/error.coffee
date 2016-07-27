module.exports = (err, req, res, next)->
  message = err.message or err
  
  if err.code != 'EBADCSRFTOKEN'
    message = "Invalid csrf token!"
    
  res.status(403).json {
    success: false
    error: message
  }