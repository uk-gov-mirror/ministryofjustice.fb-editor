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


/* See jQueryUI Dialog for config options (all are passed straight in).
 * Extra config options specific to this enhancement
 * config.classes["ui-activator"] will put the value in activator classes value.
 **/
class ActivatedDialog {
  constructor($dialog, config) {
    var conf = config || {};
    var buttons = {};
    var classes = conf.classes || {};
    this._config = conf;
    this.$node = $dialog;
    this.activator = createDialogActivator($dialog, conf.activatorText, classes["ui-activator"]);

    buttons[conf.submitText] = () => {
      conf.form.submit();
      this.close();
    }

    buttons[conf.cancelText] = () => {
      this.close();
    }

    $dialog.dialog({
      autoOpen: conf.autoOpen || false,
      buttons: buttons,
      classes: classes,
      closeOnEscape: true,
      height: "auto",
      modal: true,
      resizable: false
    });
  }

  open() {
    this.$node.dialog("open");
  }

  close() {
    var action = this._config.onClose;
    this.$node.dialog("close");
    if(action && (typeof(action) === 'function' || action instanceof Function)) {
      action();
    }
  }
}


// Creates a button and links with the passed dialog element.
// @$dialog (jQuery object) Target dialog element enhanced with dialog funcitonality.
// @text    (String) Text that will show on the button.
// @classes (String) Classes added to button.
//
function createDialogActivator($dialog, text, classes) {
  var $activator = $("<button>\</button>");
  $activator.text((text || "open dialog")); 
  $activator.addClass(classes);
  $activator.on( "click", () => {
    $dialog.dialog( "open" );
  });

  $dialog.before($activator);
  return $activator;
}


// Make available for importing.
export { ActivatedDialog };

