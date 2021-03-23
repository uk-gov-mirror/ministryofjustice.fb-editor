/**
 * Form Overview Page
 * ----------------------------------------------------
 * Description:
 * Adds functionality for the form overview (all pages) FB Editor view.
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


import { findFragmentIdentifier } from './utilities';
import { ActivatedMenu } from './component_activated_menu';
import { ActivatedDialog } from './component_activated_dialog';
import { DefaultPage } from './page_default';


class FormOverviewPage extends DefaultPage {
  constructor() {
    super();
    applyMenus();
    applyFormDialogs();
    bindDocumentEventsForPagesSection();
  }
}


/* Finds navigation elements structured to become Activated Menu
 * effects and wraps them with the required functionality.
 **/
function applyMenus() {
  $(".component-activated-menu").each(function(i, el) {
    var $menu = $(el);
    var menu =  new ActivatedMenu($menu, {
      activator_classname: $menu.data("activator-classname"),
      container_id: $menu.data("activated-menu-container-id"),
      activator_text: $menu.data("activator-text"),
      selection_event: $menu.data("document-event"),
      menu: {
        position: { at: "right+2 top-2" } // Position second-level menu in relation to first.
      }
    });
  });
}


// Bind document event listeners for the 'Pages' section of
// form builder. This will only do something if the main
// "#form-overview" container is found. It is used to control
// functionality not specific to a single component or where
// a component can be activated by more than one element (so
// prevents complicated multiple element binding/handling.
//
function bindDocumentEventsForPagesSection() {
  if($("#form-overview").length) {
    let $document = $(document);

    $document.on("FormStepContextMenuSelection", formStepContextMenuSelection);
    $document.on("AddPageTypeMenuSelection", addPageTypeMenuSelection);
  }
}


// Handle item selections on the form step context
// menu elements.
// TODO: What are other actions?
//
function formStepContextMenuSelection(event, data) {
  event.preventDefault();
  var element = data.original.element;
  var action = data.activator.data("action");
  switch(action) {
    case "edit": console.log("edit page");
         break;

    case "preview": console.log("preview page");
         break;

    case "add":
         $("#ActivatedMenu_AddPage").trigger("component.open", {
           my: "left top",
           at: "right top",
           of: element
         });
         break;

    case "delete": console.log("delete page");
         break;

    default: console.log(data.activator.href);
  }
}


// Controls what happens when user selects a page type.
// 1). Clear page_type & component_type values in hidden form.
// (if we then have new values):
// 2). Set new page_type & component_type in hidden form.
// 3). Close the open menu
// 4). Open the form URL input dialog.
//
function addPageTypeMenuSelection(event, data) {
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


// Finds forms structured to become dialog effects and
// wraps them with the required functionality.
//
function applyFormDialogs() {
	$(".component-dialog-form").each(function(i, el) {
    var $dialog = $(el);
    var $form = $dialog.find("form");
    var $submit = $form.find(":submit");
    var $errors = $dialog.find(".govuk-form-group--error");

    new ActivatedDialog($dialog, {
      autoOpen: $errors.length ? true: false,
      cancelText: $dialog.data("cancel-text"),
      okText: $submit.val(),
      activatorText: $dialog.data("activator-text"),
      classes: {
        "ui-button": "govuk-button",
        "ui-activator": "govuk-button fb-govuk-button"
      },
      onOk: () => {
        $form.submit();
      },
      onClose: () => {
        $errors.removeClass("govuk-form-group--error");
        $errors.find(".govuk-error-message").remove();
      }
    });

    // Disable button as we're replacing it.
    $submit.attr("disabled", true);

  });
}



export { FormOverviewPage }
