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

import { mergeObjects, safelyActivateFunction } from './utilities';


/* See jQueryUI Dialog for config options (all are passed straight in).
 *
 * Extra config options specific to this enhancement
 * config.classes["ui-activator"]  will put the value in activator classes value.
 * config.onOk takes a function to run when 'Ok' button is activated.
 * config.onCancel takes a function to run when 'Cancel' button is activated.
 * config.onClose takes a function to run after dialog is closed.
 **/
class ActivatedDialog {
  constructor($dialog, config) {
    var conf = mergeObjects({}, config);
    var activator = new Activator($dialog, conf);
    var buttons = {};

    // Make sure classes is an object even if nothing passed.
    conf.classes = mergeObjects({}, config.classes);

    buttons[conf.okText] = () => {
      safelyActivateFunction(this._config.onOk);
    }

    buttons[conf.cancelText] = () => {
      safelyActivateFunction(this._config.onCancel);
      this.close();
    }

    $dialog.dialog({
      autoOpen: conf.autoOpen || false,
      buttons: buttons,
      classes: conf.classes,
      closeOnEscape: true,
      height: "auto",
      modal: true,
      resizable: false,
      close: conf.onClose
    });

    $dialog.parents(".ui-dialog").addClass("ActivatedDialog");

    this._config = conf;
    this.$node = $dialog;
    this.$node.data("instance", this);
    this.activator = activator;
  }

  open() {
    this.$node.dialog("open");
  }

  close() {
    this.$node.dialog("close");
  }
}


class Activator {
  constructor($dialog, config) {
    var $node = config.activator;
    if(!$node || $node.length < 1) {
      $node = createActivator($dialog, config.activatorText, config.classes["ui-activator"]);
    }

    $node.on( "click", () => {
      $dialog.dialog( "open" );
    });

    this.$dialog = $dialog;
    this.$node = $node;
  }
}

/* Creates a button and links with the passed dialog element.
 * @$dialog (jQuery object) Target dialog element enhanced with dialog funcitonality.
 * @text    (String) Text that will show on the button.
 * @classes (String) Classes added to button.
 **/
function createActivator($dialog, text, classes) {
  var $activator = $("<button>\</button>");
  $activator.text((text || "open dialog")); 
  $activator.addClass(classes);
  $dialog.before($activator);
  return $activator;
}


// Make available for importing.
export { ActivatedDialog };

