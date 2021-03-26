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
import { DefaultPage } from './page_default';


class PublishController extends DefaultPage {
  constructor(action) {
    super();

    switch(action) {
      case "index":
        PublishController.index.call(this);
        break;
    }
  }
}


/* Setup for the Index action
 **/
PublishController.index = function() {

  // Add show/hide to credential forms.
  $(".publish-form").each(function(i, el) {
    var $publishForm = $(el);
    var $content = $publishForm.find("fieldset");
    var $radios = $publishForm.find("input[type=radio]");
    new contentVisibilityController($content, $radios);
  });
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
class contentVisibilityController {
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
