$.fn.fade = (time) -> this.fadeOut time

jQuery ->
  $('.container').on 'click', '.add-data', (event) ->
    $this = $(this)
    $.ajax
      url: $this.data('path')
      dataType: "html"
      success: (data, textStatus, jqXHR) ->
        $($this).parent().after($(data).find("#collection"))