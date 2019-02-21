//= require jquery-mask/jquery.mask

$(document).ready(function(){

  var i18nLocale = $("body").data("locale");
  var dateFormat = i18nLocale == "es" ? "DD/MM/YYYY hh:mm A" : "MM/DD/YYYY hh:mm A";

  // Init Datepicker
  $("#datetimepicker").datetimepicker(
    {
      locale: i18nLocale == "es" ? 'es' : 'en',
      format: dateFormat,
      useCurrent: false,
      defaultDate: moment().toDate(),
      maxDate: moment().toDate()
    });

    // Disable paste and write on date field
    $(".date-field").bind("paste keypress", function(e) {
      e.preventDefault();
    });

    $("#datetimepicker").on("dp.change", function(e) {
      if ($("#purchase_datetime_picker").val() != ""){
        pickerDate = moment($("#purchase_datetime_picker").val(), dateFormat).toDate();
        $("#purchase_purchase_datetime").val(moment($("#purchase_datetime_picker").val()).format());
      }
    });

    // Datetime
    $("#purchase_datetime_picker").each(function(){
      // If not empty
      if($(this).val() != ""){
        pickerDate = moment($(this).val(), dateFormat).toDate();
        $("#purchase_purchase_datetime").val(moment($(this).val()).format());
      }
    });

    // Init Bootstrap tooltips
    $('[data-toggle="tooltip"]').tooltip();
    $('[data-tooltip="true"]').tooltip();

    // Inputs listener
    $("input.form-control").on("keyup change", function(){
      // If empty
      if($(this).val() == ""){
        $(this).removeClass("with-value"); // Remove class
      }

      else{
        $(this).addClass("with-value"); // Add class
      }
    });

    // Text area listener
    $("textarea.form-control").on("keyup change", function(){
      // If empty
      if($(this).val() == ""){
        $(this).removeClass("with-value"); // Remove class
      }

      else{
        $(this).addClass("with-value"); // Add class
      }
    });

    // Inputs search
    $("input.search-input").on("keyup change", function(){
      // If empty
      if($(this).val() == ""){
        $(this).removeClass("with-value"); // Remove class
      }

      else{
        $(this).addClass("with-value"); // Add class
      }
    });

    // Inputs
    $("input.form-control").each(function(){
      // If empty
      if($(this).val() == ""){
        $(this).removeClass("with-value"); // Remove class
      }

      else{
        $(this).addClass("with-value"); // Add class
      }
    });

    // Text area
    $("textarea.form-control").each(function(){
      // If empty
      if($(this).val() == ""){
        $(this).removeClass("with-value"); // Remove class
      }

      else{
        $(this).addClass("with-value"); // Add class
      }
    });

    // Inputs search
    $("input.search-input").each(function(){
      // If empty
      if($(this).val() == ""){
        $(this).removeClass("with-value"); // Remove class
      }

      else{
        $(this).addClass("with-value"); // Add class
      }
    });

    // Mask for price Input
    $(".price").mask("#,##0.00", {reverse: true});

    // Mask for discount Input
    $(".discount").mask("##.0");

    // Change iOS toggle status
    $("#switcher").each(function(){
      if (this.checked){
        $("#switcherToggle").addClass("active");
      }

      else{
        $("#switcherToggle").removeClass("active");
      }
    });

    $("#switcher").change(function(){
      if (this.checked){
        $("#switcherToggle").addClass("active");
      }

      else{
        $("#switcherToggle").removeClass("active");
      }
    });

    // Prevent enter on product code
    $("#product_barcode").bind("keypress keydown keyup", function(e){
      if(e.keyCode == 13){
        e.preventDefault();
      }
    });

  });
