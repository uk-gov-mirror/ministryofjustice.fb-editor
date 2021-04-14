// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.


// Scripts called by javascript_pack_tag
require("jquery")
require("jquery-ui")
require("showdown")
require("../src/index")

// Entry point for fb-editor stylesheets
import "../styles/application.scss"


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)


// Something appears to have broken console.log so reinstating using console.debug
if(window.console && console.debug) {
  console.log = console.debug;
}
