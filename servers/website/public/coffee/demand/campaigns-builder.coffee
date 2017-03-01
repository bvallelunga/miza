class Dashboard

  $channel_options = []
  $impressions_table = null
  $impressions_empty = null

  constructor: ->
    $channel_options = $(".selection .option")
    $impressions_table = $(".impressions_table")
    $impressions_empty = $(".impressions_empty")
    @bind()
  
  bind: ->
    _this = @
  
    $(".range-display").each ->
      $(this).dateRangePicker({
        container: ".container .display"
        showShortcuts: false
        showTopbar: false
        autoClose: true
        singleDate : true
        singleMonth: true
        format: 'MM-DD-YYYY'
        startOfWeek: 'monday'
        language:'en'
        startDate: moment().format('MM-DD-YYYY')
        extraClass: "date-dropdown"
      })
      
    $channel_options.click ->
      _this.option_selected $(@)
      
     
    $(".selection-shortcut").click ->
      _this.option_selected $channel_options, true


  option_selected: ($options, force=null)->
    $options.toggleClass "active", force
    show_table = $channel_options.filter(".active").length > 0
    $impressions_table.toggle show_table
    $impressions_empty.toggle not show_table
    
    $(".selection .option").each ->
      $option = $(@)
      $industry = $("#industry_#{$option.data("value")}")
      $industry.toggle $option.hasClass("active")


$ ->
  if not $(".container").hasClass "campaigns-builder-dashboard"
    return

  dashboard = new Dashboard()