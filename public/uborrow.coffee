class UBorrow
  constructor: (@jQ, @container) ->
    @jQ(@container).data('uborrow',@)
    @locationFilter = @jQ('#uborrow-shim').data('uborrow-filter')
    boomTabUrl = @jQ(@container).find('.EXLTabsRibbon .EXLTabBoomId').val()
    match = boomTabUrl? && boomTabUrl.match(/rft\.isbn=([0-9X]+)/)
    @isbn = match? && match[1]

  findScriptHost: (extra) => @jQ('#uborrow-shim').data('uborrow-proxy') + extra

  checkLocal: =>
    console.log("Initiating availability check for #{@isbn}")
    if @container.find(".EXLLocationInfo#{@locationFilter} .EXLResultStatusAvailable").length == 0      
      @update('Checking ILL Status')
      console.log("Initiating uBorrow FindItem for #{@isbn}")
      query = $.param
        tid: (new Date()).valueOf()
        target: @container.attr('id')
      @jQ('head').append """<script src="#{@findScriptHost('findItem')}/ISBN/#{@isbn}?#{query}"></script>"""
    else
      console.log('Item is available. No FindItem check necessary.')
      
  update: (content) =>
    if @container.find('.EXLLocationInfo').length > 0
      if @container.find('span.uBorrowDisplay').length == 0
        @container.find(".EXLLocationInfo#{@locationFilter} .EXLResultStatusNotAvailable").first().append('<span class="uBorrowDisplay"></span>')
      if content?
        @container.find('span.uBorrowDisplay').html(content).prepend(' - ')

  checkIfReady: =>
    if @container.find('.EXLLocationInfo').length > 0
      @checkLocal()
    else
      setTimeout(@checkIfReady, 500)
      
$.fn.uBorrow = (args...) -> 
  [command, payload] = args
  switch command
    when 'init'
      for container in this 
        do (container) ->
          uBorrow = new UBorrow($, $(container))
          if uBorrow.isbn?
            console.log("Initializing uBorrow for #{uBorrow.isbn}")
            uBorrow.checkIfReady()
    when 'update'
      $(this).data('uborrow').update(payload)

$(document).ready -> 
  $('.EXLResult').uBorrow('init')
    
