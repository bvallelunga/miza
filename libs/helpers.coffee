moment = require "moment"

module.exports.date_string = (date)->
  return [
    date.getFullYear()
    date.getMonth()+1
    date.getDate()
  ].join "-"


module.exports.past_date = (range, date)->
  range_at = if date? then new Date(date) else new Date()
  moment_ob = moment(range_at)
  
  if range == "week"
    moment_ob = moment_ob.isoWeekday(1).startOf('isoweek')
    
  else if range == "month+1"
    moment_ob = moment_ob.startOf("month").add(1, "month")
    
  else
    moment_ob = moment_ob.startOf(range)
  
  return moment_ob.toDate()