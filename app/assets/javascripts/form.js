$(document).ready(function() {

  // Display on the text-input, the filename selected by the file-input
  $('input[type=file]').change(function (e) {
    filename = $(this).val();
    $("#filename").attr("value", filename);
    $(this).attr("value", "");
  });

  // Reset the file-input and img-tag values
  $("#reset-button").click(function() {
    $("#preview-image").attr("src", "https://s3.amazonaws.com/betterandnice/images/default/default.png"),
    $("#filename").attr("value", "");
  });

  // Display on the img-tag, the image selected by the file-input
  function updateImageSelected(input) {
    if (input.files && input.files[0] && input.files[0].type.match('image.*')) {
      var reader = new FileReader();

      reader.onload = function (e) {
        $("#preview-image").attr("src", e.target.result);
      }

      reader.readAsDataURL(input.files[0]);
    }
    else{
      $("#preview-image").attr("src", "https://s3.amazonaws.com/betterandnice/images/default/default.png"),
      $("#filename").attr("value", "");
    }
  }

  // Add the updateImageSelected function to the event lister of the #select_image element
  $("#select_image").change(function(){
    updateImageSelected(this);
  });
  
});
