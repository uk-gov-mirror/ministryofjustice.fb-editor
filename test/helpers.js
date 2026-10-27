/* Helpers for use across all test scripts can go here.
 * To use them, require this file in your local test
 * helpers.js file and add to the module.exports. When
 * requiring local helpers.js file in your actual tests,
 * these helpers should be made available as helpers.blah
 *
 **/

/* Due to jQueryUI Dialog we cannot identify the added buttons
 * (they have no class, etc) but we can loop over all buttons
 * to match text we seek to get a 'best guess' type of test.
 **/
function findButtonByText($dialog, text) {
  var $buttons = $dialog.find(".ui-button");
  var $button = $(); // Reduce errors by returning blank jQuery object when nothing found.
  $buttons.each(function() {
    var $this = $(this);
    if($this.text() == text) {
      $button = $this;
      return false;
    }
  });
  return $button;
}

function createServer(config) {
  conf = {
    respondImmediately: true,
  }

  if(config) {
    for(var prop in config) {
      if(config.hasOwnProperty(prop)) {
        conf[prop] = config[prop];
      }
    }
  }

  const nise = require('nise');

  server = nise.fakeServerWithClock.create(conf);
  window.XMLHttpRequest = global.XMLHttpRequest;
  return server;
}

function mergeConfig(defaultConfig, extraConfig) {
  for(var prop in extraConfig || {}) {
    if(extraConfig.hasOwnProperty(prop)) {
      defaultConfig[prop] = extraConfig[prop];
    }
  }

  return defaultConfig;
}

/* Allows a keyboard event to be programatically created.
 * @key  (String) Name of key pressed, e.g. "Enter", or "a"
 * @code (Integer) Number of character code, e.g. 13, or 65
 * @opts (Object) Provides ability to manually override any of the default options.
 *                e.g. { shiftKey: true }
 *
 * Example uses:
 *
 * var activateButtonWithEnterKey = keyDownEvent("Enter", 13 );
 * document.getElementById("some-button").dispatchEvent(activateButtonWithEnterKey);
 *
 * var keyboardDidSomething = keyDownEvent("a", 65, { shiftKey: true } );
 * window.dispatchEvent(keyboardDidSomething);
 *
 **/
function keyDownEvent(key, code, opts) {
  var options = mergeConfig({
                   key: key,
                   keyCode: code,
                   code: key,
                   which: code,
                   shiftKey: false,
                   ctrlKey: false,
                   metaKey: false
                 }, opts);

  return new window.KeyboardEvent("keydown", options);
}

module.exports = {
  findButtonByText: findButtonByText,
  createServer: createServer,
  mergeConfig: mergeConfig,
  keyDownEvent: keyDownEvent
}
