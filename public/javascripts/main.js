var knownFailures = [];
var knownProblems = [];

function fetchCIStatus() {
  $.getJSON("/ci_status", function(data) {
    $(".project").remove();

    var newFailure = false;
    _(data).each(function(project) {
      if (project.status == "failure" && !_(knownFailures).include(project)) {
        newFailure = true;
        showCIOverlay(project);
      }
      else if (project.status != "failure" && _(knownFailures).include(project)) {
        knownFailures = _(knownFailures).without([project]);
      }
      if (!newFailure) $(".ci-failure").hide();

      $("#first").append(' \
        <div class="project status ' + project.status + '"> \
          <div class="identifier">' + project.name + '</div> \
          <div class="info"> \
            ' + project.label + '<br /> \
            ' + project.author + '<br /> \
            ' + project.time + ' \
          </div> \
        </div>');
    });
  });

  setTimeout("fetchCIStatus();", 30000);
};

function showCIOverlay(project) {
  knownFailures.push(project);
  $(".ci-failure").show();

  $("#ci-failure-message .project-name").html(project.name);
  $("#ci-failure-message .project-name").effect("pulsate", { times: 10 }, 2000);
  $("#ci-failure-message .author").html(project.author);
};

function fetchNagiosStatus() {
  $.getJSON("/nagios_status", function(data) {
    $("#nagios-status .system-count").html(data.system_count);
    $("#nagios-status .problem-count").html(data.problem_count);
    $("#nagios-status .problems").html(data.problems.join(", "));

    if (_(data.problems).isEmpty()) {
      $("#nagios-status").removeClass("failure");
    }
    else {
      $("#nagios-status").addClass("failure");
    }

    var newProblem = false;
    _(data.problems).each(function(problem) {
      if (!_(knownProblems).include(problem)) {
        newProblem = true;
        showNagiosOverlay(problem);
      }
      else if (_(knownProblems).include(problem)) {
        knownProblems = _(knownProblems).without([problem]);
      }
      if (!newProblem) $(".nagios-failure").hide();
    });
  });

  setTimeout("fetchNagiosStatus();", 50000);
};

function showNagiosOverlay(system) {
  knownProblems.push(system);
  $(".nagios-failure").show();

  $("#nagios-failure-message .system-name").html(system);
  $("#nagios-failure-message .system-name").effect("pulsate", { times: 10 }, 2000);
};

function updateMpdSong() {
  $("#current").load("/mpd_song");

  meetingOverlay();

  setTimeout("updateMpdSong();", 10000);
};

function meetingOverlay() {
  var date = new Date();

  if (date.getDay() == 1 && date.getHours() == 10 && date.getMinutes() >= 0 && date.getMinutes() < 30) {
    $(".monday").show();
  }
  else if (date.getHours() == 10 && date.getMinutes() >= 0 && date.getMinutes() < 10) {
    $(".standup").show();
  }
  else {
    $(".monday, .standup").hide();
  }
};

function reload() {
  location.href = "/";
  setTimeout("reload();", 1800000);
};

$(function() {
  fetchCIStatus();
  fetchNagiosStatus();

  updateMpdSong();

  setTimeout("reload();", 1800000);
});
