$(document).ready(function(){

  // Format Currency
  const formatter = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  });
  // End Format Currency

  // Substract button on cart details
  $(".subtract").click(function(){
    var $input = $(this).next();
    var currentValue = parseInt($input.val());

    if(currentValue > 1){
      $input.val(currentValue - 1);
    }

    if ($input.val().length <= 0){
      $input.val(1);
    }
  });
  // End Substract button on cart details

  // Add button on cart details
  $(".add").click(function(){
    var $input = $(this).prev();
    var currentValue = parseInt($input.val());

    $input.val(currentValue + 1);

    if ($input.val().length <= 0){
      $input.val(1);
    }
  });
  // End Add button on cart details

  // Validate if is a number
  function isNumberInt(n) {
    return !isNaN(parseInt(n)) && isFinite(n);
  }

  function isNumberFloat(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
  }
  // End Validate if is a number

  // Validate numbers on quantity input
  $(".q-input").on("keyup change", function(){
    if (!isNumberInt($(this).val())) {
      return;
    }
    else{
      product_id = $(this).attr("id").replace("product_quantity_", "");

      price_elem = "#product_price_$product_id".replace("$product_id", product_id);
      product_price = $(price_elem);

      if($(product_price).val() != ""){
        total_elem = "#product_total_$product_id".replace("$product_id", product_id);
        product_total = $(total_elem);

        price_val = parseFloat(product_price.val());
        quantity_val = parseInt($(this).val());

        total = price_val * quantity_val;
        product_total.text(formatter.format(total));
      }
    }
  });
  // End Validate numbers on quantity input

  // Avoid enter letters and symbols
  $(".q-input").keypress(function(e) {
    if(e.charCode < 48 || e.charCode > 57) return false;
  });
  // End Avoid enter letters and symbols

  // Validate numbers on quantity input
  $(".input.price").on("keyup change", function(){
    if (!isNumberFloat($(this).val())) {
      return;
    }
    else{
      product_id = $(this).attr("id").replace("product_price_", "");

      quantity_elem = "#product_quantity_$product_id".replace("$product_id", product_id);
      product_quantity = $(quantity_elem);

      if($(product_quantity).val() != ""){
        total_elem = "#product_total_$product_id".replace("$product_id", product_id);
        product_total = $(total_elem);

        quantity_val = parseInt(product_quantity.val());
        price_val = parseFloat($(this).val());

        total = price_val * quantity_val;
        product_total.text(formatter.format(total));
      }
    }
  });
  // End Validate numbers on quantity input

  // Click on Select product
  $(".select-product").click(function(){
    var date_id = Date.now().toString();

    product_id = $(this).data("id");
    product_name = $(this).data("name");
    price_elem = "#product_price_$product_id".replace("$product_id", product_id)
    quantity_elem = "#product_quantity_$product_id".replace("$product_id", product_id)

    product_price = $(price_elem);
    product_quantity = $(quantity_elem);

    if (product_price.val() == ""){
      product_price.focus();
      return;
    }

    if (product_price.val() == ""){

      if (!isNumberInt(product_price.val())) {
        product_quantity.focus();
        return;
      }
    }

    var new_product = "<div class='nested-fields'><div class='field'><label for='purchase_purchase_details_attributes_" + date_id +"_product_id'>Product</label><br><input type='text' name='purchase[purchase_details_attributes][" + date_id +"][product_id]' id='purchase_purchase_details_attributes_" + date_id +"_product_id' value='5'></div><div class='field'><label for='purchase_purchase_details_attributes_" + date_id +"_price'>Precio</label><br><input type='text' name='purchase[purchase_details_attributes][" + date_id +"][price]' id='purchase_purchase_details_attributes_" + date_id +"_price' value='800'></div><div class='field'><label for='purchase_purchase_details_attributes_" + date_id +"_quantity'>Cantidad</label><br><input type='text' name='purchase[purchase_details_attributes][" + date_id +"][quantity]' id='purchase_purchase_details_attributes_" + date_id +"_quantity' value='2'></div><div class='field'><label for='purchase_purchase_details_attributes_" + date_id +"_status'>Condición</label><br><input type='text' name='purchase[purchase_details_attributes][" + date_id +"][status]' id='purchase_purchase_details_attributes_" + date_id +"_status' value='OK'></div><input type='hidden' name='purchase[purchase_details_attributes][" + date_id +"][_destroy]' id='purchase_purchase_details_attributes_" + date_id +"__destroy' value='false'><a class='btn btn-general remove_fields dynamic' href='#'>Remove detail</a></div>";

    $("#purchase_details").append(new_product);
  });
  // Click on Select product


});
