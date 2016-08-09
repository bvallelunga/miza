$ ->
  $(".form.card").card({
    container: '.card-wrapper'
    placeholders: {
      number: '**** **** **** ****',
      name: 'Tony Stark',
      expiry: '** / ****',
      cvc: '***'
    }
  });