import { ActivatedMenu } from './component_activated_menu';
import { ActivatedDialog } from './component_activated_dialog';
import { editableComponent } from './editable_components';


// Always runs when document ready.
//
$(document).ready(function() {
  applyFormDialogs();
  applyMenus();
  bindDocumentEventsForPagesSection();
  bindEditableContentHandlers();
});

// Controls all the Editable Component setup for each page.
// TODO: Add more description on how this works.
function bindEditableContentHandlers($area) {
  var $editContentForm = $("#editContentForm");
  var $saveButton = $editContentForm.find(":submit");
  var editableContent = [];
  if($editContentForm.length) {
    $saveButton.attr("disabled", true); // disable until needed.
    $(".fb-editable").each(function(i, node) {
      var $node = $(node);
      editableContent.push(editableComponent($node, {
        editClassname: "active",
        data: $node.data("fb-content-data"),
        filters: {
          _id: function(index) {
            return this.replace(/^(.*)?[\d]+$/, "$1" + index);
          },
          value: function(index) {
            return this.replace(/^(.*)?[\d]+$/, "$1" + index);
          }
        },
        form: $editContentForm,
        id: $node.data("fb-content-id"),
        selectorDisabled: "input:not(:hidden), textarea",
        selectorQuestion: "label",
        selectorHint: "span",
        selectorGroupQuestion: ".govuk-heading-xl",
        selectorCollectionQuestion: ".govuk-heading-xl",
        selectorCollectionHint: "fieldset > .govuk-hint",
        selectorCollectionItem: ".govuk-radios__item, .govuk-checkboxes__item",
        text: $node.data("fb-content-text"),
        onSaveRequired: function() {
          // Code detected something changed to
          // make the submit button available.
          $saveButton.attr("disabled", false);
        },
        type: $node.data("fb-content-type")
      }));
    });

    // Set focus on first editable component for design requirement.
    if(editableContent.length > 0) {
      editableContent[0].focus();
    }

    // Add handler to activate save functionality from the independent 'save' button.
    $editContentForm.on("submit", (e) => {
      for(var i=0; i<editableContent.length; ++i) {
        editableContent[i].save();
      }
    });
  }
}

// Bind document event listeners for the 'Pages' section of
// form builder. This will only do something if the main
// ".form-overview" container is found. It is used to control
// functionality not specific to a single component or where
// a component can be activated by more than one element (so
// prevents complicated multiple element binding/handling.
//
function bindDocumentEventsForPagesSection() {
  if($(".form-overview").length) {
    let $document = $(document);

    $document.on("FormStepContextMenuSelection", formStepContextMenuSelection);
    $document.on("AddPageTypeMenuSelection", addPageTypeMenuSelection);
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


// Handle item selections on the form step context
// menu elements.
// TODO: What are other actions?
//
function formStepContextMenuSelection(event, data) {
  var $link = data.activator.find("a");
  var fragId = findFragmentIdentifier($link.attr("href"))
  switch(fragId) {
    case "edit-page": console.log("edit page");
         break;

    case "preview-page": console.log("preview page");
         break;

    case "add-page-here":
         $("#ActivatedMenu_AddPage").trigger("component.open", {
           my: "left top",
           at: "right top",
           of: $link
         });
         break;

    case "delete-page": console.log("delete page");
         break;

    default: console.log(data.activator.href);
  }
}


// Utility funciton
// Return the fragment identifier value from a URL.
// Intended for use on an href value rather than document
// location, which can use location.hash.
// e.g. pass in
// "http://foo.com#something" or
// "http://foo.com#something?else=here"
// and get "something" in either case.
//
function findFragmentIdentifier(url) {
  return url.replace(/^.*#(.*?)(?:(\?).*)?$/, "$1");
}


// Finds navigation elements structured to become Activated Menu
// effects and wraps them with the required functionality.
//
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

    $(document.body).append(menu.container);
  });
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
        "ui-activator": "govuk-button"
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
