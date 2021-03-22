/**
 * Default Page
 * ----------------------------------------------------
 * Description:
 * Adds standard functionality required for common FB Editor pages.
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


import { ActivatedDialog } from './component_activated_dialog';
import { ConfirmationDialog } from './component_confirmation_dialog';


class DefaultPage {
  constructor() {
    createConfirmationDialog();
  }
}


function createConfirmationDialog() {
  $("[data-component='ConfirmationDialog']").each(function() {
    var $template = $(this);
    var $node = $($template.text());
    if($template.length && $node.length) {
      new ConfirmationDialog($node, {
        autoOpen: false,
        cancelText: $template.data("text-cancel"),
        okText: $template.data("text-ok"),
        classes: {
          "ui-activator": "govuk-button fb-govuk-button",
          "ui-button": "govuk-button",
          "ui-dialog": $template.data("classes")
        }
      });
    }
  });
}


export { DefaultPage }
