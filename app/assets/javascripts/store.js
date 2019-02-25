// Subtract button on cart details
$(".subtract").click(function(){
  var $input = $(this).next();
  var currentValue = parseInt($input.val());

  if(currentValue > 1){
    $input.val(currentValue - 1);
  }

  if ($input.val().length <= 0){
    $input.val(1);
  }
});
// End Subtract button on cart details

// Add button on cart details
$(".add").click(function(){
  var $input = $(this).prev();
  var currentValue = parseInt($input.val());

  $input.val(currentValue + 1);

  if ($input.val().length <= 0){
    $input.val(1);
  }
});
// End Add button on cart details
