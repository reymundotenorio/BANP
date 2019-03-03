$(document).ready(function(){

  // Mask for discount Input
  $(".discount").mask("##.0");

  var i18nLocale = $("body").data("locale");

  // Format Currency
  const formatter = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2
  });
  // End Format Currency

  // Validate if is a number
  function isNumberInt(n) {
    return !isNaN(parseInt(n)) && isFinite(n);
  }

  function isNumberFloat(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
  }
  // End Validate if is a number

  // Validate numbers on quantity input
  $(".q-input.search").on("keyup change", function(){
    if (!isNumberInt($(this).val())) {
      return;
    }
    else{
      product_id = $(this).attr("id").replace("product_quantity_", "");

      price_elem = "#product_price_$product_id".replace("$product_id", product_id);
      product_price = $(price_elem);

      if(product_price.text() != ""){
        total_elem = "#product_total_$product_id".replace("$product_id", product_id);
        product_total = $(total_elem);

        productPrice = product_price.text().replace("$", "");
        productPrice = productPrice.replace(",", "");

        console.error(productPrice);

        price_val = parseFloat(productPrice);
        quantity_val = parseInt($(this).val());

        total = price_val * quantity_val;
        product_total.text(formatter.format(total));
      }
    }
  });
  // End Validate numbers on quantity input

  // Prevent quantity without value
  $(".q-input.search").focusout(function(){
    if($(this).val() == ""){
      $(this).val("1");
      $(this).trigger("change");
    }
  });
  // End Prevent quantity without value

  // Avoid enter letters and symbols
  $(".q-input.search").keypress(function(e) {
    if(e.charCode < 48 || e.charCode > 57) return false;
  });
  // End Avoid enter letters and symbols

  // Validate numbers on quantity input
  $(".input.price").on("keyup change", function(){
    if($(this).val() == ""){
      product_id = $(this).attr("id").replace("product_price_", "");
      total_elem = "#product_total_$product_id".replace("$product_id", product_id);
      product_total = $(total_elem);

      product_total.text(formatter.format("0.00"));
    }
    else{
      product_id = $(this).attr("id").replace("product_price_", "");

      quantity_elem = "#product_quantity_$product_id".replace("$product_id", product_id);
      product_quantity = $(quantity_elem);

      if($(product_quantity).val() != ""){
        total_elem = "#product_total_$product_id".replace("$product_id", product_id);
        product_total = $(total_elem);

        productPrice = $(this).text().replace("$", "");
        productPrice = productPrice.replace(",", "");

        quantity_val = parseInt(product_quantity.val());
        price_val = parseFloat(productPrice);

        total = price_val * quantity_val;
        product_total.text(formatter.format(total));
      }
    }

  });
  // End Validate numbers on quantity input

  // Update total
  function updateTotal(){
    var totalDetails = 0;
    var discount = 0;
    // Detail total
    $(".detail-total").each(function(){
      // If not empty
      if($(this).text() != ""){
        total = $(this).text().replace("$", "");
        total = total.replace(",", "");
        totalDetails +=  parseFloat(total);
      }
    });

    $("#subtotal").text(formatter.format(totalDetails));
    $("#shipping").text(formatter.format(0));

    discountContent = $(".discount").val();

    if (discountContent != ""){
      discount = parseFloat(discountContent);
      discount = discount / 100;
      discount = totalDetails * discount;

      $("#discount").text(formatter.format(discount));
      $("#discountPercent").text("("+discountContent+"%)");
    }
    else{
      $("#discount").text(formatter.format(0));
      $("#discountPercent").text("(0.0%)");
    }


    $("#total").text(formatter.format(totalDetails - discount));
  }
  // End Update total

  // Events on Details
  function eventsOnDetails(){

    // Remove duplicate click functions
    $(".subtract").off("click");
    $(".add").off("click");
    // End Remove duplicate click functions


    // Subtract button on cart details
    $(".subtract").click(function(){
      var $input = $(this).next();
      var currentValue = parseInt($input.val());

      if(currentValue > 1){
        $input.val(currentValue - 1);
      }

      if ($input.val().length <= 0){
        $input.val(1);
      }

      $input.trigger("change");
    });
    // End Subtract button on cart details

    // Add button on cart details
    $(".add").click(function(){
      var $input = $(this).prev();
      var currentValue = parseInt($input.val());

      $input.val(currentValue + 1);

      if ($input.val().length <= 0){
        $input.val(1);
      }

      $input.trigger("change");
    });
    // End Add button on cart details

    // Avoid enter letters and symbols
    $(".q-input.details").keypress(function(e) {
      if(e.charCode < 48 || e.charCode > 57) return false;
    });
    // End Avoid enter letters and symbols

    // Validate numbers on quantity input on details
    $(".q-input.details").on("keyup change", function(){
      if (!isNumberInt($(this).val())) {
        return;
      }
      else{
        product_id = $(this).attr("id").replace("sale_sale_details_attributes_", "");
        product_id = product_id.replace("_quantity", "");

        price_elem = "#sale_sale_details_attributes_$product_id_price".replace("$product_id", product_id);
        product_price = $(price_elem);

        if(product_price.text() != ""){
          total_elem = "#sale_sale_details_attributes_$product_id_total".replace("$product_id", product_id);
          product_total = $(total_elem);

          price_val = parseFloat(product_price.data("price"));
          quantity_val = parseInt($(this).val());

          total = price_val * quantity_val;
          product_total.text(formatter.format(total));
        }
      }

      updateTotal()
    });
    // End Validate numbers on quantity input on details
  }
  // End Events on Details

  // Updating Total on remove
  $("#sale_details").on("cocoon:after-remove", function() {
    updateTotal();
  });
  // End Updating Total on remove

  // Remove duplicate click functions
  $(".select-product").off("click");
  // End Remove duplicate click functions

  // Click on Select product
  $(".select-product").click(function(){
    var date_id = Date.now().toString();

    product_id = $(this).data("id");
    product_name = $(this).data("name");
    price_elem = "#product_price_$product_id".replace("$product_id", product_id)
    quantity_elem = "#product_quantity_$product_id".replace("$product_id", product_id)

    product_price = $(price_elem);
    product_quantity = $(quantity_elem);

    if (product_price.text() == ""){
      product_price.focus();
      return;
    }

    if (product_price.text() == ""){

      if (!isNumberInt(product_price.text())) {
        product_quantity.focus();
        return;
      }
    }

    total_elem = "#product_total_$product_id".replace("$product_id", product_id);
    product_total = $(total_elem);

    nameText = i18nLocale == "es" ? "Nombre" : "Name";
    priceText = i18nLocale == "es" ? "Precio" : "Price";
    quantityText = i18nLocale == "es" ? "Cantidad" : "Quantity";

    productPrice = product_price.text().replace("$", "");
    productPrice = productPrice.replace(",", "");

    var new_order_product =
    "<tr class='nested-fields'><td class='hidden'><input value='" + product_id + "' type='hidden' name='sale[sale_details_attributes][" + date_id + "][product_id]' id='sale_sale_details_attributes_" + date_id + "_product_id'></td><td class='hidden'><input value='ordered' type='hidden' name='sale[sale_details_attributes][" + date_id + "][status]' id='sale_sale_details_attributes_" + date_id + "_status'></td><td class='name-container'><p class='record-link' data-header='" + nameText + "'><input class='input-disabled' value='" + product_name + "' type='text' name='sale[sale_details_attributes][" + date_id + "][product]' id='sale_sale_details_attributes_" + date_id + "_product'></p></td><td class='price-container price-row align-middle'><p class='record-link' data-header='" + priceText + "'><input class='input-disabled no-padding price-details' data-price= '" + productPrice + "' value='" + formatter.format(productPrice) + "' type='text' name='sale[sale_details_attributes][" + date_id + "][price]' id='sale_sale_details_attributes_" + date_id + "_price'></p></td><td class='quantity-container align-middle'><div class='form-group no-padding record-link' data-header='" + quantityText + "'><div class='quantity'><button class='subtract' name='minus' type='button'><i class='fas fa-minus'></i></button><input class='q-input details' min='1' step='1' value='" + product_quantity.val() + "' type='number' name='sale[sale_details_attributes][" + date_id + "][quantity]' id='sale_sale_details_attributes_" + date_id + "_quantity'><button class='add' name='plus' type='button'><i class='fas fa-plus'></i></button></div></div></td><td class='align-middle total-container'><p class='record-link detail-total' data-header='Total' id='sale_sale_details_attributes_" + date_id + "_total'>" + product_total.text() + "</p></td><td class='align-middle'><input type='hidden' name='sale[sale_details_attributes][" + date_id + "][_destroy]' id='sale_sale_details_attributes_" + date_id + "__destroy' value='false'><a class='btn btn-general remove_fields dynamic' href='#'><i class='fas fa-trash-alt'></i></a></td></tr>";

    var new_reception_product =
    "<tr class='nested-fields'><td class='hidden'><input value='" + product_id + "' type='hidden' name='sale[sale_details_attributes][" + date_id + "][product_id]' id='sale_sale_details_attributes_" + date_id + "_product_id'></td><td class='hidden'><input value='received' type='hidden' name='sale[sale_details_attributes][" + date_id + "][status]' id='sale_sale_details_attributes_" + date_id + "_status'></td><td class='name-container'><p class='record-link' data-header='" + nameText + "'><input class='input-disabled' value='" + product_name + "' type='text' name='sale[sale_details_attributes][" + date_id + "][product]' id='sale_sale_details_attributes_" + date_id + "_product'></p></td><td class='price-container price-row align-middle'><p class='record-link' data-header='" + priceText + "'><input class='input-disabled no-padding price-details' data-price= '" + productPrice + "' value='" + formatter.format(productPrice) + "' type='text' name='sale[sale_details_attributes][" + date_id + "][price]' id='sale_sale_details_attributes_" + date_id + "_price'></p></td><td class='quantity-container align-middle'><div class='form-group no-padding record-link' data-header='" + quantityText + "'><div class='quantity'><button class='subtract' name='minus' type='button'><i class='fas fa-minus'></i></button><input class='q-input details' min='1' step='1' value='" + product_quantity.val() + "' type='number' name='sale[sale_details_attributes][" + date_id + "][quantity]' id='sale_sale_details_attributes_" + date_id + "_quantity'><button class='add' name='plus' type='button'><i class='fas fa-plus'></i></button></div></div></td><td class='align-middle total-container'><p class='record-link detail-total' data-header='Total' id='sale_sale_details_attributes_" + date_id + "_total'>" + product_total.text() + "</p></td><td class='align-middle'><input type='hidden' name='sale[sale_details_attributes][" + date_id + "][_destroy]' id='sale_sale_details_attributes_" + date_id + "__destroy' value='false'><a class='btn btn-general remove_fields dynamic' href='#'><i class='fas fa-trash-alt'></i></a></td></tr>";

    $("#sale_details.order_details").append(new_order_product);
    $("#sale_details.reception_details").append(new_reception_product);

    eventsOnDetails();
    updateTotal();
  });
  // Click on Select product

  // Replacing prices
  function replacePrices(){
    $(".price-details").each(function(){
      // If not empty
      if($(this).val() != ""){
        $(this).val($(this).data("price"));
      }
    });
  }
  // End Replacing prices

  // Fixing prices
  $(".new_sale").submit(function(e) {
    replacePrices();
  });

  $(".edit_sale").submit(function(e) {
    replacePrices();
  });
  // Fixing prices

  // Update total on discount change
  $(".discount").on("keyup change", function(){
    updateTotal();
  });
  // Update total on discount change

  // Fixing date on reset
  $("#reset-button").click(function(e) {
    $(".new_sale")[0].reset();

    var i18nLocale = $("body").data("locale");
    var dateFormat = i18nLocale == "es" ? "DD/MM/YYYY hh:mm A" : "MM/DD/YYYY hh:mm A";

    // Datetime
    $("#sale_datetime_picker").each(function(){
      // If not empty
      if($(this).val() != ""){
        pickerDate = moment($(this).val(), dateFormat).toDate();
        $("#sale_sale_datetime").val(moment($(this).val(), dateFormat).format("YYYY-MM-DD'T'HH:mm:ss.SSSZ"));
      }
      else{
        if($("#sale_sale_datetime").val() != ""){
          $(this).val(moment($("#sale_sale_datetime").val(), "YYYY-MM-DD'T'HH:mm:ss.SSSZ").format(dateFormat));
        }
      }
    });

    e.preventDefault();
  });
  // End Fixing date reset

  eventsOnDetails();
  updateTotal();
});
