var githubPages = ["https://github.com/tricycle/kando/graphs/punch_card",
                   "https://github.com/tricycle/kando/graphs/traffic",
                   "https://github.com/tricycle/kando/graphs/impact"];
var githubPagesCount = githubPages.length - 1;
var githubIndex = 0;

function updateGithubFrame() {
  githubIndex++;
  if (githubIndex > githubPagesCount) githubIndex = 0;
  
  $("#github").attr("src", githubPages[githubIndex]);
  setTimeout("updateGithubFrame();", 60000);
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
  setTimeout("updateGithubFrame();", 60000);
  updateMpdSong();
});