var knownFailures = [];

function fetchCIStatus() {
  $.getJSON("/project_status", function(data) {

    var newFailure = false;
    _(data).each(function(attributes, project) {
      var ciAttr = attributes.ci;
      $(".project[ref = " + project + "]").attr("class",  "project status inactive " + ciAttr.status);

      if (ciAttr.health != null) {
        $(".project[ref = " + project + "] .health").html('<img src="http://ci.trike.com.au/static/66ffcbeb/images/16x16/' + ciAttr.health + '" />');
      }

      if (ciAttr.status == "red" && !_(knownFailures).include(project)) {
        newFailure = true;
        knownFailures.push(project);
        showCIOverlay(attributes);
      }
      else if (ciAttr.status != "red" && _(knownFailures).include(project)) {
        knownFailures = _(knownFailures).without([project]);
      }
      if (!newFailure) $(".ci-failure").hide();
    });

    var projectStatus = _(data).values().map(function(item) { return item.ci.status; });
    var globalStatus = "green";
    if (_(projectStatus).include("yellow")) {
      globalStatus = "yellow";
    }
    else if (_(projectStatus).include("red")) {
      globalStatus = "red";
    }

    $("#first")
      .removeClass("green yellow red")
      .addClass(globalStatus);
  });

  setTimeout("fetchCIStatus();", 60000);
};

function showCIOverlay(project) {
  $(".ci-failure").show();

  $("#ci-failure-message .project-name").html(project.description);
  $("#ci-failure-message .project-name").effect("pulsate", { times: 10 }, 2000);
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
  else if (window.location.hash == '#friday' || (date.getDay() == 5 && date.getHours() == 12 && date.getMinutes() >= 0 && date.getMinutes() <= 10)) {
    $(".friday").show();
  }
  else {
    $(".monday, .standup, .friday").hide();
  }
};

function tickClock() {
  var now = new Date();
  $(".clock .date").html(now.toLocaleDateString());
  $(".clock .time").html(now.toLocaleTimeString());
  setTimeout("tickClock();", 200);
};

function reload() {
  location.href = "/";
  setTimeout("reload();", 1800000);
};

$(function() {
  fetchCIStatus();
  updateMpdSong();
  tickClock();
  setTimeout("reload();", 1800000);
});
