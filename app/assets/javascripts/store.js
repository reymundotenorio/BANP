$(".add").click(function(){
  var $input = $(this).prev();
  var currentValue = parseInt($input.val());

  var $colParent = $(this).closest(".info-column");
  var $totalSpan = $colParent.next().children("span");
  var price = parseFloat($colParent.prev().children("span").text());

  $input.val(currentValue + 1);

  if ($input.val().length <= 0){
    $input.val(1)
  }

  $input.trigger("change");

  // var total = $input.val()*price;
  // $totalSpan.text(total.toFixed(2).toString());
});

$(".subtract").click(function(){
  var $input = $(this).next();
  var currentValue = parseInt($input.val());

  var $colParent = $(this).closest(".info-column");
  var $totalSpan = $colParent.next().children("span");
  var price = parseFloat($colParent.prev().children("span").text());

  if(currentValue > 1){
    $input.val(currentValue - 1);
  }

  if ($input.val().length <= 0){
    $input.val(1)
  }

  $input.trigger("change");

  // var total = $input.val()*price;
  // $totalSpan.text(total.toFixed(2).toString());
});

// $(".q-input").focusout(function(){
//   var $colParent = $(this).closest(".info-column");
//   var $totalSpan = $colParent.next().children("span");
//   var price = parseFloat($colParent.prev().children("span").text());
//   var total = $(this).val()*price;
//
//   if ($(this).val().length <= 0 || $(this).val() <= 0){
//     $(this).val(1);
//     total = $(this).val()*price;
//     $totalSpan.text(total.toFixed(2).toString());
//   }else {
//     $totalSpan.text(total.toFixed(2).toString());
//   }
// });

// new Card({
//   form: document.querySelector("#card-form"),
//   container: ".card-wrapper"
// });
