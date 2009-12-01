function fetchCIStatus() {
  $.getJSON("/ci_status", function(data) {
    $(".project-status").remove();

    var failures = [];
    _(data).each(function(project) {
      if (project["status"] == "failure") failures[failures.length] = project;
      $("#header .top").append('<div class="project-status ' + project["status"] + '">' + project["identifier"] + '</div>');
    });

    if (!_(failures).isEmpty()) {
      $(".overlay").show();

      var first = failures.shift();
      $("#ci-failure-message .project-name").html(_(failures).inject(first["name"], function(res, project) { return (res + ", " + project["name"]) }));
      $("#ci-failure-message .author").html(_(failures).inject(first["author"], function(res, project) { return (res + ", " + project["author"]) }));
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
