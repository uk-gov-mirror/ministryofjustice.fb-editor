// console.log("app/javascript/services/index.js");
$(document).ready(function() {
  applyDialog();
});

// Creates the modal dialog effect for the new form input
// TODO: Extract the text to pull in from HTML+JS mechanism.
function applyDialog() {
  var $dialog = $("#new-service-create-dialog");
  var $activator = $("<button class=\"govuk-button\">\</button>");
  var $form = $("#new_service_creation");

  if($dialog.length) {
    $dialog.dialog({
      autoOpen: false,
      buttons: {
        "Create a new form": function() {
          $form.submit();
          $( this ).dialog( "close" );
        },
        Cancel: function() {
          $( this ).dialog( "close" );
        }
      },
      classes: {
        "ui-button": "govuk-button"
      },
      closeOnEscape: false,
      height: "auto",
      modal: true,
      resizable: false
    });

    // Design requires an activator be added dynamically.
	  $activator.text("Create a new form");
    $activator.button().on( "click", function() {
      $dialog.dialog( "open" );
    });

    $(".fb-editor-form-list").after($activator);

    // POST will redirect to same page but with errors,
    // so we need to auto-open the dialog for user to see.
    if($dialog.find(".govuk-form-group--error").length) {
      $dialog.dialog("open");
    }
  }
}
