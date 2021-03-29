/**
 * Publish Controller
 * ----------------------------------------------------
 * Description:
 * Adds functionality for the Publish FB Editor view.
 *
 * Documentation:
 *
 *     - Requires jQuery & jQueryUI
 *       https://api.jquery.com/
 *       https://api.jqueryui.com/
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


import { mergeObjects, safelyActivateFunction, isFunction, post } from './utilities';
import { ActivatedFormDialog } from './component_activated_form_dialog';
import { DefaultPage } from './page_default';


class PublishController extends DefaultPage {
  constructor(app) {
    super();

    switch(app.page.action) {
      case "create":
        PublishController.create.call(this, app);
        // Allow fallthrough to share index action as well.
      case "index":
        PublishController.index.call(this, app);
        break;
    }
  }
}


/* Setup for the Index action
 **/
	PublishController.index = function(app) {
  var controller = this;

  // Add show/hide to credential forms.
  $(".publish-form").each(function(i, el) {
    var $publishForm = $(el);
    var $content = $publishForm.find("fieldset");
    var $radios = $publishForm.find("input[type=radio]");
    var $submit = $publishForm.find("input[type=submit]");
    new ContentVisibilityController($content, $radios);
    new ActivatedFormDialog($publishForm, {
      cancelText: app.text.dialogs.button_cancel,
      okText: $submit.val(),
      activator: $submit
    });
  });
}


/* Set up for the Create action
 **/
PublishController.create = function(app) {
  // TODO: If no errors...
  this.dialog.content = {
    ok: app.text.dialogs.button_publish,
    heading: app.text.dialogs.heading_publish,
    message: app.text.dialogs.message_publish
  };

  this.dialog.open();
}


/* Show/hide content based on a yes/no type of radio button control.
 * @content (jQuery node) Content area to be shown/hidden
 * @config (Object) Configuration of widget
 *  e.g. {
 *         showActivators: $(elements-that-will-set-content-to-show-on-click),
 *         hideActivators: $(elements-that-will-set-content-to-hide-on-click),
 *         visibleOnLoad: Function || Boolean // Value should be true/false but you can pass a function to return such a value.
 *       }
 **/
class ContentVisibilityController {
  constructor($content, $radios) {
    // Set listener.
    $radios.eq(0).on("change", this.toggle.bind(this));
    $radios.eq(1).on("change", this.toggle.bind(this));
    this.$content = $content;
    this.$radios = $radios;
    this.toggle();
  }

  toggle() {
    // Set initial state.
    if(this.$radios.last().prop("checked") || this.$radios.last().get(0).checked) {
      this.$content.show();
    }
    else {
      this.$content.hide();
    }
  }
}


export { PublishController }
