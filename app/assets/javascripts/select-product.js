$(document).ready(function(){

  // Select Provider
  $(".select-product").each(function(){

    $(this).click(function(){
      product_id = $(this).attr("data-id");
      product_name = $(this).attr("data-name");

      $("#purchase_product").val(product_name).change();
      $("#purchase_product_id").val(product_id);

      $("#search-input").val("");
      $("#getProviders").modal("hide");
    });

  });


});
