$(document).ready(function(){

  // Select Category
  $(".select-category").each(function(){

    $(this).click(function(){
      category_id = $(this).attr("data-id");
      category_name = $(this).attr("data-name");

      $("#product_category").val(category_name).change();
      $("#product_category_id").val(category_id);

      $("#search-input").val("");
      $("#getCategories").modal("hide");
    });

  });


});
