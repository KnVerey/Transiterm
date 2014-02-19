jQuery ->
	$('#new_excel_import').submit(stallForImportResponse)
	$('#upload-file').removeAttr('disabled')

stallForImportResponse = () ->
	$('#upload-file').attr('disabled','disabled')
	$('#please-wait-modal').foundation('reveal', 'open')