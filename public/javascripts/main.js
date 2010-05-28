var knownFailures = [];

function fetchCIStatus() {
  $.getJSON("/project_status", function(data) {

    var newFailure = false;
    _(data).each(function(attributes, project) {
      var ciAttr = attributes.ci;

      if (ciAttr.status == "failure" && !_(knownFailures).include(project)) {
        newFailure = true;
        knownFailures.push(project);
        showCIOverlay(attributes);
      }
      else if (ciAttr.status != "failure" && _(knownFailures).include(project)) {
        knownFailures = _(knownFailures).without([project]);
      }
      if (!newFailure) $(".ci-failure").hide();

      var projectElement = $(".project[ref = " + project + "]");
      projectElement.attr("class", "project status " + ciAttr.status + " " + ciAttr.activity);
      projectElement.find(".ci .message").html(ciAttr.message);
      projectElement.find(".ci .author").html("by <i>" + ciAttr.author + "</i> " + ciAttr.time);
    });
  });

  setTimeout("fetchCIStatus();", 60000);
};

function showCIOverlay(project) {
  $(".ci-failure").show();

  $("#ci-failure-message .project-name").html(project.name);
  $("#ci-failure-message .project-name").effect("pulsate", { times: 10 }, 2000);
  $("#ci-failure-message .author").html(project.ci.author);
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
  else if (date.getDay() == 5 && date.getHours() == 12 && date.getMinutes() >= 20 && date.getMinutes() < 30) {
    $(".friday").show();
  }
  else {
    $(".monday, .standup, .friday").hide();
  }
};

function reload() {
  location.href = "/";
  setTimeout("reload();", 1800000);
};

$(function() {
  fetchCIStatus();
  updateMpdSong();
  setTimeout("reload();", 1800000);
});
