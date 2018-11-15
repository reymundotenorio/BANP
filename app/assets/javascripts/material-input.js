$(document).ready(function() {

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

});
