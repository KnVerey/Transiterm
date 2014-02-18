$(document).ready ->
	if $('#notice').length then slideFlash($('#notice'))
	if $('#alert').length then slideFlash($('#alert'))
	if $('#success').length then slideFlash($('#success'))

	$('.no-js-hidden').css("display", "inline-block")

slideFlash = (target) ->
	$(target).animate({top: 30}, 800)
	setTimeout((->
		$(target).animate({top: -100}, 800)
  ), 3000)