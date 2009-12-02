function fetchCIStatus() {
  $.getJSON("/ci_status", function(data) {
    $(".project-status").remove();

    var failures = [];
    _(data).each(function(project) {
      if (project["status"] == "failure") failures[failures.length] = project;
      $("#header .top").append(' \
        <div class="project-status ' + project["status"] + '"> \
          <span class="identifier">' + project["identifier"] + '</span> \
          <span class="time">' + project["time"] + '</span> \
        </div>');
    });

    if (!_(failures).isEmpty()) {
      $(".overlay").show();

      var first = failures.shift();

      var failingProjects = _(failures).inject(first["name"] + "(" + first["label"] + ")", function(res, project) {
        return (res + ", " + project["name"] + "(" + project["label"] + ")")
      });
      $("#ci-failure-message .project-name").html(failingProjects);

      var projectAuthors ="(" + _(failures).inject(first["author"], function(res, project) {
        return (res + ", " + project["author"])
      }) + ")";
      $("#ci-failure-message .author").html(projectAuthors);
    }
    else {
      $(".overlay").hide();
    }
  });

  setTimeout("fetchCIStatus();", 30000);
}

function updateMpdSong() {
  $("#current").load("/mpd_song");
  setTimeout("updateMpdSong();", 10000);
}

function updateBottomFrame() {
  var newFrame = $("#content iframe:visible").next();
  if (newFrame.length == 0) newFrame = $("#content iframe")[0];

  $($("#content iframe:visible")[0]).hide();
  $(newFrame).show();

  setTimeout("updateBottomFrame();", 60000);
}

function reload() {
  location.href = "/";
  setTimeout("reload();", 1800000);
}

$(function() {
  fetchCIStatus();

  updateMpdSong();

  // setTimeout("updateBottomFrame();", 60000);
  $($("#content iframe")[0]).show();

  setTimeout("reload();", 1800000);
});
