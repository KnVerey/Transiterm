jQuery ->
	$("#print").click ->
		window.print()

	$("#search").submit (e) ->
		e.preventDefault()
		$.ajax
			type: 'GET'
			url: $(@).attr('action')
			data: $(@).serialize()
			dataType: 'script'
			beforeSend: ->
				$('#records-table').hide()
				$('#term-records').empty()
				setWaitMsg("Searching...")
			success: ->
				$('#records-table').show()
				$('.pagination').css('display', 'none')

	if $('.pagination').length
		$('.pagination').css('display', 'none')
		$(window).scroll ->
			url = $('.pagination span.next').children().attr('href')
			if url && userNearBottom()
				appendNextPage(url)
		$(window).scroll()

userNearBottom = () ->
	$(window).scrollTop() > $(document).height() - $(window).height() - 350

appendNextPage = (url) ->
	setWaitMsg("Loading more results...")
	$.ajax
		url: url
		dataType: "script"
		success: ->
			$('.pagination').css('display', 'none')

setWaitMsg = (msg) ->
	$('#message-area').html("<i class='fa fa-spinner fa-spin'></i> &nbsp&nbsp#{msg}")