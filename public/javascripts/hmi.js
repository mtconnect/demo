
document.observe("dom:loaded", function() {
   var hmi = $('hmi')
   if (hmi) {
      new Insight.Updater(hmi, window.location.href + "/update_hmi",
	                  {frequency: 1});
   }
});