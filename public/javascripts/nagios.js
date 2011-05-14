function fetchNagiosStatus() {
  $.getJSON("/nagios_status", function(data) {
    var problemCount = parseInt(data.problem_count);
    var criticalCount = parseInt(data.critical_count);

    var problems = _.uniq(data.problems.sort(), true);
    var criticalPattern = /^C:/g;
    for(i in problems) {
      if(criticalPattern.test(problems[i])) {
        problems[i] = "<span class=\"critical\">" + problems[i] + "</span>";
      }
    }

    $("#nagios-status .points").html(problemCount + "/" + data.system_count);
    $("#nagios-status .problems").html(problems.join("<br />"));

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
