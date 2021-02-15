import DOMPurify from 'dompurify';

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



/* Editable Element:
 * Used for creating simple content control objects on HTML
 * elements such as <H1>, <P>, <LABEL>, <LI>, etc.
 * Switched into edit mode on focus and out again on blur.
 *
 * @$node  (jQuery object) jQuery wrapped HTML node.
 * @config (Object) Configurable options, e.g.
 *                  {
 *                    classname: 'usedOnBackgroundInput',
 *                    value: 'content to populate background input'
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
 *                    classname: 'usedOnBackgroundInput',
 *                    value: 'content to populate background input'
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
    this.content = this.$node.text();
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
 * @config (Object) Configurable options, e.g.
 *                  {
 *                    classname: 'usedOnBackgroundInput',
 *                    value: 'content to populate background input'
 *                  }
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
    this.content = this.input.$node.val();
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

// TODO: Convert HTML to Markdown by tapping into a plugin or service.
// Added basic (non-complete) effort for development testing here.
function convertToMarkdown(html) {
  var text = cleanHtml(html);

  // Remove all closing brackets.
  text = text.replace(/(<p>|<ul>|<\/ul>|<\/li>|<\/h2>|<\/h3>|<\/h4>)/mig, "");

  // Apply some markdown formats.
  text = text.replace(/\s*<\/p>\s*/mig, " \n");
  text = text.replace(/<br>|<br \/>/mig, "  \n");
  text = text.replace(/<li>/mig, "- ");
  text = text.replace(/<h2>/mig, "## ");
  text = text.replace(/<h3>/mig, "### ");
  text = text.replace(/<h4>/mig, "#### ");
  text = text.replace(/<strong><em>(.*)?<\/em><\/strong>/mig, "***$1***");
  return text;
}


// TODO: Convert Markdown to HTML by tapping into a plugin or service.
// Added basic (non-complete) effort for development testing here.
function convertToHtml(markdown) {
  var text = markdown.trim();
  text = text.replace(/\*\*\*(.*)?\*\*\*/mig, "<strong><em>$1</em></strong>");
  text = text.replace(/\*\*(.*)?\*\*/mig, "<strong>$1</strong>");

  text = text.replace(/#### (.*)$/mig, "<h4>$1</h4>\n");
  text = text.replace(/### (.*)$/mig, "<h3>$1</h3>\n");
  text = text.replace(/## (.*)$/mig, "<h2>$1</h2>\n");

  text = text.replace(/- (.*)$/mig, "<li>$1</li>\n");
  text = text.replace(/(<li>(.*)<\/li>)/smig, "<ul>\n$1\n</ul>\n");
  text = text.replace(/[ ]{2,}\n/mig, "<br>");
  text = text.replace(/^([^\n<].*?)$/smig, "<p>$1</p>");

  return text;
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
