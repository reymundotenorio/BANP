$(document).ready(function(){

  // Select Employee
  $(".select-employee").each(function(){

    $(this).click(function(){
      employee_id = $(this).attr("data-id");
      employee_name = $(this).attr("data-name");
      
      $("#report_employee").val(employee_name).change();
      $("#report_employee_id").val(employee_id);

      $("#search-input").val("");
      $("#getEmployees").modal("hide");
    });

  });


});
