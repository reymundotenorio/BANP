//= require jquery-mask/jquery.mask

$(document).ready(function(){

  var i18nLocale = $("body").data("locale");
  var dateFormat = i18nLocale == "es" ? "DD/MM/YYYY hh:mm A" : "MM/DD/YYYY hh:mm A";

  // Init Datepicker
  $("#datetimepicker-1").datetimepicker({
    locale: i18nLocale == "es" ? 'es' : 'en',
    format: dateFormat,
    useCurrent: false,
    defaultDate: moment().subtract(1, "months").toDate()
    // ,
    // maxDate: moment().toDate()
  });

  $("#datetimepicker-2").datetimepicker({
    locale: i18nLocale == "es" ? 'es' : 'en',
    format: dateFormat,
    useCurrent: false,
    // defaultDate: moment().toDate(),
    maxDate: moment().toDate()
  });

  // Disable paste and write on date field
  $(".date-field").bind("paste keypress", function(e) {
    e.preventDefault();
  });

  $("#datetimepicker-1").on("dp.change", function(e) {
    if ($("#report_from_datetime").val() != ""){
      pickerDate = moment($("#report_from_datetime").val(), dateFormat).toDate();
      $("#from_datetime").val(moment($("#report_from_datetime").val(),dateFormat).format("YYYY-MM-DD'T'HH:mm:ss.SSSZ"));
    }

     $('#datetimepicker-2').data("DateTimePicker").minDate(e.date);
  });

  $("#datetimepicker-2").on("dp.change", function(e) {
    if ($("#report_to_datetime").val() != ""){
      pickerDate = moment($("#report_to_datetime").val(), dateFormat).toDate();
      $("#to_datetime").val(moment($("#report_to_datetime").val(),dateFormat).format("YYYY-MM-DD'T'HH:mm:ss.SSSZ"));
    }

    $('#datetimepicker-1').data("DateTimePicker").maxDate(e.date);
  });

  // Datetime
  $("#report_from_datetime").each(function(){
    // If not empty
    if($(this).val() != ""){
      pickerDate = moment($(this).val(), dateFormat).toDate();
      $("#from_datetime").val(moment($(this).val(), dateFormat).format("YYYY-MM-DD'T'HH:mm:ss.SSSZ"));
    }
    else{
      if($("#from_datetime").val() != ""){
        $(this).val(moment($("#from_datetime").val(), "YYYY-MM-DD'T'HH:mm:ss.SSSZ").format(dateFormat));
      }
    }
  });

  // Datetime
  $("#report_to_datetime").each(function(){
    // If not empty
    if($(this).val() != ""){
      pickerDate = moment($(this).val(), dateFormat).toDate();
      $("#to_datetime").val(moment($(this).val(), dateFormat).format("YYYY-MM-DD'T'HH:mm:ss.SSSZ"));
    }
    else{
      if($("#to_datetime").val() != ""){
        $(this).val(moment($("#to_datetime").val(), "YYYY-MM-DD'T'HH:mm:ss.SSSZ").format(dateFormat));
      }
    }
  });





});
