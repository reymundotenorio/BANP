// Turbolinks loading
$(document).on("turbolinks:click", function(){
  $(".preloader").show();
});

// Turbolinks loaded
$(document).on("turbolinks:load", function(){
  $(".preloader").hide();
});
