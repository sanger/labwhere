# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

nextID = (association) ->
  $("ul[id^=" + association + "]").children("li").length

jQuery ->
  $('form').on 'click', '.add_fields', (event) ->
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).parent().before($(this).data('fields').replace(regexp, nextID($(this).data('association'))))
    event.preventDefault()

  $('form').on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('li').hide()
    event.preventDefault()
