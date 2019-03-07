$(document).ready(function(){

  // Select Provider
  $(".select-provider").each(function(){

    $(this).click(function(){
      provider_id = $(this).attr("data-id");
      provider_name = $(this).attr("data-name");

      $("#purchase_provider").val(provider_name).change();
      $("#purchase_provider_id").val(provider_id);

      $("#report_provider").val(provider_name).change();
      $("#report_provider_id").val(provider_id);

      $("#search-input").val("");
      $("#getProviders").modal("hide");
    });

  });


});
