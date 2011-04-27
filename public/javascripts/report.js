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
});
