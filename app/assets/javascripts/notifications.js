$(document).ready(function(){

  toastr.options = {
    "closeButton": false,
    "debug": false,
    "newestOnTop": true,
    "progressBar": true,
    "positionClass": "toast-top-center",
    "preventDuplicates": false,
    "onclick": null,
    "showDuration": "300",
    "hideDuration": "1000",
    "timeOut": "3000",
    "extendedTimeOut": "3000",
    "showEasing": "swing",
    "hideEasing": "linear",
    "showMethod": "fadeIn",
    "hideMethod": "fadeOut"
  };
  
  // Flash alert
  if($("#flash-alert").length){
    toastr.error($("#flash-alert").text(), "", {closeButton: true, timeOut: 0, extendedTimeOut: 0});
  }
  
  // Flash notice
  if($("#flash-notice").length){
    toastr.success($("#flash-notice").text(), "", {closeButton: true, timeOut: 0, extendedTimeOut: 0});
  }
  
});
