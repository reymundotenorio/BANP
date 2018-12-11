//= require JsBarcode/JsBarcode.all.min

$(document).on("turbolinks:load", function(){

JsBarcode(".barcode").init();

});