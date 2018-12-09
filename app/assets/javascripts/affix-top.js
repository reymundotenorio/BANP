$(document).on("turbolinks:load", function(){

  var dataAffix = parseInt($("#back-top").attr("data-custom-affix"));

  // Data attribute is an integer and positive value
  if(!isNaN(dataAffix) && dataAffix > -1){
    $("#back-top").affix({
      offset: {
        top: dataAffix
      }
    });
  }

});
