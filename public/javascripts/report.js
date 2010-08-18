$(function() {
  $("input.toggle-billed").click(function(e) {
    var form = $(this).parent();
    var data = form.serialize();
    var handleError = function(XMLHttpRequest, textStatus, errorThrown) {
      console.log("Didn't work!");

    };

    $.ajax({
      data:   data,
      error:  handleError,
      url:    form.attr('action'),
      type:   'POST'
    });
  });
});
