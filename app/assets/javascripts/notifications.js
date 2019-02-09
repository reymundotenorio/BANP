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

  // Toast message error
  var currentURL = document.URL;
  var params = currentURL.extract();
  var i18nLocale = $("body").data("locale");

  try{
    if(params.notification == "sign-in-required"){
      i18nLocale == "es" ? mustSignIn = "Debe iniciar sesión para continuar" : mustSignIn = "You must sign in to continue";
      
      toastr.error("", mustSignIn, {closeButton: true, timeOut: 0, extendedTimeOut: 0, preventDuplicates: true});
    }
  } catch (error){
    // console.log(error.message);
  }

  // Flash alert
  if($("#flash-alert").length){
    toastr.error($("#flash-alert").text(), "", {closeButton: true, timeOut: 0, extendedTimeOut: 0});
  }

  // Flash notice
  if($("#flash-notice").length){
    toastr.success($("#flash-notice").text(), "", {closeButton: true, timeOut: 0, extendedTimeOut: 0});
  }

});
