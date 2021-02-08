import { ActivatedMenu } from './component_activated_menu';


// Always runs when document ready.
//
$(document).ready(function() {
  applyFormDialogs();
  applyMenus();
  bindDocumentEventsForPagesSection();
});


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

    // Design requires an activator be added dynamically.
    // Create and place it before enhancing the dialog
    // because that functionality will move and hide the
    // dialog element.
    $dialog.before(createDialogActivator($dialog, $dialog.data("activator-text")));

    // Enhance target element with desired functionality.
    createFormDialog($dialog, {
      form: $form,
      cancel_text: $dialog.data("cancel-text"),
      submit_text: $form.find(":submit").val()
    });
  });
}


// Creates a button and links with the passed dialog element.
// @$dialog (jQuery object) Target dialog element enhanced with dialog funcitonality.
// @text    (String) Text that will show on the button.
//
function createDialogActivator($dialog, text) {
  return $("<button class=\"govuk-button\">\</button>").on( "click", function() {
             $dialog.dialog( "open" );
           }).text(text);
}

// Enhances a dialog wrapped form with required (popup) functionlity.
// @dialog (Node) Target element that will become the dialog.
// @config (Object) Properties and elements that will be required for dialog build.
//
function createFormDialog($dialog, config) {
  var buttons = {}

  buttons[config.submit_text] = function() {
    config.form.submit();
    $(this).dialog( "close" );
  }

  buttons[config.cancel_text] = function() {
    $(this).dialog("close");
  }

  $dialog.dialog({
    autoOpen: false,
    buttons: buttons,
    classes: {
      "ui-button": "govuk-button"
    },
    closeOnEscape: false,
    height: "auto",
    modal: true,
    resizable: false
  });

  // POST will redirect to same page but with errors,
  // so we need to auto-open the dialog for user to see.
  if($dialog.find(".govuk-form-group--error").length) {
    $dialog.dialog("open");
  }
}
