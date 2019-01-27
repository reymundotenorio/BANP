$(document).ready(function(){

  $("#display-password").click(function(){
    if($("#sign_in_password").attr('type') == "password"){
      $("#sign_in_password").prop("type", "text");
      $("#display-password").addClass("no-display");
    }
    
    else{
      $("#sign_in_password").prop("type", "password");
      $("#display-password").removeClass("no-display");
    }
  });

});
