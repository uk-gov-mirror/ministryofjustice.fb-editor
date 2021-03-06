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
import { mergeObjects } from './utilities';

var turndownService = new TurndownService();


/* Editable Base:
 * Shared code across the editable component types.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options, e.g.
 *                  {
 *                    editClassname: 'usedOnElementToShowEditing'
 *                    form: $formNodeToAddHiddenInputsForSaveSubmit,
 *                    id: 'identifierStringForUseInHiddenFormInputName',
 *                    type: 'editableContentType'
 *                  }
 **/
class EditableBase {
  constructor($node, config) {
    this._config = config || {};
    this._content = $node.text();
    this.type = config.type;
    this.$node = $node;

    $node.on("click.editablecomponent focus.editablecomponent", (e) => {
      e.preventDefault();
    });
  }

  get content() {
    return this._content;
  }

  save() {
    updateHiddenInputOnForm(this._config.form, this._config.id, this.content);
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
 *                    onSaveRequired: function() {
 *                      // Pass function to do something. Triggered if
 *                      // the code believes something has changed on
 *                      // an internal 'update' call.
 *                    }
 *                  }
 **/
class EditableElement extends EditableBase {
  constructor($node, config) {
    super($node, config);

    $node.on("blur.editablecomponent", this.update.bind(this));
    $node.on("focus.editablecomponent", this.edit.bind(this) );
    $node.on("paste.editablecomponent", e => pasteAsPlainText(e) );
    $node.on("keydown.editablecomponent", e => singleLineInputRestrictions(e) );

    $node.attr("contentEditable", true);
    $node.addClass("EditableElement");
  }

  get content() {
    return this.$node.text();
  }

  set content(content) {
    if(this._content != content) {
      this._content = content;
      triggerSaveRequired(this._config.onSaveRequired);
    }
  }

  edit() {
    this.$node.addClass(this._config.editClassname);
  }

  update() {
    this.content = this.content; // confusing ES6 syntax makes sense if you look closely
    this.$node.removeClass(this._config.editClassname);
  }

  focus() {
    this.$node.focus();
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
class EditableContent extends EditableElement {
  constructor($node, config) {
    super($node, config);
    this._markdown = convertToMarkdown(this.$node.html());
    this._editing = false;

    // Adjust event for multiple line input.
    $node.off("keydown.editablecomponent");
    $node.on("keydown.editablecomponent", e => multipleLineInputRestrictions(e) );

    // Correct the class:
    $node.removeClass("EditableElement");
    $node.addClass("EditableContent");
  }

  get content() {
    return this._markdown;
  }

  set content(markdown) {
    if(this._markdown != markdown) {
      this._markdown = markdown;
      triggerSaveRequired(this._config.onSaveRequired);
    }
  }

  edit() {
    if(!this._editing) {
      let markdown = convertToMarkdown(this.$node.html());
      markdown = markdown.replace(/\n/mig, "<br>");
      this.$node.html(markdown);
      this._editing = true;
      super.edit();
    }
  }

  update() {
    if(this._editing) {
      let markdown = this.$node.html();
      this.content = sanitiseMarkdown(markdown);
      this.$node.html(convertToHtml(markdown));
      this.$node.removeClass(this._config.editClassname);
      this._editing = false;
    }
  }
}


/* Editable Component Base:
 * Share code across the editable component types.
 * Those types are comprised of one or more elements and
 * produce a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 * @elements (Object) Collection of EditableElement instances found in the component.
 *
 **/
class EditableComponentBase extends EditableBase {
  constructor($node, config, elements) {
    super($node, config);
    this.data = config.data;

    // e.g. elements = {
    //        something: new EditableElement($node.find("something"), config)
    //        and any others...
    //      }
    this._elements = arguments.length > 2 && elements || {
      label: new EditableElement($node.find(config.selectorQuestion), config),
      hint: new EditableElement($node.find(config.selectorHint), config)
    };

    $node.find(config.selectorDisabled).attr("disabled", true); // Prevent input in editor mode.
  }

  get content() {
    return JSON.stringify(this.data);
  }

  set content(elements) {
    // Expect this function to be overridden for each different type inheriting it.
    // e.g.
    // this.data.something = elements.something.content
    this.data.label = elements.label.content;
    this.data.hint = elements.hint.content;
  }

  save() {
    // e.g.
    // this.data.something = this._elements.something.content;
    this.content = this._elements;
    EditableBase.prototype.save.call(this);
  }

  // Focus on first editable element.
  focus() {
    for(var i in this._elements) {
      if(this._elements.hasOwnProperty(i)) {
        this._elements[i].focus();
        break;
      }
    }
  }
}


/* Editable Text Field Component:
 * Structured editable component comprising of one or more elements.
 * Produces a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 *
 *
 * Expected backend structure  (passed as JSON)
 * --------------------------------------------
 *  _id: single-question_text_1
 *  hint: Component hint
 *  name: single-question_text_1
 *  _type: text
 *  label: Component label
 *  errors: {}
 *  validation:
 *    required: true
 *
 * Expected (minimum) frontend struture
 * ------------------------------------
 * <div class="fb-editable" data-fb-content-id="foo" data-fb-content-type="text" data-fb-conent-data=" ...JSON... ">
 *   <label>Component label</label>
 *   <span>Component hint</span>
 *   <input name="answers[single-question_text_1]" type="text">
 * </div>
 **/
class EditableTextFieldComponent extends EditableComponentBase {
  constructor($node, config) {
    // TODO: Potential future addition...
    //       Maybe make this EditableAttribute instance when class is
    //       ready so we can edit attribute values, such as placeholder.
    //  {input: new EditableAttribute($node.find("input"), config)}
    super($node, config);
    $node.addClass("EditableTextFieldComponent");
  }
}


/* Editable Textarea Field Component:
 * Structured editable component comprising of one or more elements.
 * Produces a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 *
 *
 * Expected backend structure  (passed as JSON)
 * --------------------------------------------
 *  _id: single-question_textarea_1
 *  hint: Component hint
 *  name: single-question_textarea_1
 *  _type: text
 *  label: Component label
 *  errors: {}
 *  validation:
 *    required: true
 *
 * Expected (minimum) frontend struture
 * ------------------------------------
 * <div class="fb-editable" data-fb-content-id="foo" data-fb-content-type="text" data-fb-conent-data=" ...JSON... ">
 *   <label>Component label</label>
 *   <span>Component hint</span>
 *   <textarea name="answers[single-question_textarea_1]"></textarea>
 * </div>
 **/
class EditableTextareaFieldComponent extends EditableComponentBase {
  constructor($node, config) {
    super($node, config);
    $node.addClass("EditableTextareaFieldComponent");
  }
}


/* Editable Radio Buttons Field Component:
 * Structured editable component comprising of one or more elements.
 * Produces a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 *
 *
 * Expected backend structure  (passed as JSON)
 * --------------------------------------------
 *  _id: radio_radios_1,
 *  hint: Hint text,
 *  name: radio_radios_1,
 *  _type : radios,
 *  items: [
 *    {
 *      _id: component_radio_1,
 *      hint: Hint text,
 *      _type: radio,
 *      label: Option,
 *      value: value-1
 *    },{
 *     _id: component_radio_2,
 *      hint: Hint text,
 *      _type: radio,
 *      label: Option,
 *      value: value-2
 *    }
 *  ],
 *  errors: {},
 *  legend: Question,
 *  validation: {
 *    required: true
 *  }
 *
 *
 * Expected (minimum) frontend struture
 * ------------------------------------
 * <div class="fb-editable" data-fb-content-id="foo" data-fb-content-type="radios" data-fb-conent-data=" ...JSON... ">
 *   <fieldset>
 *     <legend>Question</legend>
 *
 *     <input name="answers[single-question_textarea_1]" type="radio" />
 *     <label>Component label</label>
 *     <span>Component hint</span>
 *
 *     <input name="answers[single-question_textarea_1]" type="radio" />
 *     <label>Component label</label>
 *     <span>Component hint</span>
 *
 * </div>
 **/
class EditableRadiosFieldComponent extends EditableComponentBase {
  constructor($node, config) {
    super($node, config, {
      // Be better for consistency if this was 'label' and not 'legend',
      // but working with the JSON recognised by/sent from the  server.
      label: new EditableElement($node.find(config.selectorRadioQuestion), config),
      hint: new EditableElement($node.find(config.selectorRadioHint), config)
    });
    this.options = EditableRadiosFieldComponent.createEditableOptions($node, config);
    $node.addClass("EditableRadiosFieldComponent");
  }

  // If we override the set content, we obliterate relationship with the inherited get content.
  // This will retain the inherit functionality by explicitly calling it.
  get content() {
    return super.content;
  }

  set content(elements) {
    this.data.legend = elements.label.content;
    this.data.hint = elements.hint.content;

    // Set data from options.
    this.data.items = [];
    for(var i=0; i< this.options.length; ++i) {
      this.data.items.push(this.options[i].data);
    }
  }

  save() {
    // Trigger the save action on options before calling it's own.
    for(var i=0; i<this.options.length; ++i) {
      this.options[i].save();
    }
    super.save();
  }

  updateItemComponents() {
    this.options = EditableRadiosFieldComponent.createEditableOptions(this.$node, this._config);
  }
}

// Private function to find radio options and enhance with editable functionality.
EditableRadiosFieldComponent.createEditableOptions = function($node, config) {
  var options = [];
  $node.find(config.selectorRadioOption).each(function(i) {
    var itemConfig = mergeObjects({}, config);
    itemConfig.data = config.data.items[i];
    options.push(new EditableItemComponent($(this), itemConfig));
  });
  return options;
}


/* Editable Collection:
 * Used for things like Radio Options that have a label and hint element but
 * are owned by a parent Editable Component, so does not need to save their
 * own content by writing a hidden element (like other types). Not considered
 * a standalone 'type' to be used in the editableComponent() initialisation
 * function.
 *
 * Save function will produce a JSON string as content from internal data object
 * but do nothing else with it. A parent component will read and use the
 * generated 'saved' content.
 *
 **/
class EditableItemComponent extends EditableComponentBase {
  constructor($node, config) {
    super($node, config);
    $node.addClass("EditableItemComponent");
  }

  save() {
    // Doesn't need super because we're not writing to hidden input.
    this.content = this._elements;
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


/* Convert HTML to Markdown by tapping into third-party code.
 * Includes clean up of HTML by stripping attributes and unwanted trailing spaces.
 **/
function convertToMarkdown(html) {
  html = html.trim();
  html = html.replace(/(<\w[\w\d]+)\s*[\w\d\s=\"-]*?(>)/mig, "$1$2");
  html = html.replace(/(?:\n\s*)/mig, "\n");
  html = html.replace(/[ ]{2,}/mig, " ");
  html = DOMPurify.sanitize(html, { USE_PROFILES: { html: true }});
  return turndownService.turndown(html);
}


/* Convert Markdown to HTML by tapping into a third-party code.
 **/
function convertToHtml(markdown) {
  return marked(sanitiseMarkdown(markdown));
}

/* Manual conversion of characters to keep values as required.
 * Stripping the <br> tags is because we put them in for visual formatting only.
 * Stripping out the extra spaces because the browser added them and we don't want.
 * Seems like the browser (contentEditable functionality) is adding <div> tags to
 * format new lines, so we're fixing that with line-breaks and stripping excess.
 **/
function sanitiseMarkdown(markdown) {
  markdown = markdown.replace(/\*\s+/mig, "* ");
  markdown = markdown.replace(/<br>/mig, "\n");
  markdown = markdown.replace(/<\/div><div>/mig, "\n");
  markdown = markdown.replace(/<[\/]?div>/mig, "");
  return markdown;
}


/* Multiple Line Input Restrictions
 * Browser contentEditable mode means some pain in trying to prevent
 * HTML being inserted (rich text attempts by browser). We're only
 * editing as plain text and markdown for all elements so try to
 * prevent unwanted entry with this function.
 **/
function multipleLineInputRestrictions(event) {

  // Prevent ENTER adding <div><br></div> nonsense.
  if(event.which == 13) {
    event.preventDefault();
    document.execCommand("insertText", false, "\n");
  }
}


/* Single Line Input Restrictions
 *Browser contentEditable mode means some pain in trying to prevent
 * HTML being inserted (rich text attempts by browser). We're only
 * editing as plain text and markdown for all elements so try to
 * prevent unwanted entry with this function.
 **/
function singleLineInputRestrictions(event) {

  // Prevent ENTER adding <div><br></div> nonsense.
  if(event.which == 13) {
    event.preventDefault();
  }
}

/* Function prevents rich text being pasted on paste event.
 * Used in the editing markdown area so we do not get crossed
 * formats.
 *
 * Use like: $('something').on('paste', e => pasteAsPlainText(e) )}
 **/
function pasteAsPlainText(event) {
  event.preventDefault();
  var content = "";
  if (event.clipboardData || event.originalEvent.clipboardData) {
    content = (event.originalEvent || event).clipboardData.getData('text/plain');
  }
  else {
    if (window.clipboardData) {
      content = window.clipboardData.getData('Text');
    }
  }

  if (document.queryCommandSupported("insertText")) {
    document.execCommand("insertText", false, content);
  }
  else {
    document.execCommand("paste", false, content);
  }
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
    case "text":
      klass = EditableTextFieldComponent;
      break;
    case "textarea":
      klass = EditableTextareaFieldComponent;
      break;
    case "radios":
      klass = EditableRadiosFieldComponent;
      break;
  }
  return new klass($node, config);
}


// Make available for importing.
export { editableComponent };
