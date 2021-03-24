/**
 * Form List Page
 * ----------------------------------------------------
 * Description:
 * Adds functionality for the form list (index page) FB Editor view.
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
import { DefaultPage } from './page_default';


class FormListPage extends DefaultPage {
  constructor() {
    super();

    // Create dialog for handling new form input and error reporting.
    new FormCreateDialog(this, $("[data-component='FormCreateDialog']"));

  }
}


/* Wrap the create form form in a dialog effect.
 * Errors will also show here on page return.
 **/
class FormCreateDialog {
  constructor(page, $node, config) {
    var formCreateDialog = this;
    var $form = $node.find("form");
    var $submit = $form.find(":submit");
    var $errors = $node.find(".govuk-error-message");

    new ActivatedDialog($node, {
      autoOpen: $errors.length ? true: false,
      cancelText: $node.data("cancel-text"),
      okText: $submit.val(),
      activatorText: $node.data("activator-text"),
      classes: {
        "ui-button": "govuk-button",
        "ui-activator": "govuk-button fb-govuk-button"
      },
      onOk: () => {
        formCreateDialog.$form.submit();
      },
      onClose: () => {
        formCreateDialog.clearErrors();
      }
    });

    // Disable button as we're replacing it.
    $submit.attr("disabled", true);

    this.$form = $form;
    this.$submit = $submit;
    this.$errors = $errors;
  }

  clearErrors() {
    this.$errors.parents().removeClass("govuk-form-group--error");
    this.$errors.remove();
  }
}


export { FormListPage }
