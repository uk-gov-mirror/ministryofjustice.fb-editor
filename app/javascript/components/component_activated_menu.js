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
    this.config = config;
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
    setMenuOpenPosition.call(this);
    this.container.show();
    this.state.open = true;
  }

  // Method
  close() {
    clearMenuOpenPosition.call(this);
    this.container.hide();
    this.state.open = false;
  }

  // Method
  action() {
    console.log("ActivateMenu.action");
  }
}

/* Positions the menu in relation to the activator  if received
 * a setting in passed configuration (this.config.position).
 * Uses the jQueryUI position() utility function to set the values.
 **/
function setMenuOpenPosition() {
  if(this.config && this.config.position) {
    console.log("Position the menu in relation to the activator");
    this.container.position({
      my: this.config.position.my,
      at: this.config.position.at,
      of: this.activator
    })
  }
}

/* Removes any position values that have occurred as a result of
 * calling the setMenuOpenPosition() function.
 * Note: This assumes that no external JS script is trying to 
 * set values independently of the ActivatedMenu class functionality.
 * Clearing the values is required to stop jQueryUI position()
 * functionality adding to existing, each time it's called.
 * An alternative might be to set position once, and not on each 
 * ActivatedMenu.open call. There is a minor performance gain that
 * could be claimed, but it would also be less flexible, if the 
 * activators (used for position reference) need to be dynamically
 * moved for any enhance or future design improvements. 
 **/
function clearMenuOpenPosition() {
  var node = this.container.get(0);
  node.style.left = "";
  node.style.right = "";
  node.style.top = "";
  node.style.bottom = "";
  node.style.position = "";
}

// Make available for importing.
export { ActivatedMenu };
