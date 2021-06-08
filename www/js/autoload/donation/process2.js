$(function() {

  $('input[name="processTicketId[]"]').change(toggleMessageCheckbox);

  // The send email checkbox is conditioned on the process ticket checkbox.
  function toggleMessageCheckbox() {
    if (!$(this).prop('checked')) {
      $(this)
        .closest('.card-body')
        .find('input[name="messageTicketId[]"]')
        .prop('checked', false);
    }
  }

});
