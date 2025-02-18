/**
 * Pages Controller
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


import { uniqueString, findFragmentIdentifier, updateHiddenInputOnForm } from './utilities';
import { ActivatedMenu } from './component_activated_menu';
import { DefaultPage } from './page_default';
import { editableComponent } from './editable_components';
import { ServicesController } from './controller_services';


class PagesController extends DefaultPage {
  constructor(app) {
    super();

    switch(app.page.action) {
      case "edit":
        PagesController.edit.call(this, app);
        break;
      case "create":
        PagesController.create.call(this, app);
        break;
    }
  }
}


/* Setup for the Edit action
 **/
PagesController.edit = function(app) {
  var $form = $("#editContentForm");
  this.$form = $form;
  this.editableContent = [];

  bindEditableContentHandlers.call(this, app);
  focusOnEditableComponent.call(this);

  // Bind document event listeners.
  $(document).on("AddComponentMenuSelection", AddComponent.MenuSelection.bind(this) );

  // Handle page-specific view customisations here.
  switch(this.type) {
    case "page.multiplequestions":
         editPageMultipleQuestionsViewCustomisations.call(this);
         break;

    case "page.singlequestion":
         // No customisations required for this view.
         break;

    case "page.content":
         editPageContentViewCustomisations.call(this);
         break;

    case "page.confirmation":
         // No customisations required for this view.
         break;

    case "page.checkanswers":
         editPageCheckAnswersViewCustomisations.call(this);
         break;
  }

  // Enhance any Add Content buttons
  $("[data-component=add-content]").each(function() {
    var $node = $(this);
    new AddContent($node, { $form: $form });
  });

  // Enhance any Add Component buttons.
  $("[data-component=add-component]").each(function() {
    var $node = $(this);
    new AddComponent($node, { $form: $form });
  });
}


/* Setup for the Create action
 **/
PagesController.create = function(app) {
  // Actually uses the Services controller due to view redirect on server.
  ServicesController.edit.call(this, app);
}


/* Gives add component buttons functionality to select a component type
 * from a drop menu, and update the 'save' form by activation of a 
 * global document event.
 * (see addComponentMenuSelection function)
 **/
class AddComponent {
  constructor($node) {
    var $list = $node.find("> ul");
    var $button = $node.find("> a");

    this.$list = $list;
    this.$button = $button;
    this.menu = new ActivatedMenu($list, {
      selection_event: "AddComponentMenuSelection",
      preventDefault: true, // Stops the default action of triggering element.
      activator: $button,
      menu: {
        position: { at: "right+2 top-2" }
      }
    });

    $node.addClass("AddComponent");
  }
}


/* Handle item selections on the AddComponent context menu elements.
 **/
AddComponent.MenuSelection = function(event, data) {
  var action = data.activator.data("action");
  updateHiddenInputOnForm(this.$form, "page[add_component]", action);
  this.$form.submit();
}


/* Gives add content buttons functionality to update the 'save' form.
 **/
class AddContent {
  constructor($node, config) {
    var $button = $node.find("> a");
    var fieldname = $node.data("fb-field-name") || "page[add_component]";
    this.$button = $button;
    this.$node = $node;

    $button.on("click.AddContent", function() {
      updateHiddenInputOnForm(config.$form, fieldname, "content");
      config.$form.submit();
    });

    $node.addClass("AddContent");
  }
}


/* Set focus on first editable component or, if a new component has been
 * added, the first element with that new component.
 **/
function focusOnEditableComponent() {
  var target = location.hash;
  if(target.match(/^[#\w\d_]+$/)) {
    // Newly added component with fragment identifier so find first
    // first editable item of last component.
    let $newComponent = $(target);
    if($newComponent.length) {
      $newComponent.data("instance").focus();
    }
  }
  else {
    // Standard editable page so find first editable item.
    if(this.editableContent.length > 0) {
      this.editableContent[0].focus();
    }
  }
}


/* Controls all the Editable Component setup for each page.
 * TODO: Add more description on how this works.
 **/
function bindEditableContentHandlers($area) {
  const SELECTOR_LABEL_STANDARD = "label h1, label h2";
  const SELECTOR_HINT_STANDARD = ".govuk-hint";

  var page = this;
  var $editContentForm = $("#editContentForm");
  var $saveButton = $editContentForm.find(":submit");
  if($editContentForm.length) {
    $saveButton.attr("disabled", true); // disable until needed.
    $(".fb-editable").each(function(i, node) {
      var $node = $(node);

      page.editableContent.push(editableComponent($node, {
        editClassname: "active",
        data: $node.data("fb-content-data"),
        attributeDefaultText: "fb-default-text",
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

        // Selectors for editable component labels/legends/hints, etc.
        selectorTextFieldLabel: SELECTOR_LABEL_STANDARD, // Also used by Number
        selectorTextFieldHint: SELECTOR_HINT_STANDARD,   // Also used by Number
        selectorTextareaFieldLabel: SELECTOR_LABEL_STANDARD,
        selectorTextareaFieldHint: SELECTOR_HINT_STANDARD,
        selectorGroupFieldLabel: "legend > :first-child", // Used by Date
        selectorGroupFieldHint: SELECTOR_HINT_STANDARD,   // Used by Date
        selectorCollectionFieldLabel: "legend > :first-child", // Used by Radios
        selectorCollectionFieldHint: "fieldset > .govuk-hint", // Used by Radios
        selectorCollectionItem: ".govuk-radios__item, .govuk-checkboxes__item", // Used by Radio and Checkbox option parent
        selectorComponentCollectionItemLabel: "label",               // Used by Radio and Checkbox options
        selectorComponentCollectionItemHint: SELECTOR_HINT_STANDARD, // Used by Radio and Checkbox options
        // Other selectors
        selectorDisabled: "input:not(:hidden), textarea",

        text: {
          addItem: app.text.actions.option_add,
          removeItem: app.text.actions.option_remove
        },
        onCollectionItemClone: function($node) {
           // @node is the collection item (e.g. <div> wrapping <input type=radio> and <label> elements)
           // Runs after the collection item has been cloned, so further custom manipulation can be
           // carried out on the element.
           $node.find("label").text(app.text.default_option);
           $node.find("span").text(app.text.default_option_hint);
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
          page.dialogConfirmationDelete.content = {
            heading: app.text.dialogs.heading_delete_option.replace(/%{option label}/, item._elements.label.$node.text()),
            ok: app.text.dialogs.button_delete_option
          };
          page.dialogConfirmationDelete.confirm({}, function() {
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

    // Add handler to activate save functionality from the independent 'save' button.
    $editContentForm.on("submit", (e) => {
      for(var i=0; i<page.editableContent.length; ++i) {
        page.editableContent[i].save();
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


/**************************************************************/
/* View customisations for PageController.edit actions follow */
/**************************************************************/


function editPageContentViewCustomisations() {
  var $button1 = $("[data-component=add-content]");
  var $target = $("#new_answers :submit");
  $target.before($button1);
}


function editPageCheckAnswersViewCustomisations() {
  var $button1 = $("[data-component=add-content]");
  var $target1 = $(".fb-editable").last();
  var $button2 = $button1.clone();
  var $target2 = $("#answers-form dl").first();
  $target1.after($button1);
  $target2.before($button2);
  $button2.attr("data-fb-field-name", "page[add_extra_component]");
}


function editPageMultipleQuestionsViewCustomisations() {
  var $button1 = $("[data-component=add-component]");
  var $target = $("#new_answers :submit");
  $target.before($button1);
}


export { PagesController }
