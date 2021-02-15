/**
 * Editable Components
 * ----------------------------------------------------
 * Description:
 * Enhance target elements (components) with editable update/save properties.
 *
 * Requires: jQuery
 * Documentation:
 *
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/

import DOMPurify from 'dompurify';
import marked from 'marked';
import TurndownService from 'turndown';
var turndownService = new TurndownService();

/* Editable Element:
 * Used for creating simple content control objects on HTML
 * elements such as <H1>, <P>, <LABEL>, <LI>, etc.
 * Switched into edit mode on focus and out again on blur.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options, e.g.
 *                  {
 *                    form: $formNodeToAddHiddenInputsForSaveSubmit,
 *                    id: 'identifierStringForUseInHiddenFormInputName',
 *                    onSaveRequired: function() {
 *                      // Pass function to do something. Triggered if
 *                      // the code believes something has changed on
 *                      // an internal 'update' call.
 *                    },
 *                    type: 'editableContentType'
 *                  }
 **/
class EditableBase {
  constructor($node, config) {
    this._config = config || {};
    this.$node = $node;
    this.type = $node.data(config.type);

    $node.on("click.editablecomponent", this.edit.bind(this));
    $node.on("blur.editablecomponent", this.update.bind(this));
  }

  edit() {
    console.log("edit");
  }

  update() {
		console.log("update");
  }

  save() {
    updateHiddenInputOnForm(this._config.form, this._config.id, this.content.trim());
  }
}

/* Editable Element:
 * Used for creating simple content control objects on HTML
 * elements such as <H1>, <P>, <LABEL>, <LI>, etc.
 * Switched into edit mode on focus and out again on blur.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options, e.g.
 *                  {
 *                    editClassname: 'usedOnElementToShowEditing'
 *                  }
 **/
class EditableElement extends EditableBase {
  constructor($node, config) {
    super($node, config);

    this.content = $node.text();
    $node.attr("contentEditable", true);
    $node.addClass("EditableElement");
  }

  edit() {
    this.$node.focus();
    this.$node.addClass(this._config.editClassname);
  }

  update() {
    var text = this.$node.text();
    if(this.content != text) {
      this.content = text;
      triggerSaveRequired(this._config.onSaveRequired);
    }
    this.$node.removeClass(this._config.editClassname);
  }
}


/* Editable Content:
 * Used for creating complex content control objects on HTML areas such as a <DIV>,
 * or <article>. The content will, when in edit mode, expect Markdown input which
 * will be translated into HTML, for view to user, when switched out of edit mode
 * (controlled by focus and blur events).
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 **/
class EditableContent extends EditableBase {
  constructor($node, config) {
    super($node, config);

    var _instance = this;
    this.html = $node.html();
    this.markdown = convertToMarkdown(this.html);
    this.input = new BackgroundInputElement(this, "<textarea></textarea>", {
      classname: "textarea",
      value: this.markdown
    });

    $node.addClass("EditableContent");

    // Counter inherited actions:
    $node.off("blur.editablecomponent");
  }

  get content() {
    return this.markdown;
  }

  set content(markdown) {
    this.html = convertToHtml(markdown);
    this.markdown = markdown;
    this.$node.html(this.html);
    this.input.$node.hide();
  }

  edit() {
    this.$node.hide();
    this.input.$node.val(this.content);
    this.input.$node.show();
    this.input.$node.focus();
  }

  update() {
    var value = this.input.$node.val();
    if(this.content != value) {
      this.content = value;
      triggerSaveRequired(this._config.onSaveRequired);
    }
    this.input.$node.hide();
    this.$node.show();
  }
}


/* TODO: Editabl Attribute:
 * Used for editing attribute values on HTML elements.
 * E.g. (and written for) allowing edit placeholder  text for an
 * input element.
 *
 * Note: Not tested at time of development but, in theory, this
 * could be used for editing the src attribute value of an <IMG>
 * tag, or it's alt value. Future use could also be to edit the
 * value attribute of an input[type=submit] button, and possibly
 * more uses yet to be discovered.
 **/
class EditableAttribute extends EditableBase {
  constructor($node, config) {
    // Does nothing for now.
    // Will handle placeholder text changes, for example.

    // Counter inherited actions:
    $node.off("click.editablecomponent"); // Prevents editing.
    $node.off("blur.editablecomponent");
    $node.addClass("EditableAttribute");
  }

  get content() {
    return this._content;
  }

  set content(blah) {
  }

  edit() {
    console.group("Update Attribute");
    console.groupEnd();
  }

  update() {
    console.group("Update Attribute");
    console.groupEnd();
  }
}


/* Background Input Element:
 * Allows an input element element (e.g. <INPUT> or <TEXTAREA>) to
 * be created for input of user edited content. This can be handy
 * when there is a need to translate the user content from one form
 * to another, such as in the Content objects where user will input
 * markdown text into a <TEXTAREA>, which gets translated into HTML
 * and shown within a standard <DIV> wrapped area. The input is
 * created from a passed HTML string.
 *
 * @component (Editable content instance) e.g. see Content class, above.
 * @html      (String) This is passed to jQuery function to create an element.
 *                     e.g. "<input />" or "<textarea></textarea>"
 * @config    (Object) Allows multiple extra values to be passed.
 *                     e.g. {
 *                            classname: 'someHtmlClassIfRequired',
 *                            value: 'Stored text content to initialise the input',
 *                          }
 *
 **/
class BackgroundInputElement {
  constructor(component, html, config) {
    var config = config || {};
    var $input = $(html);

    $input.hide();
    $input.addClass("BackgroundInputElement");
    $input.val(config.value);

    if(config.classname) {
      $input.addClass(config.classname);
    }

    $input.on("blur.editablecomponent", function() {
      component.update();
    });

    component.$node.before($input);
    this.$node = $input;
  }
}


/* Fires a passed function intended to run on code detection of
 * content required to be saved (updated and different).
 **/
function triggerSaveRequired(action) {
  if(typeof(action) === 'function' || action instanceof Function) {
    action();
  }
}

/* Function used to update (or create if does not exist) a hidden
 * form input field that will be part of the submitted data
 * capture form (new content sent to server).
 *
 * @$form   (jQuery Object) The target form to send content back to the server.
 * @id      (String) Used as the name attribute on input[hidden] form elements.
 * @content (String) instance.content value added to input[hidden] field.
 **/
function updateHiddenInputOnForm($form, id, content) {
  var $input = $form.find("input[name=\"" + id + "\"]");
  if($input.length == 0) {
    $input = $("<input type=\"hidden\" name=\"" + id + "\" />");
    $form.prepend($input);
  }
  $input.val(content);
}


/* Clean up HTML by stripping attributes and unwanted trailing spaces.
 **/
function cleanHtml(html) {
  html = html.trim();
  html = html.replace(/(<\w[\w\d]+)\s*[\w\d\s=\"-]*?(>)/mig, "$1$2");
  html = html.replace(/(?:\n\s*)/mig, "\n");
  html = html.replace(/[ ]{2,}/mig, " ");
  html = DOMPurify.sanitize(html, { USE_PROFILES: { html: true }});
  return html;
}

/* Convert HTML to Markdown by tapping into third-party code.
 **/
function convertToMarkdown(html) {
  return  turndownService.turndown(cleanHtml(html));
}


/* Convert Markdown to HTML by tapping into a third-party code.
 **/
function convertToHtml(markdown) {
  return marked(markdown);
}


/* Determin what type of node is passed and create editable content type
 * to match.
 *
 * @$node ($jQuery node) REQUIRED - jQuery wrapped HTML element to become editable content.
 * @config (Object) Properties passed for any configuration.
 **/
function editableComponent($node, config) {
  var klass;
  switch(config.type) {
    case "element":
      klass = EditableElement;
      break;
    case "content":
      klass = EditableContent;
      break;
    default: 
      // Assume we're handling attributes.
      config.attributes = config.type.replace(/^.*?\[?([\w,\s]+)\]?$/, "$1");
      klass = EditableAttribute;
  }
  return new klass($node, config);
}


// Make available for importing.
export { editableComponent };
