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


import { Dialog } from './component_dialog';
import { ConfirmationDialog } from './component_confirmation_dialog';


class DefaultPage {
  constructor() {
    this.dialog = createDialog.call(this);
    this.dialogDelete = createConfirmationDialog.call(this);
  }
}


function createDialog() {
  var $template = $("[data-component-template=Dialog]");
  var $node = $($template.text());
  return new Dialog($node, {
    autoOpen: false,
    okText: $template.data("text-ok"),
    classes: {
      "ui-button": "fb-govuk-button",
      "ui-dialog": $template.data("classes")
    }
  });
}


function createConfirmationDialog() {
  var $template = $("[data-component-template=ConfirmationDialogDelete]");
  var $node = $($template.text());
  return new ConfirmationDialog($node, {
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


export { DefaultPage }
