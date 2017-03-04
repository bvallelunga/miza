class Dashboard

  $industry_options = []
  $impressions_table = null
  $impressions_empty = null

  constructor: ->
    $industry_options = $(".selection .option")
    $impressions_table = $(".impressions_table")
    $impressions_empty = $(".impressions_empty")
    @bind()
  
  bind: ->
    _this = @
  
    $(".range-display").each ->
      $(@).dateRangePicker({
        container: ".container .display"
        showShortcuts: false
        showTopbar: false
        autoClose: true
        singleDate : true
        singleMonth: true
        format: 'MM-DD-YYYY'
        startOfWeek: 'monday'
        language:'en'
        startDate: $(@).data("start-date")
        extraClass: "date-dropdown"
      })
      
    $industry_options.click ->
      _this.option_selected $(@)
      
     
    $(".selection-shortcut").click ->
      _this.option_selected $industry_options, true
    
    $impressions_table.find("select").change ->
      _this.impressions_updated $(@)

  
  impressions_updated: ($select)->
    $tr = $select.parents("tr")
    CPM = Number $tr.data("cpm")
    IMPRESSIONS = Number $select.val()
    $tr.find(".total").text numeral(CPM * (IMPRESSIONS/1000)).format("$0,000")
  
  
  option_selected: ($options, force=null)->
    $options.toggleClass "active", force
    show_table = $industry_options.filter(".active").length > 0
    $impressions_table.toggle show_table
    $impressions_empty.toggle not show_table
    
    $(".selection .option").each ->
      $option = $(@)
      value = $option.hasClass("active")
      $industry = $("#industry_#{$option.data("value")}")
      $industry.toggle value
      $industry.find(".activated_input").val value
      $industry.find("select").attr "required", value


$ ->
  if not $(".container").hasClass "campaigns-builder-dashboard"
    return

  dashboard = new Dashboard()