class Dashboard

  $industry_options: []
  $selection_table: null
  $selection_empty: null

  constructor: ->
    @$model_options = $(".models .selection .option")
    @$industry_options = $(".industries .selection .option")
    @$selection_table = $(".selection_table")
    @$selection_empty = $(".selection_empty")
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
      
    _this.$model_options.click ->
      _this.model_selected $(@)
     
    $(".industries .selection-shortcut").click ->
      _this.option_selected _this.$industry_options, true
      
    $(".is-house").change ->
      _this.$selection_table.find("input.number").each ->
        _this.impressions_updated $(@)
    
    _this.$selection_table.find("input.number").keyup ->
      _this.impressions_updated $(@)
      
  
  total_cost_update: ->
    total = 0
    is_house = $(".is-house").val() == "true"
    model = $("input.model").val()
    
    $(".selection .option.active").each ->
      $industry = $(".section.#{model} .industry_#{$(@).data("value")}")
      COST = numeral($industry.data("amount")).value()
      AMOUNT = numeral($industry.find("input.number").val()).value()
      
      if $industry.data("model") == "cpm"
        AMOUNT = AMOUNT/1000
      
      total += if is_house then 0 else (COST * AMOUNT)
      $(".quote-box .quote").text numeral(total).format("$0,000.00")     

  
  impressions_updated: ($select)->
    is_house = $(".is-house").val() == "true"
    
    $industry = $select.parents("tr")
    COST = numeral($industry.data("amount")).value()
    AMOUNT = numeral($industry.find("input.number").val()).value()
    
    if $industry.data("model") == "cpm"
      AMOUNT = AMOUNT/1000
      
    BUDGET = if is_house then 0 else (COST * AMOUNT)
    $industry.find(".total").text numeral(BUDGET).format("$0,000.00")    
    @total_cost_update()
  
  
  option_selected: ($options, force=null)->
    $options.toggleClass "active", force
    show_table = @$industry_options.filter(".active").length > 0
    @$selection_table.toggle show_table
    @$selection_empty.toggle not show_table
    model = $("input.model").val()
    
    $(".selection .option").each ->
      $option = $(@)
      value = $option.hasClass("active")
      $industry = $(".section.#{model} .industry_#{$option.data("value")}")
      $industry.toggle value
      $industry.find(".activated_input").val value
      $industry.find("input.number").attr "required", value
      
    @total_cost_update()
    
  
  model_selected: ($option)->
    model = $option.data("value")
    @$model_options.toggleClass "active", false
    $option.toggleClass "active", true
    debugger
    $(".model_table").hide().find(".selection .option input.number").attr "required", false
    $(".model_table.#{model}").show().find(".selection .option input.number").attr "required", true
    $("input.model").val(model)
    
    $(".industries.section .selection .option").each ->
      $option = $(@)
      $option.find(".metric span").text model.toUpperCase()
      $option.find(".metric cost").text $option.data(model)
    
    @total_cost_update()


$ ->
  if not $(".container").hasClass "campaigns-builder-dashboard"
    return

  dashboard = new Dashboard()