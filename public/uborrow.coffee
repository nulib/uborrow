class UBorrow
  constructor: (@jQ, @container) ->
    @jQ(@container).data('uborrow',@)
    @locationFilter = @jQ('#uborrow-shim').data('uborrow-filter')
    boomTabUrl = $(container).find('.EXLTabsRibbon .EXLLocationsTab .EXLTabBoomId').val()
    match = boomTabUrl? && boomTabUrl.match(/rft\.isbn=([0-9X]+)/)
    @isbn = match? && match[1]

  findScriptHost: (extra) => @jQ('#uborrow-shim').data('uborrow-proxy') + extra

  checkLocal: =>
    console.log("Initiating availability check for #{@isbn}")
    if @container.find(".EXLLocationInfo#{@locationFilter} .EXLResultStatusAvailable").length == 0
      console.log("Initiating uBorrow FindItem for #{@isbn}")
      @jQ.ajax
        type: 'POST'
        url: @findScriptHost('dws/item/available')
        contentType: 'application/json'
        data: """{"ExactSearch": [{"Type": "ISBN", "Value": "#{isbn}"}]}"""
        processData: false
        dataType: 'json'
        global: false
      .always (response, status) =>
        @displayResults(response)
    else
      console.log('Item is available. No FindItem check necessary.')

  displayResults: (response) =>
    if response.hasOwnProperty('Item') &! response.Item.Available
      link = @jQ("""<span> - <a href="#{response.Item.RequestLink.ButtonLink}" target="_blank" class="test-button">#{response.Item.RequestLink.RequestMessage}</a></span>""");
      @container.find(".EXLLocationInfo#{@locationFilter} .EXLResultStatusNotAvailable").first().append(link);

  checkIfReady: =>
    if @container.find('.EXLLocationInfo').length > 0
      @checkLocal()
    else
      setTimeout(@checkIfReady, 500)

$.fn.uBorrow = (options) -> 
  for container in this 
    do (container) ->
      uBorrow = new UBorrow($, $(container))
      if uBorrow.isbn?
        console.log("Initializing uBorrow for #{uBorrow.isbn}")
        uBorrow.checkIfReady()

$(document).ready -> 
  $('.EXLResult').uBorrow()
