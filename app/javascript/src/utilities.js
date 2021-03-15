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
  if (arguments.length > 1 && text != '' && text != undefined) {
    node.appendChild(document.createTextNode(text));
    if(arguments.length > 2 && classes != '' && classes != undefined) {
      node.className = classes;
    }
  }
  return document.body.appendChild(node);
}

// Make available for importing.
export { mergeObjects, createElement };
