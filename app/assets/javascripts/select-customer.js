$(document).ready(function(){

  // Select Provider
  $(".select-customer").each(function(){

    $(this).click(function(){
      customer_id = $(this).attr("data-id");
      customer_name = $(this).attr("data-name");

      $("#sale_customer").val(customer_name).change();
      $("#sale_customer_id").val(customer_id);

      $("#search-input").val("");
      $("#getCustomers").modal("hide");
    });

  });


});
