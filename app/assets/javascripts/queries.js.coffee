jQuery ->
	$("#print").click ->
		window.print()

	if $('.pagination').length
		$(window).scroll ->
			url = $('.pagination span.next').children().attr('href')
			if url && userNearBottom()
				appendNextPage(url)
		$(window).scroll()

userNearBottom = () ->
	$(window).scrollTop() > $(document).height() - $(window).height() - 550

appendNextPage = (url) ->
	oldPaginatorContent = $('.pagination').html()
	waitMsg = "&nbsp&nbsp<i class='fa fa-spinner fa-spin'></i> &nbsp&nbspLoading more results..."
	fillPaginator(waitMsg)

	$.ajax
		url: url
		dataType: "script"
		error: ->
			fillPaginator(oldPaginatorContent)

fillPaginator = (content) ->
	$('.pagination').html(content)