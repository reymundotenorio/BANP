//= require jquery-mask/jquery.mask

$(document).ready(function(){

  // Init Bootstrap tooltips
  $('[data-toggle="tooltip"]').tooltip();
  $('[data-tooltip="true"]').tooltip();


  // Inputs listener
  $("input.form-control").on("keyup change", function(){
    // If empty
    if($(this).val() == ""){
      $(this).removeClass("with-value"); // Remove class
    }

    else{
      $(this).addClass("with-value"); // Add class
    }
  });

  // Text area listener
  $("textarea.form-control").on("keyup change", function(){
    // If empty
    if($(this).val() == ""){
      $(this).removeClass("with-value"); // Remove class
    }

    else{
      $(this).addClass("with-value"); // Add class
    }
  });

  // Inputs
  $("input.form-control").each(function(){
    // If empty
    if($(this).val() == ""){
      $(this).removeClass("with-value"); // Remove class
    }

    else{
      $(this).addClass("with-value"); // Add class
    }
  });

  // Text area
  $("textarea.form-control").each(function(){
    // If empty
    if($(this).val() == ""){
      $(this).removeClass("with-value"); // Remove class
    }

    else{
      $(this).addClass("with-value"); // Add class
    }
  });

  // Inputs change
  $("input.form-control").change(function(){
    // If empty
    if($(this).val() == ""){
      $(this).removeClass("with-value"); // Remove class
    }

    else{
      $(this).addClass("with-value"); // Add class
    }
  });

  // Mask for price Input
  $(".price").mask("#,##0.00", {reverse: true});

  // Change iOS toggle status
  $("#switcher").each(function(){
    if (this.checked){
      $("#switcherToggle").addClass("active");
    }

    else{
      $("#switcherToggle").removeClass("active");
    }
  });

  $("#switcher").change(function(){
    if (this.checked){
      $("#switcherToggle").addClass("active");
    }

    else{
      $("#switcherToggle").removeClass("active");
    }
  });

  // Prevent enter on product code
  $("#product_barcode").bind("keypress keydown keyup", function(e){
    if(e.keyCode == 13){
      e.preventDefault();
    }
  });

});
