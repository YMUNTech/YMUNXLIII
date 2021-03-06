# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

hideAlert = ->
  $('.alert-success').delay(6000).slideUp()

window.successAlert = (msg) ->
  $('#alert-success').text(msg).removeClass('hidden').show()
  hideAlert()
  $("html, body").animate({ scrollTop: 0 }, "fast");

window.dangerAlert = (msg) ->
  $('#alert-danger').text(msg).removeClass('hidden').show()
  $("html, body").animate({ scrollTop: 0 }, "fast");

$(document).ready ->
  $('.chosen-select').chosen()

  $('.add-one').click (e) ->
    e.preventDefault()
    duplicatableGroup = $('.duplicatable').last().parents('.form-group').clone().show()
    duplicatableGroup.insertBefore($(this).parent())
    duplicatableGroup.find('.duplicatable').each ->
      duplicatable = $(this)
      name = duplicatable.attr('name').replace /\[([0-9]+)]/, (str, index) ->
        "[#{parseInt(index) + 1}]"
      duplicatable.attr('name', name)
    duplicatableGroup.find('a.delete').click ->
      form_group = $(this).closest('.form-group')
      index = form_group.data('index')
      form_group.find('.should-delete').val(true)
      form_group.slideUp();
      false
    false

  $('input.other').each ->
    $this = $(this)
    if $this.attr('disabled')
      $this.hide()

  $('select.with-other').change (e) ->
    $this = $(this);
    input = $("input[name='#{$this.attr('name')}']")
    if ($(this).val() == 'other')
      input.attr('disabled', false).show()
    else
      input.attr('disabled', true).hide()
  .each ->
    $this = $(this);
    $this.val('other') if $this.attr('value') == 'other'

  if eurButton = $('#eur-button')
    usdButton = $('#usd-button')

    # payment page!
    if eurButton.hasClass 'active'
      # hide the EUR table
      $('#payment-usd').hide()
    else
      $('#payment-eur').hide()

    $('.payment-type-button').click ->
      paymentType = $(this).attr('data-payment-type')
      $('.payment-type-button').removeClass('active')
      $(this).addClass('active')
      $.getJSON('/delegation/change_payment_type.json', {payment_type: paymentType}, (data) ->
        if data.success
          successAlert('Payment method was successfully changed!')
        else
          dangerAlert('Something went wrong! Please try again in a little while.')
      )

    unless eurButton.hasClass('disabled')
      usdButton.click ->
        $('#payment-usd').show()
        $('#payment-eur').hide()
        usdButton.addClass('active')
        eurButton.removeClass('active')
        $('#pay-with-paypal').show()
        $.getJSON('/delegation/change_payment_currency.json', {currency: 'usd'}, (data) ->
          if data.success
            successAlert('Currency successfully changed to USD!')
          else
            dangerAlert('Something went wrong! Please try again in a little while.')
        )


      eurButton.click ->
        $('#payment-eur').show()
        $('#payment-usd').hide()
        eurButton.addClass('active')
        usdButton.removeClass('active')
        $('#pay-with-paypal').hide()
        $.getJSON('/delegation/change_payment_currency.json', {currency: 'eur'}, (data) ->
          if data.success
            successAlert('Currency successfully changed to EUR!')
          else
            dangerAlert('Something went wrong! Please try again in a little while.')
        )

  $('#payment-submit').click (e) ->
    e.preventDefault()
    $this = $(this)
    form = $this.parents('form')
    if form.find('input:checked').length
      $this.text('Please Wait...')
      form.submit()
    else
      dangerAlert('Please select a payment option or amount.')

  $('a.disabled').each( ->
    if because = $(this).data('disabled-because')
      $(this).tooltip
        title: because,
        trigger: 'hover',
        placement: 'auto',
        container: 'body',
        delay: { show: 500, hide: 100 }
  ).click (e) ->
    e.preventDefault()
    false

  $('.fake-save').click ->
    $this = $(this)
    text = $this.text()
    $this.text('Please wait...')
    setTimeout( ->
      $this.text(text)
      successAlert('All information saved!')
    , 500)

  # $('.advisors-form .form-group').hover ->
  #   $(this).find('a.delete-advisor').animate({left: -100});
  # , ->
  #   $(this).find('a.delete-advisor').animate({left: 0});

  $('a.delete').click ->
    form_group = $(this).closest('.form-group')
    index = form_group.data('index')
    form_group.find('.should-delete').val(true)
    form_group.slideUp();
    false

  hideAlert()

String.prototype.capitalize = ->
  this.charAt(0).toUpperCase() + this.slice(1);
