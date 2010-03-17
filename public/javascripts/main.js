var knownFailures = [];
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


    }
    else {
    }
  });


function updateMpdSong() {
  $("#current").load("/mpd_song");

  meetingOverlay();

  setTimeout("updateMpdSong();", 10000);
}

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
}

function reload() {
  location.href = "/";
  setTimeout("reload();", 1800000);
}

$(function() {
  fetchCIStatus();

  updateMpdSong();

  setTimeout("reload();", 1800000);
});
