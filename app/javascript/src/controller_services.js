/**
 * Services Controller
 * ----------------------------------------------------
 * Description:
 * Adds functionality for the FB Editor service views.
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



import { mergeObjects, post } from './utilities';
import { ActivatedMenu } from './component_activated_menu';
import { ActivatedDialog } from './component_activated_dialog';
import { DefaultPage } from './page_default';


class ServicesController extends DefaultPage {
  constructor(app) {
    super();

    switch(app.page.action) {
      case "edit":
        ServicesController.edit.call(this, app);
        break;
    }
  }
}


/* Setup for the Edit action
 **/
ServicesController.edit = function(app) {
  let $document = $(document);
  // Bind document event listeners to control functionality not specific to a single component or where
  // a component can be activated by more than one element (prevents complicated multiple element binding/handling).
  $document.on("PageActionMenuSelection", pageActionMenuSelection.bind(this) );
  $document.on("PageAdditionMenuSelection", pageAdditionMenuSelection.bind(this) );

  // Create dialog for handling new page input and error reporting.
  new PageCreateDialog(this, $("[data-component='PageCreateDialog']"));


  // Create the context menus for each page thumbnail.
  $("[data-component='PageActionMenu']").each((i, el) => {
    new PageActionMenu(this, $(el), {
      selection_event: "PageActionMenuSelection",
      preventDefault: true, // Stops the default action of triggering element.
      menu: {
        position: { at: "right+2 top-2" }
      }
    });
  });

  // Create the menu for Add Page functionality.
  $("[data-component='PageAdditionMenu']").each((i, el) => {
    new PageActionMenu(this, $(el), {
      selection_event: "PageAdditionMenuSelection",
      menu: {
        position: { at: "right+2 top-2" } // Position second-level menu in relation to first.
      }
    });
  });
}


/* Wrap the create page form in a dialog effect.
 * Errors will also show here on page return.
 **/
class PageCreateDialog {
  constructor(page, $node, config) {
    var pageCreateDialog = this;
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
        pageCreateDialog.$form.submit();
      },
      onClose: () => {
        pageCreateDialog.clearErrors();
      }
    });

    // Disable button as we're replacing it.
    $submit.attr("disabled", true);

    this.$form = $form;
    this.$submit = $submit;
    this.$errors = $errors;
  }

  clearErrors() {
    this.$errors.remove();
    this.$errors.parents().removeClass(".govuk-form-group--error");
  }
}


/* Controls form step add/edit/delete/preview controls
 **/
class PageActionMenu {
  constructor(page, $node, config) {
    var conf = mergeObjects({
      activator_classname: $node.data("activator-classname"),
      container_id: $node.data("activated-menu-container-id"),
      activator_text: $node.data("activator-text")
    }, config);

    this.menu = new ActivatedMenu($node, conf);
  }
}


/* Handle item selections on the form step context
 * menu elements.
 * TODO: What are other actions?
 **/
function pageActionMenuSelection(event, data) {
  var element = data.original.element;
  var action = data.activator.data("action");
  switch(action) {
    case "edit":
         location.href = element.href;
         break;

    case "preview":
         window.open(element.href);
         break;

    case "add":
         $("#ActivatedMenu_AddPage").trigger("component.open", {
           my: "left top",
           at: "right top",
           of: element
         });
         break;

    case "delete":
          this.dialogConfirmationDelete.content = {
            heading: app.text.dialogs.heading_delete.replace(/%{label}/, data.component.$node.data("page-heading")),
            ok: app.text.dialogs.button_delete_page
          };
          this.dialogConfirmationDelete.confirm({}, function() {
            post(element.href, { _method: "delete" });
          });
         break;

    default: console.log(data.activator.href);
  }
}


/* Controls what happens when user selects a page type.
 * 1). Clear page_type & component_type values in hidden form.
 * (if we then have new values):
 * 2). Set new page_type & component_type in hidden form.
 * 3). Close the open menu
 * 4). Open the form URL input dialog.
 **/
function pageAdditionMenuSelection(event, data) {
  var $pageTypeInput = $("#page_page_type");
  var $componentTypeInput = $("#page_component_type");
  var $activator = data.activator.find("> a");

  // First reset to empty.
  $pageTypeInput.val("");
  $componentTypeInput.val("");

  // Then add any found values.
  if($activator.length) {
    $pageTypeInput.val($activator.data("page-type"));
    $componentTypeInput.val($activator.data("component-type"));

    data.component.close();
    $("#new-page-create-dialog").dialog("open");
  }
}


export { ServicesController }
