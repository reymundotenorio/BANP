$(document).ready(function() {

  // Clickcable row
  $(".clickable-row").click(function() {
    linkdata = $(this).attr("data-href");
    window.location.href = linkdata;
  });

});
