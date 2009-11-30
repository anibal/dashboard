function updateBottomFrame() {
  var newFrame = $("#bottom iframe:visible").next();
  if (newFrame.length == 0) newFrame = $("#bottom iframe")[0];
  
  $($("#bottom iframe:visible")[0]).hide();
  $(newFrame).show();
  
  setTimeout("updateBottomFrame();", 5000);
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
  setTimeout("reload();", 1800000);
  
  setTimeout("updateBottomFrame();", 10000);
  $($("#bottom iframe")[0]).show();
  
  updateMpdSong();
});