$(document).on("turbolinks:load", function() {
  // $(document).ready(function() {

  // Inputs listener
  $("input.form-control").on("keyup change", function() {
    // If empty
    if($(this).val() == ""){
      $(this).removeClass("with-value"); // Remove class
    }

    else{
      $(this).addClass("with-value"); // Add class
    }
  });

  // Text area listener
  $("textarea.form-control").on("keyup change", function() {
    // If empty
    if($(this).val() == ""){
      $(this).removeClass("with-value"); // Remove class
    }

    else{
      $(this).addClass("with-value"); // Add class
    }
  });

  // Inputs
  $("input.form-control").each(function() {
    // If empty
    if($(this).val() == ""){
      $(this).removeClass("with-value"); // Remove class
    }

    else{
      $(this).addClass("with-value"); // Add class
    }
  });

  // Text area
  $("textarea.form-control").each(function() {
    // If empty
    if($(this).val() == ""){
      $(this).removeClass("with-value"); // Remove class
    }

    else{
      $(this).addClass("with-value"); // Add class
    }
  });

  // Inputs change
  $("input.form-control").change(function() {
    // If empty
    if($(this).val() == ""){
      $(this).removeClass("with-value"); // Remove class
    }

    else{
      $(this).addClass("with-value"); // Add class
    }
  });

});
