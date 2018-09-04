$(document).ready(function() {

  $('input.form-control.input').on('keyup change', function() {
    // If empty
    if($(this).val() == ''){
      $(this).removeClass("with-value"); // Remove class
    }
    else{
      $(this).addClass("with-value"); // Add class
    }
  });

});
