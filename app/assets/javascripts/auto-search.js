$(document).ready(function(){

  // Auto search
  $("#search-input").on("keyup", function(){
    $("#search-btn").delay(500).click();
  });

  // Auto search providers
  $("#search-input-providers").on("keyup", function(){
    $("#search-btn-providers").delay(500).click();
  });

  // Auto search products
  $("#search-input-products").on("keyup", function(){
    $("#search-btn-products").delay(500).click();
  });

});
