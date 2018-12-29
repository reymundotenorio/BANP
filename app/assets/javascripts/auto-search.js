$(document).ready(function(){
  
  // Auto search
  $("#search-input").bind("keyup", function(){
    $("#search-form").delay(200).submit();
  });

});
