$(function() {
  // Set up AJAX persisted "billed" check-boxes
  $("input.toggle-billed").click(function(e) {
    var form = $(this).parent();
    var data = form.serialize();
    var handleError = function(XMLHttpRequest, textStatus, errorThrown) {
      alert("Setting build state didin't work, try again in 5 minutes?");
    };

    $.ajax({
      data:   data,
      error:  handleError,
      url:    form.attr('action'),
      type:   'POST'
    });
  });

  // Fix widths of floating headers in report table.
  // Floating header cell widths do not match table column widths because the
  // CSS positioning ejects it from the table layout.  We double-render the
  // header, once hidden as a filler to provide reference widths and a space
  // for the floating header to sit at the top of the table.
  var rowWidth = 0;
  $.each($("#timereport thead tr.header th"), function(index, cell) {
    var refCell = $("#timereport thead tr.filler th:eq(" + index + ")");
    $(cell).css('width', refCell.width());
    rowWidth += refCell.outerWidth();
  });
  $("#timereport thead tr.header").css('width', rowWidth);
});
