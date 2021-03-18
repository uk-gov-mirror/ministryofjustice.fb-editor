/**
 * Activated Dialog Component
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

import { safelyActivateFunction } from './utilities';


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
class ConfirmationDialog {
  constructor($node, config) {
    var conf = config || {};
    var classes = conf.classes || {};
    var buttons = [
      {
        text: conf.okText,
        click: () => {
          safelyActivateFunction(this.action);
          $node.dialog("close");
        }
      },
      {
        text: conf.cancelText,
        click: () => {
          $node.dialog("close");
        }
    }];

    $node.dialog({
      autoOpen: conf.autoOpen || false,
      buttons: buttons,
      classes: classes,
      closeOnEscape: true,
      height: "auto",
      modal: true,
      resizable: false
    });

    $node.parents(".ui-dialog").addClass("ConfirmationDialog");
    $node.data("instance", this);

    ConfirmationDialog.setElements.call(this, $node, ["heading", "message"]);

    this._config = conf;
    this.$node = $node;
    this.action = function() {} // Should be overwritten in confirm()
  }

  confirm(text, action) {
    for(var t in text) {
      if(text.hasOwnProperty(t) && this._elements[t]) {
        this._elements[t].text(t);
      }
    }
    this.action = action;
    this.$node.dialog("open");
  }
}

/* Private
 * Finds required elements to populate this._elements property.
 **/
ConfirmationDialog.setElements = function($node, dataNodeNames) {
  var elements = {};
  var $buttons = $node.find(".ui-dialog-buttonset button");
  for(var i=0; i<dataNodeNames.length; ++i) {
    elements[dataNodeNames[i]] = $node.find("[data-node='heading']");
  }

  // Added by the jQueryUI widget but hard to get.
  elements.ok = $buttons.eq(0);
  elements.cabcel = $buttons.eq(1);
  this._elements = elements;
}



// Make available for importing.
export { ConfirmationDialog };

