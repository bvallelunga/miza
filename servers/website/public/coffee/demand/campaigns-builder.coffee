class Dashboard

  $industry_options: []
  $impressions_table: null
  $impressions_empty: null

  constructor: ->
    @$industry_options = $(".selection .option")
    @$impressions_table = $(".impressions_table")
    @$impressions_empty = $(".impressions_empty")
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
      
    _this.$industry_options.click ->
      _this.option_selected $(@)
     
    $(".selection-shortcut").click ->
      _this.option_selected _this.$industry_options, true
      
    $(".is-house").change ->
      _this.$impressions_table.find("input").each ->
        _this.impressions_updated $(@)
    
    @$impressions_table.find("input").keyup ->
      _this.impressions_updated $(@)
      
  
  total_cost_update: ->
    total = 0
    is_house = $(".is-house").val() == "true"
    
    $(".selection .option.active").each ->
      $industry = $("#industry_#{$(@).data("value")}")
      CPM = numeral($industry.data("cpm")).value()
      IMPRESSIONS = numeral($industry.find("input.number").val()).value()
      total += if is_house then 0 else (CPM * (IMPRESSIONS/1000))
      $(".quote-box .quote").text numeral(total).format("$0,000.00")     

  
  impressions_updated: ($select)->
    is_house = $(".is-house").val() == "true"
    
    $tr = $select.parents("tr")
    CPM = numeral($tr.data("cpm")).value()
    IMPRESSIONS = numeral($select.val()).value()
    COST = if is_house then 0 else (CPM * (IMPRESSIONS/1000))
    $tr.find(".total").text numeral(COST).format("$0,000.00")    
    @total_cost_update()
  
  
  option_selected: ($options, force=null)->
    $options.toggleClass "active", force
    show_table = @$industry_options.filter(".active").length > 0
    @$impressions_table.toggle show_table
    @$impressions_empty.toggle not show_table
    
    $(".selection .option").each ->
      $option = $(@)
      value = $option.hasClass("active")
      $industry = $("#industry_#{$option.data("value")}")
      $industry.toggle value
      $industry.find(".activated_input").val value
      $industry.find("select").attr "required", value
      
    @total_cost_update()


$ ->
  if not $(".container").hasClass "campaigns-builder-dashboard"
    return

  dashboard = new Dashboard()