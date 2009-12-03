function fetchCIStatus() {
  $.getJSON("/ci_status", function(data) {
    $(".project-status").remove();

    var failures = [];
    _(data).each(function(project) {
      if (project.status == "failure") failures[failures.length] = project;
      $("#left").append(' \
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
      $(".overlay").show();

      var first = failures.shift();

      var failingProjects = _(failures).inject(first.name + "(" + first.label + ")", function(res, project) {
        return (res + ", " + project.name + "(" + project.label + ")")
      });
      $("#ci-failure-message .project-name").html(failingProjects);

      var projectAuthors ="(" + _(failures).inject(first.author, function(res, project) {
        return (res + ", " + project.author)
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

function reload() {
  location.href = "/";
  setTimeout("reload();", 1800000);
}

$(function() {
  fetchCIStatus();

  updateMpdSong();

  setTimeout("reload();", 1800000);
});
