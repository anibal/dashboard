$(function() {
  $("#project-select").change(function() {
    $("form .iterations").remove();

    var project_id = $(this).find("option:selected").attr("value");
    if (project_id != "0") {
      $(".iterations[ref = " + project_id + "]").clone().appendTo($("form .project-wrap")).removeClass("hidden");
    }
  });

  $("#save-hours").click(function() {
    $("#error").html("");
    var project_id = $("#project-select").find("option:selected").attr("value");
    var iteration_id = $("form .iterations").find("option:selected").attr("value");
    var hours = $("#hours").val().trim();
    var income = $("#income").val().trim();

    if (project_id == "0") {
      $("#error").html("Please select a project.");
    }
    else if (hours.length == 0) {
      $("#error").html("Please provide the hours worked in the selected iteration.");
    }
    else if (hours.match(/^\d+$/) == null) {
      $("#error").html("Please provide the hours worked in a valid format: No decimal digits, No dollar sign.");
    }
    else if (income.length > 0 && income.match(/^\d+$/) == null) {
      $("#error").html("Please provide the money earned in a valid format: No decimal digits, No dollar sign.");
    }
    else {
      $.ajax({
        type: "PUT",
        url: "/projects/" + project_id + "/iterations/" + iteration_id,
        data: {
          hours: hours,
          income: income
        },
        success: function() {
          alert("Update successful!");
          $("#hours").val("");
          $("#income").val("");
        }
      });
    }
  });
});
