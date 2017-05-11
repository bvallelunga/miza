class Dashboard 

  timeframe: {}
  charts: {}
  
  
  constructor: ->
    @build_charts()
    
  
  build_charts: ->
    # Impressions Chart
    @charts.impressions_chart = new Keen.Dataviz()
      .el('.chart.impressions')
      .height(250)
      .type('area-spline')
      .title(" ")
      .chartOptions({
        axis: {
          x: {
            inner: false
            type: 'timeseries'
            tick: {
              outer: false
              format: '%m-%d'
            } 
          }
          y: {
            inner: false
            tick: {
              outer: false
              format: (x)-> 
                return if parseInt(x) == x then numeral(x).format("1[.]0a") else null
            }
          }
        }
        point: {
          show: true
        }
        legend: {
          show: false
        }
      })
      .prepare()
  
    # Impression Chart
    @charts.impression_count = new Keen.Dataviz()
      .el('.chart.impression-count')
      .height(180)
      .title('Impressions')
      .type('metric')
      .colors([ 'transparent' ])
      .theme("keen-dataviz-green")
      .prepare()
      
    # Click Count
    @charts.click_count = new Keen.Dataviz()
      .el('.chart.click-count')
      .height(180)
      .title('Clicks')
      .type('metric')
      .colors([ 'transparent' ])
      .theme("keen-dataviz-purple")
      .prepare()
      
    
    # Views Count
    @charts.view_count = new Keen.Dataviz()
      .el('.chart.visitors-count')
      .height(180)
      .title('Page Views')
      .type('metric')
      .colors([ 'transparent' ])
      .theme("keen-dataviz-orange")
      .prepare()
      
      
    # CTR Rate
    @charts.ctr_count = new Keen.Dataviz()
      .el('.chart.ctr-count')
      .height(180)
      .title('Click Rate')
      .type('metric')
      .colors([ 'transparent' ])
      .theme("keen-dataviz-purple")
      .chartOptions({ 
        suffix: "%" 
      })
      .prepare()
    
    
    # Fill Rate
    @charts.fill_count = new Keen.Dataviz()
      .el('.chart.fill-count')
      .height(180)
      .title('Fill Rate')
      .type('metric')
      .colors([ 'transparent' ])
      .theme("keen-dataviz-green")
      .chartOptions({ 
        suffix: "%" 
      })
      .prepare()
    
    
    # Protection Rate
    @charts.protection_count = new Keen.Dataviz()
      .el('.chart.protection-count')
      .height(180)
      .title('Ad Block Rate')
      .type('metric')
      .colors([ 'transparent' ])
      .theme("keen-dataviz-red")
      .chartOptions({ 
        suffix: "%" 
      })
      .prepare()
      
      
    # Browsers Chart
    @charts.browsers_chart = new Keen.Dataviz()
      .el('.chart.browsers')
      .height(250)
      .type('pie')
      .title("Ad Block Traffic by Browser")
      .chartOptions({
        size: {
          height: 220
        }
        legend: {
          position: "right"
        }
      })
      .prepare()
     
     
    # OS Chart
    @charts.os_chart = new Keen.Dataviz()
      .el('.chart.os')
      .height(250)
      .type('pie')
      .title("Ad Block Traffic by OS")
      .chartOptions({
        size: {
          height: 220
        }
        legend: {
          position: "right"
        }
      })
      .prepare()
      
    
    # Devices Chart
    @charts.devices_chart = new Keen.Dataviz()
      .el('.chart.devices')
      .height(250)
      .type('pie')
      .title("Ad Block Traffic by Device")
      .chartOptions({
        size: {
          height: 220
        }
        legend: {
          position: "right"
        }
      })
      .prepare()
      
    
    # Countries Chart
    @charts.countries_chart = new Keen.Dataviz()
      .el('.chart.countries')
      .height(250)
      .type('pie')
      .title("Ad Block Traffic by Country")
      .chartOptions({
        size: {
          height: 220
        }
        legend: {
          position: "right"
        }
      })
      .prepare()
  
  
  update: (timeframe, finished)->  
    max_start = moment().subtract(1, "hour").startOf("hour").toDate()
    max_end = moment().subtract(1, "hour").endOf("hour").toDate()
  
    if timeframe.start > max_start
      timeframe.start = max_start
    
    if timeframe.end > max_end
      timeframe.end = max_end
      
    timeframe.start = timeframe.start.toISOString()
    timeframe.end = timeframe.end.toISOString()
    
    $.get("/dashboard/supply/#{config.publisher}/analytics/metrics", {
      timeframe: timeframe
    }).done (response)=>
      for name, data of response
        chart = @charts[name]
                
        if data.success      
          if name == "impressions_chart"
            chart.data(data.result[0]).call(->
              ds2 = Keen.Dataset.parser('interval')(data.result[1])
              this.dataset.appendColumn('Clicks', ds2.selectColumn(1).slice(1))
            ).labels(["Impressions", "Clicks"]).render()
          
          else
            if data.result.result == null
              data.result.result = NaN
            
            chart.data(data.result).sortGroups("desc").render()
        
        else 
          chart.message(data.error)
    
      if finished? then finished()
  

$ ->
  if not $(".container").hasClass "analytics-dashboard"
    return
  
  dashboard = new Dashboard()
  
  Keen.ready ->
    dashboard.update {
      start: moment.utc().startOf("month").toDate()
      end: moment.utc().add(1, "day").startOf("day").toDate()
    }
#     new DatePicker ".analytics-dashboard", (dates, finished)->
#       dashboard.update dates, finished
