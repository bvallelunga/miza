$ ->
  $views = $("input.views")
  $visits = $("input.visits")
  $units = $("input.units")
  $protection = $("input.protection")
  $ctr = $("input.ctr")
  $cpc = $("input.cpc")
  $commission = $("input.commission")
  $fee = $("input.fee")
  
  $(".container").on "keypress keyup keydown", "input", ->
    views = Number($views.val() or 0)
    visits = Number($visits.val() or 5)
    units = Number($units.val() or 2)
    protection = Number($protection.val() or 20)/100
    ctr = Number($ctr.val() or 0.1)/100
    cpc = Number($cpc.val() or 0.5)
    commission = Number($commission.val() or 3)/100
    fee = Number($fee.val() or 40)/100
  
    impressions = views * visits * units
    miza_impression = impressions * protection
    total_revenue = miza_impression * ctr * cpc
    miza_revenue = total_revenue * fee
    miza_commission = miza_revenue * commission
    
    $(".page-views .value").text numeral(views * visits).format "0,000"
    $(".total-impressions .value").text numeral(impressions).format "0,000"
    $(".miza-impressions .value").text numeral(miza_impression).format "0,000"
    $(".total-revenue .value").text numeral(total_revenue).format "$0,000"
    $(".miza-revenue .value").text numeral(miza_revenue).format "$0,000"
    $(".commission .value").text numeral(miza_commission).format "$0,000"