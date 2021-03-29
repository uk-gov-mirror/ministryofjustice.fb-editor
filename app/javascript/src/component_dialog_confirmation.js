/**
 * Dialog Confirmation Component
 * ----------------------------------------------------
 * Description:
 * Enhances jQueryUI Dialog component.
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

import { mergeObjects, safelyActivateFunction } from './utilities';
import { Dialog } from './component_dialog';


/* See jQueryUI Dialog for config options (all are passed straight in).
 *
 * Extra config options specific to this enhancement
 * config.classes["ui-activator"]  will put the value in activator classes value.
 * config.onOk takes a function to run when 'Ok' button is activated.
 * config.onCancel takes a function to run when 'Cancel' button is activated.
 * config.onClose takes a function to run after dialog is closed.
 *
 * @$node  (jQuery node) Element found in template that should be enhanced.
 * @config (Object) Configurable key/value pairs.
 **/
class DialogConfirmation extends Dialog {
  constructor($node, config) {
    super($node, mergeObjects( config, {
      buttons: [
      {
        text: config.okText,
        click: () => {
          safelyActivateFunction($node.data("instance")._action);
          $node.dialog("close");
        }
      },
      {
        text: config.cancelText,
        click: () => {
          var instance = $node.data("instance");
          instance.content = instance._defaultText;
          $node.dialog("close");
        }
      }]
    }));

    if($node && $node.length) {
      $node.parents(".ui-dialog").removeClass("Dialog");
      $node.parents(".ui-dialog").addClass("DialogConfirmation");
      $node.data("instance", this);

      DialogConfirmation.setElements.call(this, $node);
      DialogConfirmation.setDefaultText.call(this, $node);
    }

    this._config = config;
    this._action = function() {} // Should be overwritten in confirm()
    this.$node = $node;
  }

  get content() {
    return this._defaultText;
  }

  set content(text) {
    this._elements.heading.text(text.heading || this._defaultText.heading);
    this._elements.message.text(text.message || this._defaultText.message);
    this._elements.ok.text(text.ok || this._defaultText.ok);
    this._elements.cancel.text(text.cancel || this._defaultText.cancel);
  }

  confirm(text, action) {
    for(var t in text) {
      if(text.hasOwnProperty(t) && this._elements[t]) {
        let current = this._elements[t].text();
        this._elements[t].text();
      }
    }
    this._action = action;
    this.$node.dialog("open");
  }
}

/* Private
 * Finds required elements to populate this._elements property.
 **/
DialogConfirmation.setElements = function($node) {
  var elements = {};
  var $buttons = $node.parents(".DialogConfirmation").find(".ui-dialog-buttonset button");
  $buttons.eq(1).show(); // Reverse inherited state.

  elements.heading = $node.find("[data-node='heading']");
  elements.message = $node.find("[data-node='message']");

  // Added by the jQueryUI widget so harder to get.
  elements.ok = $buttons.eq(0);
  elements.cancel = $buttons.eq(1);
  this._elements = elements;
}

/* Private
 * Finds on-load text to use as default values.
 **/
DialogConfirmation.setDefaultText = function($node) {
  this._defaultText = {
    heading: this._elements.heading.text(),
    message: this._elements.message.text(),
    ok: this._elements.ok.text(),
    cancel: this._elements.cancel.text()
  };
}


// Make available for importing.
export { DialogConfirmation };

