class Dashboard

  charts: {}
  $table: null
  data_table: null
  $search: null
  
  
  constructor: ->
    @$search = $(".display .search-box input")
    @$table = $(".display .table-body table").show()
  
    @bindings()
    @build_table()
    @build_charts()
    @update()
    
  
  bindings: ->
    @$search.keyup =>
      @data_table.column(1).search(@$search.val()).draw()
      
    $(".campaign.actions .action").click (e)=>    
      $spinner = $(e.currentTarget).find(".fa-spin").show()
      $original = $(e.currentTarget).find(":not(.fa-spin)").hide()  
      
      $.post("/demand/#{config.advertiser}/campaign/#{config.campaign}", {
        _csrf: config.csrf
        action: $(e.currentTarget).data("action")
      }).done ->
        window.location.reload()
        
      .fail (error)->
        $spinner.hide()
        $original.show()
        message = error.responseJSON.message
        
        $(".container").prepend(
          "<div class='warning orange'>#{message}</div>"
        )
        
        window.scrollTo(0,0);
     
    $(".industries.actions:not(.disabled) .action").click (e)=>
      industries = $.makeArray @data_table.column(0).checkboxes.selected()
      
      if industries.length == 0
        return
        
      $spinner = $(e.currentTarget).find(".fa-spin").show()
      $original = $(e.currentTarget).find(":not(.fa-spin)").hide()
      
      $.post("/demand/#{config.advertiser}/campaign/#{config.campaign}/industries", {
        _csrf: config.csrf
        action: $(e.currentTarget).data("action")
        industries: industries
      }).done =>
        $spinner.hide()
        $original.show()
        @update()
        
      .fail (error)->
        $spinner.hide()
        $original.show()
        message = error.responseJSON.message
        
        $(".container").prepend(
          "<div class='warning orange'>#{message}</div>"
        )
        
        window.scrollTo(0,0);
    
    
  build_table: ->
    @data_table = @$table.DataTable({
      "paging":   false
      "ordering": false
      "order":    false
      "info":     false
      "search":   false
      "bSort":    false
      'columnDefs': [{
        'targets': 0,
        'checkboxes': {
          'selectRow': true
        }
      }]
      "columns": [
        { "data": "id" },
        { "data": "name" },
        { "data": "status" },
        { "data": "metrics.progress" },
        { "data": "metrics.impressions" },
        { "data": "metrics.clicks" }
        { "data": "metrics.ctr" }
        { "data": "metrics.cpm" },
        { "data": "metrics.budget" },
        { "data": "metrics.spend" }
      ]
    })
    
  
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
                return if parseInt(x) == x then x else null
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
        
  
  update: ->
    @data_table.clear() 
  
    $.get("/demand/#{config.advertiser}/campaign/#{config.campaign}/industries").done (response)=>
      if not response.success
        return
        
      @data_table.rows.add(response.results)
      @data_table.draw()    
  
    $.get("/demand/#{config.advertiser}/campaign/#{config.campaign}/charts").done (response)=>
      for name, data of response
        chart = @charts[name]
                
        if data.success
          chart.data(data.result).render()
        
        else 
          chart.message(data.error)



$ ->
  if not $(".container").hasClass "campaign-dashboard"
    return

  dashboard = new Dashboard()