jQuery ->
	$('#notice, #alert, #success').slideFlash()
	$('#term-records').on 'click', '[data-toggler]', toggleRecordExpand
	$('#delete-link').on 'click', ->
		confirm("Are you sure? Deletion can't be undone!")

$.fn.slideFlash = ->
	@.each ->
		$(@).animate({top: 30}, 800)
		setTimeout((=>
			$(@).animate({top: -100}, 800)
	  ), 3000)

toggleRecordExpand = ->
	$this = $(@)
	$this.closest('tr').next('.record-expand').toggle()
	$this.parent().children('[data-toggler]').toggle()