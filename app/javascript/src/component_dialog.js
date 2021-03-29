/**
 * Dialog Component
 * ----------------------------------------------------
 * Description:
 * Enhances jQueryUI Dialog component to make a simple message dialog.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/dialog
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/

import { safelyActivateFunction } from './utilities';


/* See jQueryUI Dialog for config options (all are passed straight in).
 *
 * Extra config options specific to this enhancement
 * config.onOk takes a function to run when 'Ok' button is activated.
 *
 * @$node  (jQuery node) Element found in template that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class Dialog {
  constructor($node, config) {
    var conf = config || {};
    var classes = conf.classes || {};
    var buttons = conf.buttons || [
      {
        text: conf.okText,
        click: () => {
          $node.dialog("close");
        }
      }];

    if($node && $node.length) {
      $node.dialog({
        autoOpen: conf.autoOpen || false,
        buttons: buttons,
        classes: classes,
        closeOnEscape: true,
        height: "auto",
        modal: true,
        resizable: false
      });

      $node.parents(".ui-dialog").addClass("Dialog");
      $node.data("instance", this);

      Dialog.setElements.call(this, $node);
      Dialog.setDefaultText.call(this, $node);
    }

    this._config = conf;
    this.$node = $node;
  }

  get content() {
    return this._defaultText;
  }

  set content(text) {
    this._elements.heading.text(text.heading || this._defaultText.heading);
    this._elements.message.text(text.message || this._defaultText.message);
    this._elements.ok.text(text.ok || this._defaultText.ok);
  }

  open(text) {
    for(var t in text) {
      if(text.hasOwnProperty(t) && this._elements[t]) {
        let current = this._elements[t].text();
        this._elements[t].text();
      }
    }
    this.$node.dialog("open");
  }
}

/* Private
 * Finds required elements to populate this._elements property.
 **/
Dialog.setElements = function($node) {
  var elements = {};
  var $buttons = $node.parents(".Dialog").find(".ui-dialog-buttonset button");

  elements.heading = $node.find("[data-node='heading']");
  elements.message = $node.find("[data-node='message']");

  // Added by the jQueryUI widget so harder to get.
  elements.ok = $buttons.eq(0);
  
  // Don't want this button so hide it.
  $buttons.eq(1).hide();

  this._elements = elements;
}

/* Private
 * Finds on-load text to use as default values.
 **/
Dialog.setDefaultText = function($node) {
  this._defaultText = {
    heading: this._elements.heading.text(),
    message: this._elements.message.text(),
    ok: this._elements.ok.text(),
  };
}


// Make available for importing.
export { Dialog };

