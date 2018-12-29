$(document).ready(function(){
  
  // Select Category
  $(".select-category").click(function(){
    category_id = $(this).attr('data-id');
    category_name = $(this).attr('data-name');

    $("#product_category").val(category_name).change();
    $("#product_category_id").val(category_id);

    $('#getCategories').modal('hide');
  });

});
