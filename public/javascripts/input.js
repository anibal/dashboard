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

    if (project_id == "0") {
      $("#error").html("Please select a project.");
    }
  });
});
