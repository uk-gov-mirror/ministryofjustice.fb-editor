/**
 * Editable Component Page
 * ----------------------------------------------------
 * Description:
 * Adds functionality required to enhance FB Editor form pages with editable components.
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


import { uniqueString, findFragmentIdentifier } from './utilities';
import { ActivatedMenu } from './component_activated_menu';
import { DefaultPage } from './page_default';
import { editableComponent } from './editable_components';


class EditableContentPage extends DefaultPage {
  constructor() {
    super();
    bindEditableContentHandlers.call(this);
  }
}


// Controls all the Editable Component setup for each page.
// TODO: Add more description on how this works.
function bindEditableContentHandlers($area) {
  var PAGE = this;
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
        text: {
          addItem: app.text.actions.option_add,
          removeItem: app.text.actions.option_remove
        },
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
          // Runs before removing an editable Collection item.
          // Provides an opportunity for clean up.
          var activatedMenu = item.$node.data("ActivatedMenu");
          if(activatedMenu) {
            activatedMenu.activator.$node.remove();
            activatedMenu.$node.remove();
            activatedMenu.container.$node.remove();
          }
        },
        onItemRemoveConfirmation: function(item) {
          // @item (EditableComponentItem) Item to be deleted.
          // Runs before onItemRemove when removing an editable Collection item.
          // Currently not used but added for future option and consistency
          // with onItemAdd (provides an opportunity for clean up).
          PAGE.dialogConfirmationDelete.content = {
            heading: app.text.dialogs.heading_delete_option.replace(/%{option label}/, item._elements.label.$node.text()),
            ok: app.text.dialogs.button_delete_option
          };
          PAGE.dialogConfirmationDelete.confirm({}, function() {
            item.component.remove(item);
          });
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


export { EditableContentPage }
