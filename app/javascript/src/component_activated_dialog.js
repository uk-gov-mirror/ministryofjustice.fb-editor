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
 *
 * Extra config options specific to this enhancement
 * config.classes["ui-activator"]  will put the value in activator classes value.
 * config.onOk takes a function to run when 'Ok' button is activated.
 * config.onCancel takes a function to run when 'Cancel' button is activated.
 * config.onClose takes a function to run after dialog is closed.
 **/
class ActivatedDialog {
  constructor($dialog, config) {
    var conf = config || {};
    var buttons = {};
    var classes = conf.classes || {};
    this._config = conf;
    this.$node = $dialog;
    this.activator = createDialogActivator($dialog, conf.activatorText, classes["ui-activator"]);

    buttons[conf.okText] = () => {
      executeFunction(this._config.onOk);
    }

    buttons[conf.cancelText] = () => {
      executeFunction(this._config.onCancel);
      this.close();
    }

    $dialog.dialog({
      autoOpen: conf.autoOpen || false,
      buttons: buttons,
      classes: classes,
      closeOnEscape: true,
      height: "auto",
      modal: true,
      resizable: false,
      close: this._config.onClose
    });
  }

  open() {
    this.$node.dialog("open");
  }

  close() {
    this.$node.dialog("close");
  }
}


/* Checks if is a function and, if so, runs it.
 * func (Function) Required function to execute.
 **/
function executeFunction(func) {
  if(func && (typeof(func) === 'function' || func instanceof Function)) {
    func();
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

