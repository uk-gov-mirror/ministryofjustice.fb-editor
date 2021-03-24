/**
 * Publish Controller
 * ----------------------------------------------------
 * Description:
 * Adds functionality for the Publish FB Editor view.
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


import { mergeObjects, post } from './utilities';
import { DefaultPage } from './page_default';


class PublishController extends DefaultPage {
  constructor(action) {
    super();

    switch(action) {
      case "index":
        console.log("PublishController#index");
        break;
    }
  }
}


export { PublishController }
