import { DefaultPage } from './page_default';
import { EditableContentPage } from './page_editable_content';
import { FormOverviewPage } from './page_form_overview';


// Always runs when document ready.
//
$(document).ready(function() {

  switch(app.page.type) {
    case "services":
         if($("#form-overview").length) {
           new FormOverviewPage();
         }
         break;
    case "pages":
         new EditableContentPage();
         break;
    default: new DefaultPage();
  }
});

