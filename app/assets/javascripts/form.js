$(document).ready(function(){

  // Display on the text-input, the filename selected by the file-input
  $("input[type=file]").change(function(e){
    filename = $(this).val();
    $("#filename").attr("value", filename);
    $(this).attr("value", "");
  });

  // Reset the file-input and img-tag values
  $("#reset-button").click(function(){
    $("#preview-image").attr("src", "https://res.cloudinary.com/reymundotenorio/image/upload/v1563544834/BANP/default.png"),
    $("#filename").attr("value", "");
  });

  // Display on the img-tag, the image selected by the file-input
  function updateImageSelected(input){
    if (input.files && input.files[0] && input.files[0].type.match("image.*")){
      var reader = new FileReader();

      reader.onload = function(e){
        $("#preview-image").attr("src", e.target.result);
      }

      reader.readAsDataURL(input.files[0]);
    }

    else{
      $("#preview-image").attr("src", "https://res.cloudinary.com/reymundotenorio/image/upload/v1563544834/BANP/default.png"),
      $("#filename").attr("value", "");
    }
  }

  // Add the updateImageSelected function to the event lister of the #select-image element
  $("#select-image").change(function(){
    updateImageSelected(this);
  });

  // Dropdown "Bootstrap" listener
  $(".dropdown-item").click(function(){
    $(".dropdown-toggle").val($.trim($(this).text()));
  });

  // Dropdown "Bootstrap" listener on pressing the "Enter" key
  $(".dropdown-item").on("keyup", function(e){
    if(e.which === 13){
      $(".dropdown-toggle").val($.trim($(this).text()));
      $("#role-dropdown").removeClass("open");
    }
  });

  // Open dropdown on input focus and add focus to dropdown-menu first item
  $("#employee_role").focus(function(){
    $("#role-dropdown").addClass("open");
    $("#role-dropdown .dropdown-menu li:first-child .dropdown-item").focus();
  });

  // Copy customer_email to value on user_email
  $("#customer_email").on("change paste keyup", function(){
    $("#customer_user_attributes_email").val($(this).val());
  });

});
