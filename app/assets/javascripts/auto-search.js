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

  // Auto search customers
  $("#search-input-customers").on("keyup", function(){
    $("#search-btn-customers").delay(500).click();
  });

  // Auto search employees
  $("#search-input-employees").on("keyup", function(){
    $("#search-btn-employees").delay(500).click();
  });

});
