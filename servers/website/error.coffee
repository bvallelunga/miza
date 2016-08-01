module.exports = (err, req, res, next)->
  message = err.message or err
  
  if err.code == 'EBADCSRFTOKEN'
    message = "Invalid CSRF token!"
    
  console.log err
    
  res.status(403).json {
    success: false
    message: message
  }