function fetchNagiosStatus() {
  $.getJSON("/nagios_status", function(data) {
    var problemCount = parseInt(data.problem_count);
    var criticalCount = parseInt(data.critical_count);

    $("#nagios-status .points").html(problemCount + "/" + data.system_count);
    $("#nagios-status .problems").html(data.problems.join("<br />"));

    $("#nagios-status .problem-overlay").html(problemCount);
    $("#nagios-status .problem-overlay").hide();
    if (problemCount > 4) {
      $("#nagios-status .problem-overlay").show();
    }

    $("#nagios-status").removeClass("red");
    if (criticalCount > 0) {
      $("#nagios-status").addClass("red");
    }
  });

  setTimeout("fetchNagiosStatus();", 20000);
};

$(function() {
  fetchNagiosStatus();
});
