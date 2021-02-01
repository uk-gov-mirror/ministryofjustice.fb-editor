// Always runs when document ready.
//
$(document).ready(function() {
  applyFormDialogs();
  applyMenus();
});

function applyMenus() {
  var $menu = $(".component-activated-menu");

  new ActivatedMenu($menu, {
    activator_text: $menu.data("activator-text"),
    menu: {
      position: { at: "right+2 top-2" }
    }
  });
}

class ActivatedMenu {
  constructor($menu, config) {
    this.activator = $("<button class=\"ActivatedMenu_Activator\"></button>");
    this.container = $("<div class=\"ActivatedMenu_Container\"></div>");
    this.menu = $menu;
    this.state = {
      open: false
    }

    this.menu.before(this.container);
    this.menu.menu(config.menu); // Bit confusing but is how jQueryUI adds effect to eleemnt.

    this.menu.on("menuselect", function() {
      console.log("Menu select");
    });

    if(config.activator_classname) {
      this.activator.addClass(config.activator_classname);
    }

    this.activator.text(config.activator_text);
    this.activator.on("click.ActivatedMenu", () => {
      if(this.state.open) {
        this.close();
      }
      else {
        this.open();
      }
    });

    this.container.append(this.menu);
    this.container.before(this.activator);

    this.close();
  }

  // Method
  open() {
    console.log("ActivateMenu.open");
    this.container.show();
    this.state.open = true;
  }

  // Method
  close() {
    console.log("ActivateMenu.close");
    this.container.hide();
    this.state.open = false;
  }

  // Method
  action() {
    console.log("ActivateMenu.action");
  }
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
