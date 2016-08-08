$ ->
  if $(".display").hasClass "analytics-dashboard"
    analyticsMetrics()
    analyticsLogs()
    
  if $(".display").hasClass "billing-dashboard"
    billingMetrics()
    billingLogs()


billingMetrics = ->
  $.get("#{location.pathname}/metrics").done (metrics)->
    $(".revenue-metric").text metrics.revenue
    $(".billed-metric").text moment(metrics.billed).format("MMM D")
    $(".cpm-metric").text metrics.cpm
    $(".owe-metric").text metrics.owe
    $(".fee-metric").text metrics.fee
  

billingLogs = ->
  $.get("#{location.pathname}/logs").done (logs)->
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
          <td>#{moment(log.created).format("MMM Do YYYY")}</td>
        </tr>
      """)


analyticsMetrics = ->
  $.get("#{location.pathname}/metrics").done (metrics)->
    $(".ctr-metric").text metrics.ctr
    $(".impressions-metric").text metrics.impressions
    $(".clicks-metric").text metrics.clicks
    $(".assets-metric").text metrics.assets
    $(".blocked-metric").text metrics.blocked
    setTimeout analyticsMetrics, 5000
  

analyticsLogs = ->
  $.get("#{location.pathname}/logs").done (logs)->
    now = new Date()
    setTimeout analyticsLogs, 5000
    
    $(".logs-table-message")
      .toggle(logs.length == 0)
      .text "We don't have any logs yet for your account."
    
    $(".logs-table tbody").html logs.map (log)->
      created = new Date log.created_at
          
      return $("""
        <tr class="#{ if log.protected then "protected" else "normal" }">
          <td>#{log.type}</td>
          <td>#{log.ad_network or ""}</td>
          <td>#{log.protected}</td>
          <td>#{log.ip_address}</td>
          <td>#{moment.duration(created - now).humanize(true)}</td>
        </tr>
      """)