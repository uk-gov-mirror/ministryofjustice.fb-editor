/**
 * Utility functions
 * ----------------------------------------------------
 * Description:
 * Collection of useful utility functions for script inclusion.
 *
 * Requires: jQuery
 * Documentation:
 *
 *
 *     - TODO:
 *       (steven.burnell@digital.justice.gov.uk to add).
 *
 **/



// Single level object merging.
// Merges object b into object a.
// Returns the changed object a.
// Does not merge nested level objects.
// Duplicate properties overwrite existing.
function mergeObjects(a, b) {
  for(var i in b) {
    if(b.hasOwnProperty(i)) {
      a[i] = b[i]
    }
  }
  return a;
}

// Make available for importing.
export { mergeObjects };
