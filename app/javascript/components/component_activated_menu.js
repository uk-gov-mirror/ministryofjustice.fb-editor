/**
 * Activated Menu Component
 * ----------------------------------------------------
 * Description:
 * Enhances jQueryUI Menu component by adding a controlling activator.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/menu
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/

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
    this.container.show();
    this.state.open = true;
  }

  // Method
  close() {
    this.container.hide();
    this.state.open = false;
  }

  // Method
  action() {
    console.log("ActivateMenu.action");
  }
}

// Make available for importing.
export { ActivatedMenu };
