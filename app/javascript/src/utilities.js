/**
 * Utility functions
 * ----------------------------------------------------
 * Description:
 * Collection of useful utility functions for script inclusion.
 *
 * Requires: jQuery
 * Documentation:
 *
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/



/* Single level object merging.
 * Merges object b into object a.
 * Returns the changed object a.
 * Does not merge nested level objects.
 * Duplicate properties overwrite existing.
 **/
function mergeObjects(a, b) {
  for(var i in b) {
    if(b.hasOwnProperty(i)) {
      a[i] = b[i]
    }
  }
  return a;
}

/* Nicety helper only, for those that prefer
 * to keep HTML strings out of code, where
 * possible.
 * e.g. instead of...
 *   var $node = $('<button class="something">Click me</button>');
 * can do...
 *   var $node = $(createElement("button", "Click me", "something"));
 * Hardly worth it, but makes code look pretty.
 **/
function createElement(tag, text, classes) {
  var node = document.createElement(tag);
  if (arguments.length > 1) {
    if(text != '' && text != undefined) {
      node.appendChild(document.createTextNode(text));
    }

    if(arguments.length > 2 && classes != '' && classes != undefined) {
      node.className = classes;
    }
  }
  return document.body.appendChild(node);
}

/* Safe way to call a function that might not exist.
 * Example:
 *   config.runMyFunction();
 *
 *   The above call might blow up if runMyFunction does not exist or
 *   is not a function. Alternatively...
 *
 *   safelyActivateFunction(runMyFunction);
 *
 *   The above call should test it is a function and
 *   run it only if that proves true.
 *
 * @func (Function) Expected to be required function.
 *
 * Function only specifies an argument for the expected function but,
 * if you pass other arguments they will be passed on to your function.
 **/
function safelyActivateFunction(func, ...args) {
  if(typeof(func) === 'function' || func instanceof Function) {
    if(args) {
      func.apply(this, args);
    }
    else {
      func();
    }
  }
}

/* Generates randomised number to add onto a passed string.
 * Useful when requiring unique ID values for dynamic elements.
 *
 * @str (String) Prefix for resulting unique string.
 **/
function uniqueString(str) {
  return str + Date.now() + String(Math.random()).replace(".","");
}

// Make available for importing.
export { mergeObjects, createElement, safelyActivateFunction, uniqueString };
