var graphPages = ["https://github.com/tricycle/kando/graphs/punch_card",
                  "https://github.com/tricycle/kando/graphs/traffic",
                  "https://github.com/tricycle/kando/graphs/impact",
                   "http://www.pivotaltracker.com/reports/point_count/iteration?iteration_designation=current&project_id=25033&chart_type=current_iteration",
                   "http://www.pivotaltracker.com/reports/point_count/iteration?iteration_designation=current&project_id=40441&chart_type=current_iteration",
                   ];
var graphPagesCount = graphPages.length - 1;
var graphIndex = 0;

function updateGraphFrame() {
  graphIndex++;
  if (graphIndex > graphPagesCount) graphIndex = 0;
  
  $("#github").attr("src", graphPages[graphIndex]);
  setTimeout("updateGraphFrame();", 60000);
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
  setTimeout("updateGraphFrame();", 60000);
  updateMpdSong();
});