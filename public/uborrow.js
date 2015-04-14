(function(jQ) {
  jQ(document).ready(function() {

    var locationFilter = jQ('#uborrow-shim').data('uborrow-filter');
    
    function findScriptHost(extra) {
      var scriptHost = jQ('#uborrow-shim').data('uborrow-proxy');
      return scriptHost + extra;
    }
    
    function checkLocal() {
      var needToCheck = jQ('.EXLLocationInfo' + locationFilter + ' .EXLResultStatusAvailable').length == 0
      if (needToCheck) {
        var isbn = jQ('#ISBN-1 .EXLDetailsDisplayVal').text().split(/\s/)[0];
        console.log('Initiating uBorrow FindItem for '+isbn)
        jQ.ajax({
          type: 'POST',
          url: findScriptHost('dws/item/available'),
          contentType: 'application/json',
          data: JSON.stringify({
            "ExactSearch": [{"Type": "ISBN", "Value": isbn}]
          }),
          processData: false,
          dataType: 'json',
          global: false
        }).always(function(response, status) {
          displayResults(response)
        })
      } else {
        console.log('Item is available. No FindItem check necessary.')
      }
    }

    function displayResults(response) {
      if (response.hasOwnProperty('Item') &! response.Item.Available) {
        var link = jQ('<span> - <a href="' + response.Item.RequestLink.ButtonLink + '" target="_blank" class="test-button">' + response.Item.RequestLink.RequestMessage + '</a></span>');
        jQ('.EXLLocationInfo' + locationFilter + ' .EXLResultStatusNotAvailable').first().append(link);
      }
    }

    function checkIfReady() {
      if(jQ('.EXLLocationInfo').length > 0) {
        checkLocal();
      } else {
        setTimeout(checkIfReady, 500);
      }
    }
    checkIfReady();
  })
})($)
