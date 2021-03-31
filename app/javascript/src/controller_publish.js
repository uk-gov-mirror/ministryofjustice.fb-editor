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
        break;
      case "index":
        PublishController.index.call(this, app);
        break;
    }
  }
}


/* Setup for the Index action
 **/
PublishController.index = function(app) {
  setupPublishForms.call(this);

  // When to show 15 minute message.
  if(this.publishFormTest.firstTimePublish() || this.publishFormProd.firstTimePublish()) {
    this.dialog.content = {
      ok: app.text.dialogs.button_publish,
      heading: app.text.dialogs.heading_publish,
      message: app.text.dialogs.message_publish
    };

    this.dialog.open();
  }
}


/* Set up for the Create action
 **/
PublishController.create = function(app) {
  setupPublishForms.call(this);
}


/* Setup the Publish Form as an enhanced object.
 **/
class PublishForm {
  constructor($node) {
    var $content = $node.find("fieldset");
    var $radios = $node.find("input[type=radio]");
    var $submit = $node.find("input[type=submit]");
    new ContentVisibilityController($content, $radios);
    new ActivatedFormDialog($node, {
      cancelText: app.text.dialogs.button_cancel,
      okText: $submit.val(),
      activator: $submit
    });

    this.$node = $node;
    this.$errors = $(".govuk-error-message", $node);
  }

  hasError() {
    return this.$errors.length > 0;
  }

  firstTimePublish() {
    return this.$node.data("first_publish");
  }
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


// Private

/* Find and setup publish forms
 **/
function setupPublishForms(page) {
  this.publishFormTest = new PublishForm($("#publish-form-dev"));
  this.publishFormProd = new PublishForm($("#publish-form-live"));
}

export { PublishController }
