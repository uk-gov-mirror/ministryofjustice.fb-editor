import { DefaultPage } from './page_default';
import { PagesController } from './controller_pages';
import { FormOverviewPage } from './page_form_overview';
import { FormListPage } from './page_form_list';
import { PublishController } from './controller_publish'


// Always runs when document ready.
//
$(document).ready(function() {
  switch(controllerAndAction()) {
    case "ServicesController#index":
    case "ServicesController#create":
         new FormListPage();
    break;

    case "ServicesController#edit":
    case "PagesController#create":
         new FormOverviewPage();
    break;

    case "PagesController#edit":
         new PagesController(app);
    break;

    case "PublishController#index":
    case "PublishController#create":
         new PublishController(app);
    break;

    default:
         console.log(controllerAndAction());
         new DefaultPage();
  }
});


function controllerAndAction() {
  var controller = app.page.controller.charAt(0).toUpperCase() + app.page.controller.slice(1);
  return controller + "Controller#" + app.page.action;
}
