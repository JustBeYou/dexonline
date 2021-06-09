$(function() {

  function init() {
    $('.defWrapper .deleteLink').click(deleteDefinition);
    $('.bookmarkAddButton').click(addBookmark);
    $('.bookmarkRemoveButton').click(removeBookmark);
  }

  function deleteDefinition() {
    var link = $(this);
    var defId = link.data('id');

    $.get(wwwRoot + 'ajax/deleteDefinition.php?id=' + defId)
      .done(function() {
        link.closest('.defWrapper').slideUp();
      })
      .fail(function() {
        alert('A apărut o problemă la comunicarea cu serverul. Definiția nu a fost încă ștearsă.');
      });

    return false;
  }

  /************************* Bookmark-related code ***********************/

  function addBookmark() {
    var anchor = $(this);
    var span = anchor.find('span[data-pending-text]');
    var url = anchor.attr('href');

    // show loading message
    span.text(span.data('pendingText'));

    $.ajax({
      url: url,
      dataType: 'json',
      success: function (data) {
        handleAjaxResponse(data, anchor, addBookmarkSuccess, bookmarkResponseError);
      },
      error: function () {
        bookmarkResponseError(anchor);
      },
    });

    return false;
  }

  function addBookmarkSuccess(anchor) {
    var span = anchor.find('span[data-pending-text]');
    span.text(span.data('addedText'));
    anchor.addClass('disabled');
  }

  function removeBookmark(evt) {
    evt.preventDefault();

    var anchor = $(this);
    var span = anchor.find('span[data-pending-text]');
    var url = anchor.attr('href');

    // show ajax indicator
    span.text(span.data('pendingText'));

    $.ajax({
      url: url,
      dataType: 'json',
      success: function (data) {
        handleAjaxResponse(data, anchor, removeBookmarkSuccess, bookmarkResponseError);
      },
      error: function () {
        bookmarkResponseError(anchor);
      },
    });

    return false;
  }

  function removeBookmarkSuccess(anchor) {
    var defWrapper = anchor.closest('dd');
    var allDefs = anchor.closest('dl');

    // remove element from the DOM
    defWrapper.fadeOut(function() {
      $(this).remove();
      if (!allDefs.children('dd').length) {
        allDefs.text(allDefs.data('noneText'));
      }
    });
  }

  function bookmarkResponseError(anchor, msg) {
    if(msg == null) {
      msg = 'eroare la încărcare';
    }
    anchor.find('span').text(msg);
    anchor.closest('li').addClass('disabled');
  }

  function handleAjaxResponse(data, anchor, successCallback, errorCallback) {
    if (data.status == 'success') {
      successCallback(anchor);
    } else if (data.status == 'redirect') {
      window.location.replace(wwwRoot + data.url);
    } else {
      errorCallback(anchor, data.msg);
    }
  }

  init();
});

// deletes typos via Ajax and hides them from the UI
$(function() {
  $('.ignore-typo').click(function() {
    var typoId = $(this).data('typoId');
    var wrapper = $(this).closest('.typo-wrapper');

    $.get(wwwRoot + 'ajax/ignoreTypo.php', { id: typoId })
      .done(function() {
        wrapper.hide();
      })
      .fail(function() {
        alert('A apărut o problemă la comunicarea cu serverul. ' +
              'Greșeala de tipar nu a fost încă ștearsă.');
      });

    return false;
  });
});

function ifWikiPageExists(title, callback) {
  $.ajax({
    url: 'https://wiki.dexonline.ro/api.php',
    data: {
      'action': 'query',
      'titles': title,
      'format': 'json',
    },
    success: function(data) {
      // returns a -1 somewhere if the page does not exist
      if (!('-1' in data.query.pages)) {
        callback();
      }
    },
  });
}
