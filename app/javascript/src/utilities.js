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
 * Returns a new object without storing references
 * to any existing contained object or values.
 *
 * Notes:
 * - Does not merge nested level objects.
 * - Duplicate properties overwrite existing.
 * @a      (Object) Receives key/values (overwriting it's own).
 * @b      (Object) Gives key/values, remaining unchanged.
 * @ignore (Array)  List of strings expected to match unwanted keys.
 **/
function mergeObjects(a, b, ignore) {
  for(var i in b) {
    if(b.hasOwnProperty(i)) {
      if(ignore && ignore.includes(i)) {
        continue;
      }
      a[i.toString()] = b[i]
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
  if(isFunction(func)) {
    if(args) {
      func.apply(this, args);
    }
    else {
      func();
    }
  }
}


/* Expects a function but returns true/false depending on valid passed argument.
 **/
function isFunction(func) {
  return typeof(func) === 'function' || func instanceof Function;
}

/* Generates randomised number to add onto a passed string.
 * Useful when requiring unique ID values for dynamic elements.
 *
 * @str (String) Prefix for resulting unique string.
 **/
function uniqueString(str) {
  return str + Date.now() + String(Math.random()).replace(".","");
}


/* Utility funciton
 * Return the fragment identifier value from a URL.
 * Intended for use on an href value rather than document
 * location, which can use location.hash.
 * e.g. pass in
 * "http://foo.com#something" or
 * "http://foo.com#something?else=here"
 * and get "something" in either case.
 **/
function findFragmentIdentifier(url) {
  return url.replace(/^.*#(.*?)(?:(\?).*)?$/, "$1");
}


/* Gets value from <meta /> tag
 **/
function meta(name) {
  var meta = document.querySelector('meta[name=' + name + ']');
  return meta && meta.content;
}


/* Send POST request with token.
 * Can be used for sending Rails style delete links.
 * e.g. post('/path/to/some/resource', { _method: 'delete' });
 **/
function post(url, data) {
  var param = meta("csrf-param");
  var token = meta("csrf-token");
  var form = document.createElement("form");
  var params = {};

  params = mergeObjects(params, data);
  params[param] = token;

  form.setAttribute("action", url);
  form.setAttribute("method", "post");
  document.body.appendChild(form);

  // Add params.
  for(var param in params) {
    if(params.hasOwnProperty(param)) {
      let input = document.createElement("input");
      input.setAttribute("type", "hidden");
      input.setAttribute("name", param);
      input.setAttribute("value", params[param]);
      form.appendChild(input);
    }
  }
  form.submit();
}


/* Function used to update (or create if does not exist) a hidden
 * form input field that will be part of the submitted data
 * capture form (new content sent to server).
 *
 * @$form   (jQuery Object) The target form to send content back to the server.
 * @id      (String) Used as the name attribute on input[hidden] form elements.
 * @content (String) instance.content value added to input[hidden] field.
 **/
function updateHiddenInputOnForm($form, name, content) {
  var $input = $form.find("input[name=\"" + name + "\"]");
  if($input.length == 0) {
    $input = $("<input type=\"hidden\" name=\"" + name + "\" />");
    $form.prepend($input);
  }
  $input.val(content);
}


/* Function return specified namespace (creates if doesn't exist).
 * This means you can safely do something like this:
 * namespace("my.name.space").something = "foo";
 * without having the 'space' object previously exist, for example.
 *
 * Also, it means you can avoid undefined errors by doing this:
 * if(namespace("my.name.space").something) {
 *   // something exists so use it
 * }
 *
 * If 'space' did not exist this code would fall over when trying
 * to see if 'something' has value. Instead, although 'something'
 * would still not exist (because 'space' did not) the check should
 * work but without having to write an alternative such as:
 * if(my && my.name && my.name.space && my.name.space.something) {
 *   // something exists so use it
 * }
 **/
function namespace(namespace) {
  var split = namespace.split(".");
  var context = this;
  var i = 0;
  while( i < split.length) {
    context = namespace.call(context, split(i));
    ++i;
  }
  return context;
}


// Make available for importing.
export { mergeObjects, createElement, safelyActivateFunction, isFunction, uniqueString, findFragmentIdentifier, meta, post, updateHiddenInputOnForm };
