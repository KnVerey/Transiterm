$(document).ready ->
	if $('#notice').length then slideFlash($('#notice'))
	if $('#alert').length then slideFlash($('#alert'))
	if $('#success').length then slideFlash($('#success'))

	$('.record-expander').click(toggleRecordExpand)
	$('.record-minimizer').click(toggleRecordExpand)
	$('#delete-link').click(->
		confirm("Are you sure? Deletion can't be undone!"))

slideFlash = (target) ->
	$(target).animate({top: 30}, 800)
	setTimeout((->
		$(target).animate({top: -100}, 800)
  ), 3000)

toggleRecordExpand = () ->
	$(this).parents('tr').next('.record-expand').toggleClass("hide")
	$($(this).siblings('.fa')[0]).toggleClass("hide")
	$(this).toggleClass("hide")