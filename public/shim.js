function uB(jQ) { 
  jQ('head').data('uborrow-proxy','http://uborrow.library.northwestern.edu/'); 
  jQ('head').data('uborrow-filter',':not(:contains(Qatar))'); 
  jQ('head').append('<script src="http://uborrow.library.northwestern.edu/uborrow.js" class="uborrow-proxy"></script>'); 
  return void(0); 
} 
uB($)
