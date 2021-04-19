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


import { mergeObjects, createElement, safelyActivateFunction, updateHiddenInputOnForm } from './utilities';
var showdown  = require('showdown');
var converter = new showdown.Converter({
                  noHeaderId: true,
                  strikethrough: true,
                  omitExtraWLInCodeBlocks: true,
                  disableForced4SpacesIndentedSublists: true
                });

showdown.setFlavor('github');

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
    this.type = config.type;
    this.$node = $node;
    $node.data("instance", this);

    $node.on("click.editablecomponent focus.editablecomponent", (e) => {
      e.preventDefault();
    });
  }

  get content() {
    return $node.text();
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
    var originalContent = $node.text().trim(); // Trim removes whitespace from template.

    $node.on("blur.editablecomponent", this.update.bind(this));
    $node.on("focus.editablecomponent", this.edit.bind(this) );
    $node.on("paste.editablecomponent", e => pasteAsPlainText(e) );
    $node.on("keydown.editablecomponent", e => singleLineInputRestrictions(e) );

    $node.attr("contentEditable", true);
    $node.addClass("EditableElement");

    this._content = $node.text().trim();
    this.originalContent = originalContent;
    this.defaultContent = $node.data(config.attributeDefaultText);
  }

  get content() {
    var content = this._content;
    return content == this.defaultContent ? "" : content;
  }

  set content(content) {
    this._content = content;
    this.populate(content);
    safelyActivateFunction(this._config.onSaveRequired);
  }

  edit() {
    this.$node.addClass(this._config.editClassname);
  }

  update() {
    this.content = this.$node.text().trim();
    this.$node.removeClass(this._config.editClassname);
  }

  // Expects content or blank string to show content or default text in view.
  populate(content) {
    var defaultContent = this.defaultContent || this.originalContent;
    this.$node.text(content == "" ? defaultContent : content);
  }

  focus() {
    this.$node.focus();
  }
}


/* Editable Content:
 * Used for creating complex content control objects on HTML areas such as a <DIV>,
 * or <article>. The content will, when in edit mode, convert to Markdown and expect
 * user input in as Markdown. On exit of edit mode visible content will be translated
 * back into HTML for non-edit view and to save.
 * (Edit mode controlled by focus and blur events).
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 **/
class EditableContent extends EditableElement {
  constructor($node, config) {
    super($node, config);

    // Adjust event for multiple line input.
    $node.off("keydown.editablecomponent");
    $node.on("keydown.editablecontent", e => multipleLineInputRestrictions(e) );

    // Correct the class:
    $node.removeClass("EditableElement");
    $node.addClass("EditableContent");

    this._editing = false;
    this._content = $node.html().trim(); // trim removes whitespace from template.
  }

  // Get content must always return Markdown because that's what we save.
  get content() {
    var content = convertToMarkdown(this._content);
    var value = "";
    if(this._config.data) {
      this._config.data.content = content;
      value = JSON.stringify(this._config.data);
    }
    else {
      value = (content.replace(/\s/mig, "") == this.defaultContent ? "" : content);
    }
    return value;
  }

  // Set content takes markdown (because it should be called after editing).
  // It should convert the markdown to HTML and put back as DOM node content.
  set content(markdown) {
    this._content = convertToHtml(markdown);
    safelyActivateFunction(this._config.onSaveRequired);
  }

  edit() {
    if(!this._editing) {
      EditableContent.displayMarkdownInBrowser.call(this);
      this._editing = true;
      super.edit();
    }
  }

  update() {
    if(this._editing) {
      // Get the content which should be markdown mixed with
      // some HTML due to browser contentEditable handling.
      this.content = this.$node.html();
      EditableContent.displayHtmlInBrowser.call(this);
      this.$node.removeClass(this._config.editClassname);
      this._editing = false;
    }
  }

  markdown() {
    return convertToMarkdown(this._content);
  }
}

/* Function to display the content as markdown in browser.
 * Had own function because we need to manipulate the content to
 * make sure it displays correctly formatted (visually), and
 * for clarity of where the display action happens.
 **/
EditableContent.displayMarkdownInBrowser = function() {
  var markdown = this.markdown();
  this.$node.html(markdown.replace(/\n/g,"<br>")); // Displays on one line without this.
}


/* Function to display the content as markdown in browser.
 * Had own function because we need to manipulate the content to
 * make sure it displays correctly formatted (visually), and
 * for clarity of where the display action happens.
 **/
EditableContent.displayHtmlInBrowser = function() {
  var defaultContent = this.defaultContent || this.originalContent;
  var content = (this._content == "" ? defaultContent : this._content);
  this.$node.html(content);
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
    $node.data("instance", this);

    // e.g. elements = {
    //        something: new EditableElement($node.find("something"), config)
    //        and any others...
    //      }
    this._elements = arguments.length > 2 && elements || {
      label: new EditableElement($node.find(config.selectorElementLabel), config),
      hint: new EditableElement($node.find(config.selectorElementHint), config)
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
    super($node, mergeObjects({
      selectorElementLabel: config.selectorTextFieldLabel,
      selectorElementHint: config.selectorTextFieldHint
    }, config));
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
    super($node, mergeObjects({
      selectorElementLabel: config.selectorTextareaFieldLabel,
      selectorElementHint: config.selectorTextareaFieldHint
    }, config));
    $node.addClass("EditableTextareaFieldComponent");
  }
}


/* Editable Group Field Component:
 * Structured editable component comprising of one or more fields wrapped in fieldset.
 * Produces a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 *
 *
 * Example expected backend structure  (passed as JSON - using a Date component)
 * -----------------------------------------------------------------------------
 *  _id: Date_date_1
 *  hint: Component hint
 *  name: Date_date_1
 *  _type: date
 *  label: Component label
 *  errors: {}
 *  validation:
 *    required: true
 *
 * Expected (minimum) frontend struture
 * ------------------------------------
 * <div class="fb-editable" data-fb-content-id="foo" data-fb-content-type="date" data-fb-conent-data=" ...JSON... ">
 *   <fieldset>
 *     <legend>Question text</legend>
 *
 *     <label>Day</label>
 *     <input name="answers[date_1]" type="text" />
 *
 *     <label>Month</label>
 *     <input name="answers[date_2]" type="text" />
 *
 *     <label>Year</label>
 *     <input name="answers[date_3]" type="text" />
 *   </fieldset>
 * </div>
 **/
class EditableGroupFieldComponent extends EditableComponentBase {
  constructor($node, config) {
    super($node, mergeObjects({
      selectorElementLabel: config.selectorGroupFieldLabel,
      selectorElementHint: config.selectorGroupFieldHint
    }, config));
    $node.addClass("EditableGroupFieldComponent");
  }

  // Override get/set content only because we need to use data.legend instead of data.label
  get content() {
    return JSON.stringify(this.data);
  }

  set content(elements) {
    this.data.legend = elements.label.content;
    this.data.hint = elements.hint.content;
  }
}


/* Editable Collection (Radios/Checkboxes) Field Component:
 * Structured editable component comprising of one or more elements.
 * Produces a JSON string as content from internal data object.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options.
 *
 *
 * Expected backend structure  (passed as JSON)
 * --------------------------------------------
 *  _id: collections_1,
 *  hint: Hint text,
 *  name: collections_1,
 *  _type : [radios|checkboxes],
 *  items: [
 *    {
 *      _id: component_item_1,
 *      hint: Hint text,
 *      _type: [radio|checkbox],
 *      label: Label Text,
 *      value: value-1
 *    },{
 *     _id: component_item_2,
 *      hint: Hint text,
 *      _type: [radio|checkbox],
 *      label: Label text,
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
 * Expected (minimum) frontend structure
 * -------------------------------------
 * <div class="fb-editable" data-fb-content-id="foo" data-fb-content-type="radios" data-fb-conent-data=" ...JSON... ">
 *   <fieldset>
 *     <legend>Question</legend>
 *
 *     <input name="answers[single-question_radio_1]" type="radio" />
 *     <label>Component label</label>
 *     <span>Component hint</span>
 *
 *     <input name="answers[single-question_radio_1]" type="radio" />
 *     <label>Component label</label>
 *     <span>Component hint</span>
 *
 * </div>
 **/
class EditableCollectionFieldComponent extends EditableComponentBase {
  constructor($node, config) {
    super($node, mergeObjects({
      selectorElementLabel: config.selectorCollectionFieldLabel,
      selectorElementHint: config.selectorCollectionFieldHint
    }, config));

    var text = config.text || {}; // Make sure it exists to avoid errors later on.

    this._preservedItemCount = (this.type == "radios" ? 2 : 1); // Either minimum 2 radios or 1 checkbox.
    EditableCollectionFieldComponent.createCollectionItemTemplate.call(this, config);
    EditableCollectionFieldComponent.createEditableCollectionItems.call(this, config);
    new EditableCollectionItemInjector(this, config);
    $node.addClass("EditableCollectionFieldComponent");
  }

  // If we override the set content, we obliterate relationship with the inherited get content.
  // This will retain the inherit functionality by explicitly calling it.
  get content() {
    return super.content;
  }

  set content(elements) {
    this.data.legend = elements.label.content;
    this.data.hint = elements.hint.content;

    // Set data from items.
    this.data.items = [];
    for(var i=0; i< this.items.length; ++i) {
      this.data.items.push(this.items[i].data);
    }
  }

  // Dynamically adds an item to the components collection
  add() {
    // Component should always have at least one item, otherwise something is very wrong.
    var $lastItem = this.items[this.items.length - 1].$node;
    var $clone = this.$itemTemplate.clone();
    $lastItem.after($clone);
    EditableCollectionFieldComponent.addItem.call(this, $clone, this.$itemTemplate.data("config"));
    EditableCollectionFieldComponent.updateItems.call(this);
    safelyActivateFunction(this._config.onItemAdd, $clone);
    safelyActivateFunction(this._config.onSaveRequired);
  }

  // Dynamically removes an item to the components collection
  remove(item) {
    var index = this.items.indexOf(item);
    safelyActivateFunction(this._config.onItemRemove, item);
    this.items.splice(index, 1);
    item.$node.remove();
    EditableCollectionFieldComponent.updateItems.call(this);
    safelyActivateFunction(this._config.onSaveRequired);
  }

  save() {
    // Trigger the save action on items before calling it's own.
    for(var i=0; i<this.items.length; ++i) {
      this.items[i].save();
    }
    super.save();
  }
}

/* Private function
 * Create an item template which can be cloned in component.add()
 * config (Object) key/value pairs for extra information.
 *
 * Note: Initial index elements of Array/Collection is called directly
 * without any checking for existence. This is because they should always
 * exist and, if they do not, we want the script to throw an error
 * because it would alert us to something very wrong.
 **/
EditableCollectionFieldComponent.createCollectionItemTemplate = function(config) {
  var $clone = this.$node.find(config.selectorCollectionItem).eq(0).clone();
  var data = mergeObjects({}, config.data, ["items"]); // pt.1 Copy without items.
  var itemConfig = mergeObjects({}, config, ["data"]); // pt.2 Copy without data.
  itemConfig.data = mergeObjects(data, config.data.items[0]); // Bug fix response to JS reference handling.

  // Filters could be changing the blah_1 values to blah_0, depending on filters in play.
  itemConfig.data = EditableCollectionFieldComponent.applyFilters(config.filters, 0, itemConfig.data);

  // In case we need some custom actions on element.
  safelyActivateFunction(config.onCollectionItemClone, $clone);

  $clone.data("config", itemConfig);

  // Note: If we need to strip out some attributes or alter the template
  //       in some way, do that here.

  this.$itemTemplate = $clone;
}

/* Private function
 * Find radio or checkbox items and enhance with editable functionality.
 * Creates the initialising values for this.items
 * config (Object) key/value pairs for extra information.
 **/
EditableCollectionFieldComponent.createEditableCollectionItems = function(config) {
  var component = this;
  component.$node.find(config.selectorCollectionItem).each(function(i) {
    var data = mergeObjects({}, config.data, ["items"]); // pt.1 Copy without items.
    var itemConfig = mergeObjects({ preserveItem: (i < component._preservedItemCount) }, config, ["data"]); // pt.2 Without data
    itemConfig.data = mergeObjects(data, config.data.items[i]); // Bug fix response to JS reference handling.

    // Only wrap in EditableComponentCollectionItem functionality if doesn't look like it has it.
    if(this.className.indexOf("EditableComponentCollectionItem") < 0) {
      EditableCollectionFieldComponent.addItem.call(component, $(this), itemConfig);
    }
  });
}

/* Private function
 * Enhance an item and add to this.items array.
 * $node (jQuery node) Should be a clone of this.itemTemplate
 * config (Object) key/value pairs for extra information.
 **/
EditableCollectionFieldComponent.addItem = function($node, config) {
  if(!this.items) { this.items = []; } // Should be true on first call only.
  this.items.push(new EditableComponentCollectionItem(this, $node, config));

  // TODO: need to update the data on each item so _id and value are different.
  
}

/* Private function
 * Run through the collection items to make sure data is sync'd when we've
 * either added a new item or removed one (e.g. makes sure to avoid clash
 * of data _id values.
 **/
EditableCollectionFieldComponent.updateItems = function() {
  var filters = this._config.filters;
  for(var i=0; i < this.items.length; ++i) {
    this.items[i].data = EditableCollectionFieldComponent.applyFilters(filters, i+1, this.items[i].data);
  }
}


/* Private function
 * Applies config.filters to the data passed in, with an index number, since this should
 * be called within a loop of the items. It has been expracted out to counter complications
 * running into closure issues due to manipulating data within a loop.
 * @unique (Integer|String) Should be current loop number, or at least something unique. 
 * @data   (Object) Collection item data.
 **/
EditableCollectionFieldComponent.applyFilters = function(filters, unique, data) {
  var filtered_data = {};
  for(var prop in data) {
    if(filters && filters.hasOwnProperty(prop)) {
      filtered_data[prop] = filters[prop].call(data[prop], unique);
    }
    else {
      filtered_data[prop] = data[prop];
    }
  }
  return filtered_data;
}

/* Editable Component Collection Item:
 * Used for things like Radio Options/Checkboxes that have a label and hint element
 * but are owned by a parent Editable Component, so does not need to save their
 * own content by writing a hidden element (like other types). Not considered
 * a standalone 'type' to be used in the editableComponent() initialisation
 * function.
 *
 * Save function will produce a JSON string as content from internal data object
 * but do nothing else with it. A parent component will read and use the
 * generated 'saved' content.
 *
 * config.onItemRemoveConfirmation (Function) An action passed the item.
 *
 **/
class EditableComponentCollectionItem extends EditableComponentBase {
  constructor(editableCollectionFieldComponent, $node, config) {
    super($node, mergeObjects({
      selectorElementLabel: config.selectorComponentCollectionItemLabel,
      selectorElementHint: config.selectorComponentCollectionItemHint
    }, config));

    if(!config.preserveItem) {
      new EditableCollectionItemRemover(this, editableCollectionFieldComponent, config);
    }

    $node.on("focus.EditableComponentCollectionItem", "*", function() {
      $node.addClass(config.editClassname);
    });

    $node.on("blur.EditableComponentCollectionItem", "*", function() {
      $node.removeClass(config.editClassname);
    });

    this.component = editableCollectionFieldComponent;
    $node.addClass("EditableComponentCollectionItem");
  }

  remove() {
    if(this._config.onItemRemoveConfirmation) {
      // If we have confirgured a way to confirm first...
      safelyActivateFunction(this._config.onItemRemoveConfirmation, this);
    }
    else {
      // or just run the remove function.
      this.component.remove(this);
    }
  }

  save() {
    // Doesn't need super because we're not writing to hidden input.
    this.content = this._elements;
  }
}


class EditableCollectionItemInjector {
  constructor(editableCollectionFieldComponent, config) {
    var conf = mergeObjects({}, config);
    var text = mergeObjects({ addItem: 'add' }, config.text);
    var $node = $(createElement("button", text.addItem, conf.classes));
    editableCollectionFieldComponent.$node.append($node);
    $node.addClass("EditableCollectionItemInjector");
    $node.attr("type", "button");
    $node.data("instance", this);
    $node.on("click", function(e) {
      e.preventDefault();
      editableCollectionFieldComponent.add();
    });

    this.component = editableCollectionFieldComponent;
    this.$node = $node;
  }
}


class EditableCollectionItemRemover {
  constructor(editableCollectionItem, editableCollectionFieldComponent, config) {
    var conf = mergeObjects({}, config);
    var text = mergeObjects({ removeItem: 'remove' }, config.text);
    var $node = $(createElement("button", text.removeItem, conf.classes));
    var removeCollectionItem = function() {
      editableCollectionFieldComponent.remove(editableCollectionItem);
    }

    $node.data("instance", this);
    $node.addClass("EditableCollectionItemRemover");
    $node.attr("type", "button");
    $node.on("click.EditableCollectionItemRemover", function(e) {
      e.preventDefault();
      editableCollectionItem.remove();
    });

    // Close on SPACE and ENTER
    $node.on("keydown.EditableCollectionItemRemover", function(e) {
      e.preventDefault();
      if(e.which == 13 || e.which == 32) {
        editableCollectionItem.remove();
      }
    });

    editableCollectionItem.$node.append($node);

    this.component = editableCollectionFieldComponent;
    this.item = editableCollectionItem;
    this.$node = $node;
  }
}


/* Convert HTML to Markdown by tapping into third-party code.
 * Includes clean up of HTML by stripping attributes and unwanted trailing spaces.
 **/
function convertToMarkdown(html) {
  html = html.trim();
  html = html.replace(/<!-- -->/mig, "");
  html = html.replace(/(<\/p>)/mig, "$1\n\n");
  html = html.replace(/(<\w[\w\d]+)\s*[\w\d\s=\"-]*?(>)/mig, "$1$2");
  return converter.makeMarkdown(html).trim();
}


/* Convert Markdown to HTML by tapping into third-party code.
 * Includes clean up of both Markdown and resulting HTML to fix noticed issues.
 **/
function convertToHtml(markdown) {
  // First clean up what we got as it will probably contain
  // some nonsense due to browser contentEditabl handling. 
  markdown = markdown.trim();
  markdown = markdown.replace(/&nbsp;/mig, " "); // Entity spaces mess things up.
  markdown = markdown.replace(/<br>/mig, "\n");  // Revert any we added for visual purpose.
  markdown = markdown.replace(/<\/div><div>/mig, "\n");
  markdown = markdown.replace(/<[\/]?div>/mig, "");
  markdown = markdown.replace(/&gt;/mig, ">"); // Fix blockquotes.

  // Next do the conversion and correct some things to display properly.
  let html = converter.makeHtml(markdown);
  html = html.replace(/<li><p>(.*)?<\/p>/mig, "<li>$1");  // Don't want <p> tags in there.
  return html;
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
    case "number":
      klass = EditableTextFieldComponent;
      break;
    case "textarea":
      klass = EditableTextareaFieldComponent;
      break;
    case "date":
      klass = EditableGroupFieldComponent;
      break;
    case "radios":
    case "checkboxes":
      klass = EditableCollectionFieldComponent;
      break;
  }
  return new klass($node, config);
}


// Make available for importing.
export { editableComponent };
