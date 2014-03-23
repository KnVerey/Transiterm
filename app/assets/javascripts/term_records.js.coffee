jQuery ->
  if $('#term_record_source_name').length
    $('#term_record_source_name').autocomplete({
      source: getSources,
      appendTo: $('#term_record_source_name').parent(),
      delay: 500,
      minLength: 3
      })

  if $('#term_record_domain_name').length
    $('#term_record_domain_name').autocomplete({
      source: getDomains,
      appendTo: $('#term_record_domain_name').parent(),
      delay: 500,
      minLength: 3
      })

getSources = (request, response) ->
  $.ajax
    url: '/sources'
    data: { filter: request.term }
    dataType: 'json'
    success: (data) ->
      response(data)

getDomains = (request, response) ->
  $.ajax
    url: '/domains'
    data: { filter: request.term }
    dataType: 'json'
    success: (data) ->
      response(data)
