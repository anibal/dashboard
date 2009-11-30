function fetchCIStatus() {
  $.getJSON("/ci_status", function(data) {
    $(".project-status").removeClass("success").removeClass("failure").removeClass("building");

    _(data).each(function(project) {
      $(".project-status[ref = " + project["identifier"] + "]").addClass(project["status"])
    });
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

  setTimeout("updateBottomFrame();", 60000);
  $($("#content iframe")[0]).show();

  setTimeout("reload();", 1800000); 
});
