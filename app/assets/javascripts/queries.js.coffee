jQuery ->
	$("#print").click(->
		window.print())

	if $('.pagination').length
		$(window).scroll(->
			url = $('.pagination span.next').children().attr('href')
			if url && userNearBottom()
				fetchNextPage(url)
				replacePaginatorWithMsg())
		$(window).scroll()

replacePaginatorWithMsg = () ->
	$('.pagination').html("&nbsp&nbsp<i class='fa fa-spinner fa-spin'></i> &nbsp&nbspLoading more results...")

fetchNextPage = (url) ->
	$.getScript(url)

userNearBottom = () ->
	$(window).scrollTop() > $(document).height() - $(window).height() - 550