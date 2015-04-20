function uB(jQ) { 
  jQ(document).ready(function() {
    jQ('body').prepend('<div class="EXLCustomLayoutTile"><div id="uborrow-shim" data-uborrow-proxy="http://uborrow.dev/" data-uborrow-filter=":not(:contains(Qatar))"><script src="http://uborrow.dev/uborrow.js"></script></div></div>');
  });
} 
uB($)
