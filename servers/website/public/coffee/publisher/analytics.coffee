class Dashboard 

  client: null
  collection: "ads.event"
  timeframe: {}
  charts: {}
  
  
  constructor: ->
    @client = new Keen config.keen
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
              #format: d3.format(".2s")
            }
          }
        }
        point: {
          show: false
        }
        tooltip: {
          format: {
            name: (name, ratio, id, index)-> "Impressions"
          }
        }
      })
      .prepare()
  
    # Impression Chart
    @charts.impression_count = new Keen.Dataviz()
      .el('.chart.impression-count')
      .height(200)
      .title('Impressions')
      .type('metric')
      .colors([ '#3edf86' ])
      .prepare()
      
    # Click Count
    @charts.click_count = new Keen.Dataviz()
      .el('.chart.click-count')
      .height(200)
      .title('Clicks')
      .type('metric')
      .colors(['#8A8AD6'])
      .prepare()
      
    
    # Views Count
    @charts.view_count = new Keen.Dataviz()
      .el('.chart.visitors-count')
      .height(200)
      .title('Page Views')
      .type('metric')
      .colors(['#EEB058'])
      .prepare()
      
      
    # Protection Rate
    @charts.protection_count = new Keen.Dataviz()
      .el('.chart.protection-count')
      .height(200)
      .title('Ad Blocker (%)')
      .type('metric')
      .colors(['#FE6672'])
      .prepare()
      
      
    # Browsers Chart
    @charts.browsers_chart = new Keen.Dataviz()
      .el('.chart.browsers')
      .height(250)
      .type('donut')
      .title("Browsers")
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
      .type('donut')
      .title("Operating Systems")
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
    $.get("/publisher/#{config.publisher}/analytics/metrics", {
      timeframe: timeframe
    }).done (response)=>
      for name, data of response
        chart = @charts[name]
                
        if data.success
          chart.data(data.result).render()
        
        else 
          chart.message(data.error)
    
      finished()
  

$ ->
  dashboard = new Dashboard()
  
  Keen.ready ->
    new DatePicker ".analytics-dashboard", (start, end, finished)->
      dashboard.update {
        start: start
        end: end
      }, finished