

// Fixing switch on reset
$("#reset-button").click(function(e) {
  $(".new_customer")[0].reset();

  // Change iOS toggle status
  $("#switcher").each(function(){
    if (this.checked){
      $("#switcherToggle").addClass("active");
    }

    else{
      $("#switcherToggle").removeClass("active");
    }
  });


  e.preventDefault();
});
// End Fixing switch reset
