class Dashboard

  $industry_options: []
  $selection_table: null
  $selection_empty: null

  constructor: ->
    @$pricing_select = $(".pricing-input select")
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
      
    _this.$pricing_select.change ->
      _this.model_selected $(@)
     
    $(".industries .selection-shortcut").click ->
      _this.option_selected _this.$industry_options, true
      
    $(".is-house").change ->
      _this.$selection_table.find("input.dynamic").each ->
        _this.impressions_updated $(@)
    
    _this.$selection_table.on "keyup change", "input.dynamic", ->
      _this.impressions_updated $(@)
      
  
  total_cost_update: ->
    total = 0
    is_house = $(".is-house").val() == "true"
    model = @$pricing_select.val()
    
    $(".selection .option.active").each ->
      $industry = $(".section.#{model} .industry_#{$(@).data("value")}")
      COST = numeral($industry.find(".amount").val()).value()
      AMOUNT = numeral($industry.find("input.quantity").val()).value()
      
      if $industry.data("model") == "cpm"
        AMOUNT = AMOUNT/1000
      
      total += if is_house then 0 else (COST * AMOUNT)
      $(".quote-box .quote").text numeral(total).format("$0,000.00")     

  
  impressions_updated: ($select)->
    is_house = $(".is-house").val() == "true"
    
    $industry = $select.parents("tr")
    COST = numeral($industry.find(".amount").val()).value()
    AMOUNT = numeral($industry.find("input.quantity").val()).value()
    
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
    model = @$pricing_select.val()
    
    $(".selection .option").each ->
      $option = $(@)
      value = $option.hasClass("active")
      $(".industry_#{$option.data("value")}").toggle value
      $industry = $(".section.#{model} .industry_#{$option.data("value")}")
      $industry.find(".activated_input").val value
      $industry.find("input.dynamic").attr "required", value
      
    @total_cost_update()
    
  
  model_selected: ($option)->
    model = $option.val()
    $(".model_table").hide().find("input.dynamic").attr "required", false
    $(".model_table .activated_input").val false
    $(".model_table.#{model}").show()
    
    $(".selection .option").each ->
      $option = $(@)
      value = $option.hasClass("active")
      $industry = $(".section.#{model} .industry_#{$option.data("value")}")
      $industry.find(".activated_input").val value
      $industry.find("input.dynamic").attr "required", value
    
    $(".industries.section .selection .option").each ->
      $option = $(@)
      $option.find(".metric span").text model.toUpperCase()
      $option.find(".metric cost").text $option.data(model)
    
    @total_cost_update()


$ ->
  if not $(".container").hasClass "campaigns-builder-dashboard"
    return

  dashboard = new Dashboard()