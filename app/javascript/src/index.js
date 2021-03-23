import { DefaultPage } from './page_default';
import { EditableContentPage } from './page_editable_content';
import { FormOverviewPage } from './page_form_overview';


// Always runs when document ready.
//
$(document).ready(function() {
  switch(app.page.controller) {
    case "services":
         if(app.page.action == "edit") {
           new FormOverviewPage();
         }
         break;
    case "pages":
         if(app.page.action == "create") {
           new FormOverviewPage();
         }
         else {
           new EditableContentPage();
         }
         break;
    default: new DefaultPage();
  }
});

