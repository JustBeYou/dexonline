$(function() {
  var stem = null;

  function init() {
    stem = $('#stem').detach();

    $('.ambigAbbrev').each(function() {
      var e = stem.children().clone();
      e.find('.text').html($(this).html());
      $(this).replaceWith(e);
    });
    $('.ambigAbbrev button').click(pushAbbrevButton);

    $('#reviewForm').submit(collectActions);
    $('#sourceId').change(function() { this.form.submit() });
    updateSaveButtonState();

    $(document).bind('keydown', '1', pressNextLeftArrow);
    $(document).bind('keydown', '2', pressNextRightArrow);
  }

  function pushAbbrevButton() {
    var span = $(this).siblings('span');
    var isAbbrev = parseInt($(this).data('abbrev'));
    $(this).closest('.ambigAbbrev').attr('data-action', isAbbrev);

    if (isAbbrev) {
      span.removeClass('previewWord').addClass('previewAbbrev');
    } else {
      span.removeClass('previewAbbrev').addClass('previewWord');
    }

    $(this).siblings('button').addBack().removeClass('btn-primary').addClass('btn-light');
    updateSaveButtonState();
  }

  // enables the Save button if there are no more decisions to make
  function updateSaveButtonState() {
    var numLeft = $('.ambigAbbrev[data-action=""]').length;
    if (!numLeft) {
      $('button[name="saveButton"]').removeAttr('disabled');
    }
  }

  function collectActions() {
    var actions = [];
    $('.ambigAbbrev').each(function() {
      actions.push($(this).data('action'));
    });

    $('input[name=actions]').val(JSON.stringify(actions));
  }

  function pressNextLeftArrow() {
    $('.ambigAbbrev[data-action=""] button[data-abbrev="1"]').first().click();
  }

  function pressNextRightArrow() {
    $('.ambigAbbrev[data-action=""] button[data-abbrev="0"]').first().click();
  }

  init();

});
