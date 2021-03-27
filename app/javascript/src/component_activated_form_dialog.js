/**
 * Activated Form Dialog Component
 * ----------------------------------------------------
 * Description:
 * Wraps a form in Activated Dialog effect.
 * Clears errors on close/cancel, if they are shown.
 *
 * Documentation:
 *
 *     - jQueryUI
 *       https://api.jqueryui.com/dialog
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/


import { ActivatedDialog } from './component_activated_dialog';


class ActivatedFormDialog {
  constructor($form, config) {
    $form.before(config.activator);
    var activatedFormDialog = this;
    var $errors = $form.find(".govuk-error-message");

    new ActivatedDialog($form, {
      autoOpen: $errors.length ? true: false,
      cancelText: config.cancelText,
      okText: config.activator.val(),
      activator: config.activator,
      onOk: () => {
        activatedFormDialog.$form.submit();
      },
      onClose: () => {
        activatedFormDialog.clearErrors();
      }
    });

    this.$form = $form;
    this.$errors = $errors;
  }

  clearErrors() {
    this.$errors.parents().removeClass("govuk-form-group--error");
    this.$errors.remove();
  }
}


export { ActivatedFormDialog }
