// Generated by CoffeeScript 1.6.3
(function() {
  var UBorrow,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  UBorrow = (function() {
    function UBorrow(jQ, container) {
      var boomTabUrl, match;
      this.jQ = jQ;
      this.container = container;
      this.checkIfReady = __bind(this.checkIfReady, this);
      this.displayResults = __bind(this.displayResults, this);
      this.checkLocal = __bind(this.checkLocal, this);
      this.findScriptHost = __bind(this.findScriptHost, this);
      this.jQ(this.container).data('uborrow', this);
      this.locationFilter = this.jQ('#uborrow-shim').data('uborrow-filter');
      boomTabUrl = $(container).find('.EXLTabsRibbon .EXLLocationsTab .EXLTabBoomId').val();
      match = (boomTabUrl != null) && boomTabUrl.match(/rft\.isbn=([0-9X]+)/);
      this.isbn = (match != null) && match[1];
    }

    UBorrow.prototype.findScriptHost = function(extra) {
      return this.jQ('#uborrow-shim').data('uborrow-proxy') + extra;
    };

    UBorrow.prototype.checkLocal = function() {
      var _this = this;
      console.log("Initiating availability check for " + this.isbn);
      if (this.container.find(".EXLLocationInfo" + this.locationFilter + " .EXLResultStatusAvailable").length === 0) {
        console.log("Initiating uBorrow FindItem for " + this.isbn);
        return this.jQ.ajax({
          type: 'POST',
          url: this.findScriptHost('dws/item/available'),
          contentType: 'application/json',
          data: JSON.stringify({
            "ExactSearch": [
              {
                "Type": "ISBN",
                "Value": this.isbn
              }
            ]
          }),
          processData: false,
          dataType: 'json',
          global: false
        }).always(function(response, status) {
          return _this.displayResults(response);
        });
      } else {
        return console.log('Item is available. No FindItem check necessary.');
      }
    };

    UBorrow.prototype.displayResults = function(response) {
      var link;
      if (response.hasOwnProperty('Item') & !response.Item.Available) {
        link = this.jQ("<span> - <a href=\"" + response.Item.RequestLink.ButtonLink + "\" target=\"_blank\" class=\"test-button\">" + response.Item.RequestLink.RequestMessage + "</a></span>");
        return this.container.find(".EXLLocationInfo" + this.locationFilter + " .EXLResultStatusNotAvailable").first().append(link);
      }
    };

    UBorrow.prototype.checkIfReady = function() {
      if (this.container.find('.EXLLocationInfo').length > 0) {
        return this.checkLocal();
      } else {
        return setTimeout(this.checkIfReady, 500);
      }
    };

    return UBorrow;

  })();

  $.fn.uBorrow = function(options) {
    var container, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      container = this[_i];
      _results.push((function(container) {
        var uBorrow;
        uBorrow = new UBorrow($, $(container));
        if (uBorrow.isbn != null) {
          console.log("Initializing uBorrow for " + uBorrow.isbn);
          return uBorrow.checkIfReady();
        }
      })(container));
    }
    return _results;
  };

  $(document).ready(function() {
    return $('.EXLResult').uBorrow();
  });

}).call(this);
