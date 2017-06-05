$(function() {
  const WORD_LIST_DIA_URL = 'https://dexonline.ro/static/download/game-word-list-dia.txt';
  const WORD_LIST_URL = 'https://dexonline.ro/static/download/game-word-list.txt';
  const ALPHABET = 'aăâbcdefghiîjklmnopqrsștțuvwxyz';

  const MODE_WORD_SEARCH = 0;
  const MODE_ANAGRAM = 1;
  
  const CANVAS_WIDTH = 480;
  const CANVAS_HEIGHT = 320;
  const TILE_WIDTH = 55;
  const TILE_PADDING = 10;
  const END_FONT_SIZE = 60;
  const TOP_Y = 50;
  const BOTTOM_Y = 200;
  const THRESHOLD_Y = 120;
  const VERIFY_BUTTON_Y = 290;

  const ANIMATION_SPEED = 200;
  const GAME_OVER_ANIMATION_SPEED = 600;

  var letters;    // letter set
  var legalWords; // words that can be made from the letter set
  var wordsFound; // boolean array indicating which legal words the user has found
  var upLayers;   // top row tiles
  var downLayers; // bottom row tiles
  var wordStem;   // div to be cloned for every legal word
  var wordList, wordListDia; // word lists downloaded from server, without and with diacritics
  var gameParams; // main menu options

  // runs only once on page load
  function init() {
    $('#startGameButton').click(startGame);
    $('#restartGameButton').click(restartGame);
    wordStem = $('#wordStem').detach().removeAttr('id');

    // download word lists
    $.when($.get(WORD_LIST_URL),
           $.get(WORD_LIST_DIA_URL))
      .then(function(result, resultDia) {
        wordList = result[0].trim().split('\n');
        wordListDia = resultDia[0].trim().split('\n');
        $('#startGameButton').prop('disabled', false);
      })
      .fail(function() {
        console.log('Nu pot descărca listele de cuvinte.');
      });
  }

  // runs whenever a new game starts
  function startGame() {
    gameParams = {
      mode: parseInt($('.active input[name="mode"]').val()),
      level: parseInt($('.active input[name="level"]').val()),
      useDiacritics: parseInt($('.active input[name="useDiacritics"]').val()),
      seconds: parseInt($('.active input[name="seconds"]').val()),
    };

    getNewLetters();

    $('#wordCountDiv').toggle(gameParams.mode == MODE_WORD_SEARCH);
    $('#mainMenu').hide();
    $('#gamePanel').show();
    $('#score').text('0');
    $('#foundWords').text('0');
    $('#maxWords').text(legalWords.length);
        
    $(document).keypress(letterHandler);
    $(document).keydown(specialKeyHandler);
    startTimer();
  }

  // generate a letter set
  function getLetters(wordList, level) {
    var s;

    // choose a random word
    do {
      s = wordList[Math.floor(Math.random() * wordList.length)];
    } while (s.length != level);

    // shuffles the letters
    var a = s.split('');

    for (var i = a.length - 1; i; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var tmp = a[i];
      a[i] = a[j];
      a[j] = tmp;
    }

    return a.join('');
  }

  // builds the frequency table of a string
  function frequencyTable(s) {
    var f = [];

    for (var i = 0; i < ALPHABET.length; i++) {
      f[ALPHABET[i]] = 0;
    }
    for (var i = 0; i < s.length; i++) {
      f[s[i]]++;
    }

    return f;
  }

  // builds the legal words list constrained by the frequency table
  function getLegalWords(wordList, limit) {
    legalWords = [];
    wordsFound = [];

    for (var i in wordList) {
      var len = wordList[i].length;

      if ((gameParams.mode != MODE_ANAGRAM) || (len == letters.length)) {
        var legal = true;
        var f = [];

        // increment frequencies for the word being examined
        var j = 0;
        while ((j < len) && legal) {
          var char = wordList[i][j];
          f[char] = 1 + ((char in f) ? f[char] : 0);
          if (f[char] > limit[char]) {
            legal = false;
          }
          j++;
        }
        if (legal) {
          legalWords.push(wordList[i]);
          wordsFound.push(false);
        }
      }
    }
  }

  // generate new letters at the game start or in anagram mode
  function getNewLetters() {
    var wl = gameParams.useDiacritics ? wordListDia : wordList;
    letters = getLetters(wl, gameParams.level);
    var limit = frequencyTable(letters);
    getLegalWords(wl, limit);
    writeLegalWords();
    drawLetters();
  }

  // returns the X coordinate for a tile in the index-th position
  function getTileX(index) {
    var wp = TILE_WIDTH + TILE_PADDING;
    return (CANVAS_WIDTH + wp * (2 * index - letters.length + 1)) / 2;
  }

  function letterHandler(event) {
    var key = String.fromCharCode(event.charCode).toLowerCase();

    if (key.match(/[a-zăîșțâ]/g)) {
      // move a tile down if the letter matches
      var i = 0;
      while ((i < upLayers.length) &&
             (!upLayers[i] || (upLayers[i].data.letter != key))) {
        i++;
      }

      if (i < upLayers.length) {
        gather(i);
      }
    }
  }

  function specialKeyHandler(event) {
    var keyCode = event.keyCode;

    if (keyCode == 13) { // enter
      scoreWord();
    } else if (keyCode == 8) { // backspace
      scatterLastBottom();
    } else if (keyCode == 27) { // esc
      scatterBottomRow();
    }
  }

  function scoreWord() {
    // assemble the word
    var word = '';
    for (var k = 0; k < downLayers.length; k++) {
      if (downLayers[k]) {
        word += downLayers[k].data.letter;
      }
    }

    // look for a legal word that the user has not already found
    var i = 0;
    while ((i < legalWords.length) &&
           ((legalWords[i] != word) || wordsFound[i])) {
      i++;
    }

    if (i < legalWords.length) {
      // found one
      wordsFound[i] = true;

      var score = (gameParams.mode == MODE_ANAGRAM) ? 1 : (5 * word.length);
      $('#score').text(score + parseInt($('#score').text()));

      if (gameParams.mode == MODE_WORD_SEARCH) {
        $('#foundWords').text(1 + parseInt($('#foundWords').text()));
        $('#legalWord-' + i)
          .find('a')
          .removeClass('text-danger').addClass('text-success')
          .find('i')
          .removeClass('glyphicon-remove').addClass('glyphicon-ok');
        scatterBottomRow();
      } else {
        getNewLetters();
      }
    }
  }

  // animates the given layer on the index-th position on the top row (top = true)
  // or bottom row (top = false)
  function animateTile(layer, index, top) {
    $('canvas').animateLayer(layer, {
      x: getTileX(index),
      y: (top ? TOP_Y : BOTTOM_Y),
    }, ANIMATION_SPEED);
  }

  // moves the letter at position pos on row1 to the first open slot on row2
  function moveTile(pos, row1, row2, top) {
    if (row1[pos]) {
      var i = 0;
      while (row2[i]) {
        i++;
      }
      row2[i] = row1[pos];
      row1[pos] = 0;

      animateTile(row2[i], i, top);
    }
  }

  // moves the letter at position pos on the top row to the first open slot on the bottom row
  function gather(pos) {
    moveTile(pos, upLayers, downLayers, false);
  }

  // sends the letter at position pos on the bottom row back to the top row
  function scatter(pos) {
    moveTile(pos, downLayers, upLayers, true);
  }

  // sends letters on the bottom row back to the top row
  function scatterLastBottom() {
    var j = downLayers.length - 1;
    while ((j >= 0) && !downLayers[j]) {
      j--;
    }
    if (j >= 0) {
      scatter(j);
    }
  }

  // sends letters on the bottom row back to the top row
  function scatterBottomRow() {
    for (var j = 0; j < downLayers.length; j++) {
      if (downLayers[j]) {
        scatter(j);
      }
    }
  }

  // returns a string in the form m:ss
  function minutesAndSeconds(time) {
    var m = Math.floor(time / 60),
        s = time - m * 60;
    return (s >= 10)
      ? (m + ':' + s)
      : (m + ':0' + s);
  }

  function startTimer() {
    var secondsLeft = gameParams.seconds;
    var timer = setInterval(decrementTimer, 1000);

    $('#timer').text(minutesAndSeconds(secondsLeft));

    function decrementTimer() {
      secondsLeft--;
      $('#timer').text(minutesAndSeconds(secondsLeft));
      if (!secondsLeft) {
        clearInterval(timer);
        endGame();
      }
    }
  }

  // called when a drag goes beyond the canvas
  function dragCancel(layer) {
    for (var i in upLayers) {
      if (upLayers[i] == layer) {
        animateTile(layer, i, true);
      }
    }
    for (var i in downLayers) {
      if (downLayers[i] == layer) {
        animateTile(layer, i, false);
      }
    }
  }

  // called when a drag terminates normally
  function dragStop(layer) {
    var srcTop; // was the tile originally top or bottom?
    var destTop = (layer.y < THRESHOLD_Y); // was the tile dragged to the top or bottom?
    var move = false;

    var index = 0;
    while ((index < upLayers.length) && (upLayers[index] != layer)) {
      index++;
    }

    if (index < upLayers.length) {
      srcTop = true;
    } else {
      srcTop = false;
      index = 0;
      while (downLayers[index] != layer) {
        index++;
      }
    }

    if (srcTop == destTop) {
      // tile dragged on the same row -- just send it back
      animateTile(layer, index, srcTop);
    } else if (destTop) {
      scatter(index);
    } else {
      gather(index);
    }
  }

  // draws letters and creates layers
  function drawLetters() {
    upLayers = [];
    downLayers = [];

    $('canvas').removeLayers().drawLayers();

    for (var i = 0; i < letters.length; i++) {

      $('canvas').drawImage({
        name: 'tile' + i,
        layer: true,
        source: wwwRoot + 'img/scramble/' + letters[i] + '.png',
        x: getTileX(i),
        y: TOP_Y,
        data: {
          letter: letters[i],
        },
        draggable: true,
        dragcancel: dragCancel,
        dragstop: dragStop,
        bringToFront: true,
      });

      var l = $('canvas').getLayer('tile' + i);
      upLayers.push(l);
      downLayers.push(0);
    }

    drawVerifyButton();
  }

  function drawVerifyButton() {
    $('canvas').drawImage({
      layer: true,
      source: wwwRoot + 'img/scramble/verify-button.png',
      x: CANVAS_WIDTH / 2,
      y: VERIFY_BUTTON_Y,
      click: scoreWord,
      touchend: scoreWord,
    });
  }

  function writeLegalWords() {
    $('#legalWords').empty();

    for (var i in legalWords) {
      var w = legalWords[i];
      var div = wordStem.clone(true)
          .attr('id', 'legalWord-' + i)
          .appendTo('#legalWords');

      var href = div.find('a').attr('href');
      div.find('a').attr('href', href + w);

      div.find('span').text(w);
    }
  }

  function endGame() {
    // unbind key listeners
    $(document).unbind('keypress', letterHandler);
    $(document).unbind('keydown', specialKeyHandler);

    // show the legal words
    $('#wordListPanel').slideDown();

    $('#restartGameButton').show();

    // animate the 'The end' text
    $('canvas')
      .removeLayers()
      .drawLayers()
      .drawText({
        layer: true,
        name: 'gameOverText',
        fillStyle: '#ddd',
        strokeStyle: '#222',
        x: 2 * CANVAS_WIDTH,
        y: CANVAS_HEIGHT,
        fontSize: END_FONT_SIZE,
        fontFamily: 'Verdana, sans-serif',
        text: 'Sfârșit',

      })
      .animateLayer('gameOverText', {
        x: CANVAS_WIDTH / 2,
        y: CANVAS_HEIGHT / 2,
        rotate: '+=360',
      }, GAME_OVER_ANIMATION_SPEED);
  }

  function restartGame() {
    $('#mainMenu').show();
    $('#gamePanel').hide();    
    $('#wordListPanel').hide();
    $('#restartGameButton').hide();
  }

  init();
});
