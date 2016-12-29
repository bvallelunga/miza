$ ->
  $(".slider-range").each ->
    $slider = $(this)
    $input = $slider.parents().find(".slider-input")
    $display = $slider.parents().find(".slider-display.value")
    $display_leftover = $slider.parents().find(".slider-display.leftover")
    
    noUiSlider.create this, {
    	start: [ Number($slider.data("value")) ]
    	step: 1
    	connect: 'lower'
    	range: {
    		'min': [ Number($slider.data("min")) ]
    		'max': [ Number($slider.data("max")) ]
    	}
    }
    
    this.noUiSlider.on 'update', (values, handle)->
    	$input.val values[handle]/100
    	$display.text Math.floor(values[handle]) + "%"
    	$display_leftover.text Math.floor(100 - values[handle]) + "%"
