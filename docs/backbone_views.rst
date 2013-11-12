Backbone Views
==============

OmniSearch - omnisearch_view.js
-------------------------------

*description*

*functions*

initialize - Sets view state
  params: options

onKeyUp - Routes event to search

search - Takes in a query with a given callback function. Will make ajax request to server for desired search query. The callback will receive list of results along with an error (will be undefined if no error).
  params: query, callback
  output: object containing keys to two lists of results, indicators and operations.

render - Renders result list under `el`


NavigationPanel - navigation_panel_view.js
------------------------------------------

*description*

*functions*

initialize - Sets view state
  params: options

render - renders list of navigation dropdown items based on options sent in

NavigationDropdown - navigation_dropdown_view.js
------------------------------------------------

*description*

*functions*

initialize - Sets view state
  params: options

render - renders a dropdown. will use omnisearch view for additional searching

onToggleDropdown - handles event of clicking expand button

expand - will expand dropdown and expose options

contract - will contract dropdown to hide options

onParameterClick - handles the event when someone unchecks or checks a parameter
