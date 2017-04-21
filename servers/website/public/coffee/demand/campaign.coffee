class Dashboard

  charts: {}
  $tables: []
  $search: null
  
  
  constructor: ->
    @$search = $(".display .search-box input")
    @$table = $(".display.industries .table-body table").show()
  
    @bindings()
    @build_charts()
    @update()
    
  
  bindings: ->
    campaign = @
  
    @$search.keyup =>
      @data_table.column(1).search(@$search.val()).draw()
      
    
    $(".display").each ->
      $display = $(@)
      action_url = $display.find(".actions").data("url")
      
      $table = campaign.build_table $display
    
      $display.find(".actions .action").click (e)=>  
        action = $(e.currentTarget).data("action")
        confirm_text = $(e.currentTarget).data("confirm")
        selected = []
        
        if confirm_text? and not confirm(confirm_text)
          return
        
        if $table?
          selected = $.makeArray $table.column(0).checkboxes.selected()
          
          if selected.length == 0 then return
        
        $spinner = $(e.currentTarget).find(".fa-spin").show()
        $original = $(e.currentTarget).find(":not(.fa-spin)").hide() 
        
        $.post(action_url, {
          _csrf: config.csrf
          action: action
          selected: selected
        }).done ->
          if $table?
            $spinner = $(e.currentTarget).find(".fa-spin").hide()
            $original = $(e.currentTarget).find(":not(.fa-spin)").show() 
            return campaign.update()
          
          window.location.reload()
          
        .fail (error)->
          $spinner.hide()
          $original.show()
          message = error.responseJSON.message
          
          $(".container").prepend(
            "<div class='warning orange'>#{message}</div>"
          )
          
          window.scrollTo(0,0);
     
    
  build_table: ($display)->  
    if not $display.hasClass "table"
      return null
      
    $table = $display.find(".table-body table").show()
    $data_table = $table.DataTable({
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
      "columns": $.makeArray $table.data("columns")
    })
    
    @$tables.push [$table, $data_table]
    return $data_table
    
    
  
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
                console.log x
                return if parseInt(x) == x then numeral(x).format("1a") else null
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
    @$tables.forEach (tables)->
      $.get(tables[0].data("url")).done (response)=>
        if not response.success
          return
        
        tables[1].clear() 
        tables[1].rows.add(response.results)
        tables[1].draw()    
  
  
    $.get("/demand/#{config.advertiser}/campaign/#{config.campaign}/charts").done (response)=>
      for name, data of response
        chart = @charts[name]
        
        chart.data(data[0]).call(->
          ds2 = Keen.Dataset.parser('interval')(data[1])
          this.dataset.appendColumn('Clicks', ds2.selectColumn(1).slice(1))
        ).labels(["Impressions", "Clicks"]).render()



$ ->
  if not $(".container").hasClass "campaign-dashboard"
    return

  dashboard = new Dashboard()