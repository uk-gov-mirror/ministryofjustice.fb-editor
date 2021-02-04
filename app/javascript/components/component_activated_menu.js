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
    this.config = config || {};
    this.menu = $menu;
    this.state = {
      open: false,
      position: null // Default is empty - update this dynamically
      // e.g. position = {
      //        my: "left top",
      //        at: "right bottom"
      //        of: this.activator
      //      }
    }

    this.menu.before(this.container);
    this.menu.menu(config.menu); // Bit confusing but is how jQueryUI adds effect to eleemnt.

    this.activator.text(config.activator_text);
    if(config.activator_classname) {
      this.activator.addClass(config.activator_classname);
    }

    if(config.container_id) {
      this.container.attr("id", config.container_id);
    }
    this.container.append(this.menu);
    this.container.before(this.activator);

    bindEventHandlers.call(this);
    setMenuOpenPosition.call(this);

    this.close();
  }

  // Method
  open() {
    this.container.show();
    this.state.open = true;
  }

  // Expected to be used by other elements/script calling the component.
  // Whatever calls it, is expected to pass component.state.position
  // requirements with the call.
  openRemote(position) {
    setMenuOpenPosition.call(this, position);
    this.open();
  }

  // Method
  close() {
    this.container.hide();
    this.state.open = false;

    // Clear any externally set component.state.position
    // and make sure it's reset to original.
    clearMenuOpenPosition.call(this);
    setMenuOpenPosition.call(this)
  }

  // Toggles the open/close functionality
  toggle() {
    if(this.state.open) {
      this.close();
    }
    else {
      this.open();
    }
  }
}

/* Positions the menu in relation to the activator  if received
 * a setting in passed configuration (this.config.position).
 * Uses the jQueryUI position() utility function to set the values.
 **/
function setMenuOpenPosition(position) {
  var pos = (position || this.config.position || {});
  this.container.position({
    my: (pos.my || "left top"),
    at: (pos.at || "right bottom"),
    of: (pos.of || this.activator)
  });
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
  this.state.position = null; // Reset because this one is set on-the-fly
}


/* Set event handlers on elements:
 *   - Menu selection
 *   - Injected Activator
 *   - Wrapping container
 **/
function bindEventHandlers() {
  var component = this;

  // Main (generated) activator uses this event to
  // open the menu.
  this.activator.on("click.ActivatedMenu", (event) => {
    component.state.activator = event.currentTarget;
    component.open();
  });

  // Open the menu by triggering this event from something else.
  // Probably need to pass in the positioning object
  // (see setMenuOpenPosition() function for details)
  this.container.on("ActivatedMenuOpen", (event, position) => {
    component.openRemote(position);
  });

  /* TODO: Need something like this for ESC key closing.
  this.container.on("keydown", (e) => {
    if(e.which == 27) {
      component.close();
    }
  });
  */

  // Add a trigger for any listening document event
  // to activate on menu item selection.
  if(this.config.selection_event) {
    let component = this;
    let selection_event = component.config.selection_event;
    component.menu.on("menuselect", function(event, ui) {
      event.preventDefault();
      $(document).trigger(selection_event, {
        activator: ui.item,
        menu: event.currentTarget,
        component: component
      });
    });
  }
}


// Make available for importing.
export { ActivatedMenu };

