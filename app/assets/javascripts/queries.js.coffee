jQuery ->
	$("#print").click ->
		window.print()

	$("#search").submit (e) ->
		e.preventDefault()
		$this = $(@)
		data = $this.serialize()
		url = $this.attr('action')
		ajaxSearch(data, url)

	if $('.pagination').length
		hidePagination()
		bindInfiniteScroll()
		$(window).scroll()

bindInfiniteScroll = () ->
	$(window).scroll ->
		url = $('.pagination span.next').children().attr('href')
		if url && userNearBottom() then appendNextPage(url)

userNearBottom = () ->
	$(window).scrollTop() > $(document).height() - $(window).height() - 350

appendNextPage = (url) ->
	setWaitMsg("Loading more results...")
	$.ajax
		url: url
		dataType: "script"
		success: ->
			hidePagination()

ajaxSearch = (data, url) ->
	setWaitMsg("Searching...")
	clearRecordsTable()
	$.ajax
		type: 'GET'
		url: url
		data: data
		dataType: 'script'
		success: ->
			hidePagination()
			$('#records-table').show()

clearRecordsTable = ->
	$('#records-table').hide()
	$('#term-records').empty()

setWaitMsg = (msg) ->
	$('#message-area').html("<i class='fa fa-spinner fa-spin'></i> &nbsp&nbsp#{msg}")

hidePagination = ->
	$('.pagination').css('display', 'none')