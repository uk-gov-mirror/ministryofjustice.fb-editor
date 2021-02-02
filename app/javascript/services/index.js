import { ActivatedMenu } from '../components/component_activated_menu';


// Always runs when document ready.
//
$(document).ready(function() {
  applyFormDialogs();
  applyMenus();
});


// Finds navigation elements structured to become Activated Menu
// effects and wraps them with the required functionality.
//
function applyMenus() {
  $(".component-activated-menu").each(function(i, el) {
    var $menu = $(el);
    new ActivatedMenu($menu, {
      activator_classname: $menu.data("activator-classname"),
      activator_text: $menu.data("activator-text"),
      menu: {
        position: { at: "right+2 top-2" }
      }
    });
  });
}


// Finds forms structured to become dialog effects and
// wraps them with the required functionality.
//
function applyFormDialogs() {
	$(".component-dialog-form").each(function(i, el) {
    var $dialog = $(el);
    var $form = $dialog.find("form");

    // Design requires an activator be added dynamically.
    // Create and place it before enhancing the dialog
    // because that functionality will move and hide the
    // dialog element.
    $dialog.before(createDialogActivator($dialog, $dialog.data("activator-text")));

    // Enhance target element with desired functionality.
    createFormDialog($dialog, {
      form: $form,
      cancel_text: $dialog.data("cancel-text"),
      submit_text: $form.find(":submit").val()
    });
  });
}


// Creates a buttons and links with the passed dialog element.
// @$dialog (jQuery object) Target dialog element enhanced with dialog funcitonality.
// @text    (String) Text that will show on the button.
function createDialogActivator($dialog, text) {
  return $("<button class=\"govuk-button\">\</button>").on( "click", function() {
             $dialog.dialog( "open" );
           }).text(text);
}

// Enhances a dialog wrapped form with required (popup) functionlity.
// @dialog (Node) Target element that will become the dialog.
// @config (Object) Properties and elements that will be required for dialog build.
//
function createFormDialog($dialog, config) {
  var buttons = {}

  buttons[config.submit_text] = function() {
    config.$form.submit();
    $(this).dialog( "close" );
  }

  buttons[config.cancel_text] = function() {
    $(this).dialog("close");
  }

  $dialog.dialog({
    autoOpen: false,
    buttons: buttons,
    classes: {
      "ui-button": "govuk-button"
    },
    closeOnEscape: false,
    height: "auto",
    modal: true,
    resizable: false
  });

  // POST will redirect to same page but with errors,
  // so we need to auto-open the dialog for user to see.
  if($dialog.find(".govuk-form-group--error").length) {
    $dialog.dialog("open");
  }
}
