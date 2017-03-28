$ ->
  $(".slider-range").each ->
    $slider = $(this)
    $input = $slider.parents(".slider").find(".slider-input")
    $display = $slider.parents(".slider").find(".slider-display.value")
    $display_leftover = $slider.parents(".slider").find(".slider-display.leftover")
    display_rules = {}
    
    $display.data("rules").split(",").forEach (rule)->
      parts = rule.split(":")
      display_rules[parts[0]] = parts[1] 
    
    noUiSlider.create this, {
    	start: [ Number($slider.data("value")) ]
    	step: Number $slider.data("step") or 1
    	connect: 'lower'
    	range: {
    		'min': [ Number($slider.data("min")) ]
    		'max': [ Number($slider.data("max")) ]
    	}
    }
    
    this.noUiSlider.on 'update', (values, handle)->
      value = Number values[handle]
      $input.val values[handle]
      $display.text display_rules[value] or (($display.data("prefix") or "") + Math.floor(value) + ($display.data("postfix") or ""))
      $display_leftover.text ($display.data("prefix") or "") + Math.floor(100 - value) + ($display.data("postfix") or "")
