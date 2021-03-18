import { uniqueString } from './utilities';
import { ActivatedMenu } from './component_activated_menu';
import { ActivatedDialog } from './component_activated_dialog';
import { editableComponent } from './editable_components';



// Always runs when document ready.
//
$(document).ready(function() {
  createConfirmationDialog();
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
        onItemAdd: function($node) {
          // @$node (jQuery node) Node (instance.$node) that has been added.
          // Runs after adding a new Collection item.
          // This adjust the view to wrap Remove button with desired menu component.
          //
          // This is not very good but expecting it to get significant rework when
          // we add more menu items (not for MVP).
          collectionItemControlsInActivatedMenu($node, {
            classnames: "editableCollectionItemControls"
          });
        },
        onItemRemove: function(item) {
          // @item (EditableComponentItem) Item to be deleted.
          // Runs before removing an editable Colleciton item.
          // Currently not used but added for future option and consistency
          // with onItemAdd (provides an opportunity for clean up).
          var activatedMenu = item.$node.data("ActivatedMenu");
          if(activatedMenu) {
            activatedMenu.activator.$node.remove();
            activatedMenu.$node.remove();
            activatedMenu.container.$node.remove();
          }
        },
        onSaveRequired: function() {
          // Code detected something changed to
          // make the submit button available.
          $saveButton.attr("disabled", false);
        },
        type: $node.data("fb-content-type")
      }));
    });

    // If any Collection items are present with ability to be removed, we need
    // to find them and scoop up the Remove buttons to put in menu component.
    $(".EditableComponentCollectionItem").each(function() {
      collectionItemControlsInActivatedMenu($(this), {
        classnames: "editableCollectionItemControls"
      });
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
  });
}


/* Finds elements to wrap in Activated Menu component.
 * Best used for dynamically generated elements that have been injected into the page
 * through JS enhancement. If items existed in the template code, you could probably
 * just use an easier method such as applyMenus() function.
 *
 * This function will basically find desired elments, wrap each one with an <li> tag,
 * add those to a new <ul> element, and then create an ActivateMenu component from
 * that structure.
 *
 * @selector (String) jQuery compatible selector to find elements for menu inclusion.
 * @$node  (jQuery node) Wrapping element/container that should hold the elements sought.
 * effects and wraps them with the required functionality.
 **/
function collectionItemControlsInActivatedMenu($item, config) {
  var $elements = $(".EditableCollectionItemRemover", $item);
  if($elements.length) {
    $elements.wrapAll("<ul class=\"govuk-navigation\"></ul>");
    $elements.wrap("<li></li>");
    let menu = new ActivatedMenu($elements.parents("ul"), {
      container_classname: config.classnames,
      container_id: uniqueString("activatedMenu-"),
      menu: {
        position: { my: "left top", at: "right-15 bottom-15" } // Position second-level menu in relation to first.
      }
    });

    $item.data("ActivatedMenu", menu);
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
