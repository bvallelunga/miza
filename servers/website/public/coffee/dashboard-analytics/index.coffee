$ ->
  if $(".display").hasClass "analytics-dashboard"
    analyticsMetrics()
    analyticsLogs()
    
  if $(".display").hasClass "billing-dashboard"
    billingMetrics()
    billingLogs()


billingMetrics = ->
  $.get("#{location.pathname}/metrics", {
    date: new Date()
  }).done (reports)-> 
    if reports.all.length == 0
      $(".billing-table .loading").remove()
      
    $(".billing-table .loading td").text "" 
    $(".owed-metric").text reports.totals.owed   
    $(".billing-table tbody").prepend reports.all.map (report)->
      return $("""
        <tr>
          <td>#{moment(report.created_at).format("MMM Do, YYYY")}</td>
          <td>#{report.impressions}</td>
          <td>#{report.cpm}</td>
          <td>#{report.impressions_owed}</td>
        </tr>
      """)
  

billingLogs = ->
  $.get("#{location.pathname}/logs", {
    date: new Date()
  }).done (logs)->
    now = new Date()
    
    $(".logs-table-message")
      .toggle(logs.length == 0)
      .text "We don't have any logs yet for your account."
    
    $(".logs-table tbody").html logs.map (log)->          
      return $("""
        <tr class="#{ log.status }">
          <td>#{log.id}</td>
          <td>#{log.amount}</td>
          <td>#{log.status}</td>
          <td>#{log.card.brand} #{log.card.last4}</td>
          <td>#{moment(log.created).format("MMM Do, YYYY")}</td>
        </tr>
      """)


analyticsMetrics = ->
  $.get("#{location.pathname}/metrics", {
    date: new Date()
  }).done (metrics)->
    $(".ctr-metric").text metrics.ctr
    $(".impressions-metric").text metrics.impressions
    $(".clicks-metric").text metrics.clicks
    $(".views-metric").text metrics.views
    $(".blocked-metric").text metrics.blocked
  

analyticsLogs = ->
  $.get("#{location.pathname}/logs", {
    date: new Date()
  }).done (logs)->
    now = new Date()
    
    $(".logs-table-message")
      .toggle(logs.length == 0)
      .text "We don't have any logs yet for your account."
    
    $(".logs-table tbody").html logs.map (log)->
      created = new Date log.created_at
          
      return $("""
        <tr>
          <td>#{log.type}</td>
          <td>#{log.network_name or ""}</td>
          <td>#{log.browser}</td>
          <td>#{log.os}</td>
          <td>#{moment.duration(created - now).humanize(true)}</td>
        </tr>
      """)