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
  function updateImageSelected(evt) {
    var files = evt.target.files;
    f = files[0]
    if (f.type.match('image.*')) {
      var reader = new FileReader();
      reader.onload = (function (theFile) {
        return function (e) {
          document.getElementById("preview-image").src = e.target.result;
        };
      })(f);
      reader.readAsDataURL(f);
    }
  }

  // Add the updateImageSelected function to the event lister of the #select_image element
  document.getElementById('select_image').addEventListener('change', updateImageSelected, false);
});
