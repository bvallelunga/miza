class ReportsDashboard

  metrics: (range)->
    from_date = @past_date range
    to_date = moment()
    @clear_metrics()

    Promise.props({
      impressions: @metric 'ADS.EVENT.Impression', from_date, to_date, true   
      clicks: @metric 'ADS.EVENT.Click', from_date, to_date, true
      protected_pings: @metric 'ADS.EVENT.Ping', from_date, to_date, true   
      all_pings: @metric 'ADS.EVENT.Ping', from_date, to_date, false       
    }).then (props)->
      return Promise.map config.publishers, (publisher)->      
        values = {
          impressions: props.impressions[publisher.id] or 0
          clicks: props.clicks[publisher.id] or 0
          protected_pings: props.protected_pings[publisher.id] or 0
          all_pings: props.all_pings[publisher.id] or 0
        }

        values.revenue = values.impressions/1000 * publisher.industry.cpm
        values.owe = values.revenue * publisher.industry.fee
        
        $publisher = $("tr.#{publisher.key}")
        $publisher.find(".protected").text numeral(values.protected_pings/(values.all_pings or 1)).format("0%")
        $publisher.find(".revenue").text numeral(values.revenue).format("$0[,]000a")
        $publisher.find(".owed").text numeral(values.owe).format("$0[,]000a")
        
        return values
    
    .then (publishers)->
      totals = {
        clicks: 0
        impressions: 0
        owe: 0
        revenue: 0
        protected_pings: 0
        all_pings: 0
      }
    
      for publisher in publishers    
        totals.clicks += publisher.clicks
        totals.impressions += publisher.impressions
        totals.owe += publisher.owe
        totals.revenue += publisher.revenue
        totals.all_pings += publisher.all_pings
        totals.protected_pings += publisher.protected_pings
        
      $(".impressions-metric").html numeral(totals.impressions).format("0[.]0a")
      $(".clicks-metric").html numeral(totals.clicks).format("0[.]0a")
      $(".owed-metric").html numeral(totals.owe).format("$0[,]000[.]00a")
      $(".revenue-metric").html numeral(totals.revenue).format("$0[,]000.00a")
      $(".protected-metric").html numeral(totals.protected_pings/(totals.all_pings or 1)).format("0%")
      
    
    
  metric: (event, from_date, to_date, is_protected)->
    MP.api.segment(event, 'Publisher ID', {
      from: from_date
      to: to_date
      unit: "month"
      method: "numeric"
      where: if is_protected then 'properties["Protected"] == true' else null
    }).then (results)->
      publishers = results.values()
    
      for key, days of publishers
        publishers[key] = Object.keys(days).map (day)->
          return days[day]
          
        .reduce ((total, item) -> total + item), 0
      
      return publishers
    

  past_date: (range)->
    if range == "week"
      return moment().isoWeekday(1).startOf('isoweek')
    
    return moment().startOf(range)


  clear_metrics: ->
    $(".impressions-metric").html "&nbsp;"
    $(".clicks-metric").html "&nbsp;"
    $(".owed-metric").html "&nbsp;"
    $(".revenue-metric").html "&nbsp;"
    $(".protected-metric").html "&nbsp;"
    $("tr.publisher .data").text ""

  
$ ->
  MP.api.setCredentials config.mixpanel_secret
  dashboard = new ReportsDashboard()
  dashboard.metrics $(".range-toggle .active").data("range")
  
  $(".range-toggle div").click ->
    $(".range-toggle div").removeClass "active"
    $(this).addClass "active"
    dashboard.metrics $(".range-toggle .active").data("range")

