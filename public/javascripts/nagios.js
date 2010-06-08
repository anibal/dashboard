function fetchNagiosStatus() {
  $.getJSON("/nagios_status", function(data) {
    $("#nagios-status .points").html(data.problem_count + "/" + data.system_count);
    $("#nagios-status .problems").html(data.problems.join("<br />"));

    if (_(data.problems).isEmpty()) {
      $("#nagios-status").removeClass("failure");
    }
    else {
      $("#nagios-status").addClass("failure");
    }
  });

  setTimeout("fetchNagiosStatus();", 20000);
};

$(function() {
  fetchNagiosStatus();
});
