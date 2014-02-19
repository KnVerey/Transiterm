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
				$('#term-records').html("")

	if $('.pagination').length
		$(window).scroll ->
			url = $('.pagination span.next').children().attr('href')
			if url && userNearBottom()
				appendNextPage(url)
		$(window).scroll()

userNearBottom = () ->
	$(window).scrollTop() > $(document).height() - $(window).height() - 550

appendNextPage = (url) ->
	paginationHandler = paginationToMsg()
	$.ajax
		url: url
		dataType: "script"
		error: ->
			paginationHandler.reset()

paginationToMsg = () ->
	originalContent: $('.pagination').html()
	setWaitMsg: do ->
		msg = "&nbsp&nbsp<i class='fa fa-spinner fa-spin'></i> &nbsp&nbspLoading more results..."
		$('.pagination').html(msg)
	reset: ->
		$('.pagination').html(@.originalContent)