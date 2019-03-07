$(document).ready(function(){

  // Select Product
  $(".select-product").each(function(){

    $(this).click(function(){
      product_id = $(this).attr("data-id");
      product_name = $(this).attr("data-name");

      $("#report_product").val(product_name).change();
      $("#report_product_id").val(product_id);

      $("#search-input").val("");
      $("#getProducts").modal("hide");
    });

  });
  

});
