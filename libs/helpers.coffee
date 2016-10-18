moment = require "moment"

module.exports.date_string = (date)->
  return [
    date.getFullYear()
    date.getMonth()+1
    date.getDate()
  ].join "-"


module.exports.capitalize = (string)->
  return string.charAt(0).toUpperCase() + string.slice(1)


module.exports.past_date = (range, date, increment=0, time="start")->
  if range == "yesterday"
    range = "day"
    increment = -1

  range_at = if date? then new Date(date) else new Date()
  moment_ob = moment(range_at).add(increment, range)
  
  if range == "week"
    moment_ob = moment_ob.isoWeekday(1)["#{time}Of"]('isoweek')
    
  else
    moment_ob = moment_ob["#{time}Of"](range)
  
  return moment_ob.toDate()