function fetchCIStatus() {
  $.getJSON("/ci_status", function(data) {
    $(".project-status").remove();

    var failures = [];
    _(data).each(function(project) {
      if (project.status == "failure") failures[failures.length] = project;
      $("#right").append(' \
        <div class="project-status ' + project.status + '"> \
          <div class="identifier">' + project.identifier + '</div> \
          <div class="info"> \
            ' + project.label + '<br /> \
            ' + project.author + '<br /> \
            ' + project.time + ' \
          </div> \
        </div>');
    });

    if (!_(failures).isEmpty()) {
      $(".ci-failure").show();

      var first = failures.shift();

      var failingProjects = _(failures).inject(first.name + " (" + first.label + ")", function(res, project) {
        return (res + ", " + project.name + " (" + project.label + ")")
      });
      $("#ci-failure-message .project-name").html(failingProjects);
      $("#ci-failure-message .project-name").effect("pulsate", { times: 10 }, 2000);

      var projectAuthors ="(" + _(failures).inject(first.author, function(res, project) {
        return (res + ", " + project.author)
      }) + ")";
      $("#ci-failure-message .author").html(projectAuthors);
    }
    else {
      $(".ci-failure").hide();
    }
  });

  setTimeout("fetchCIStatus();", 30000);
}

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
