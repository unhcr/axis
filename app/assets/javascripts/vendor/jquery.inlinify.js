$.fn.inlinify = function() {
  var rules, i, j, len, sheets, nodes, parent;

  sheets = document.styleSheets;

  // nodes should be children and actual node itself
  nodes = $.merge(this.find('*'), this)

  // No sheets so just return
  if (!sheets)
    return;

  for(i = sheets.length - 1; i >= 0; i--) {
    try {
      rules = sheets[i].cssRules || sheets[i].rules;
    } catch (err) {
      // Skip over external stylesheets in FF
      if (err.name === 'SecurityError') {
        console.log('Skipping cross-domain stylesheet');
        continue;
      } else {
        throw err;
      }
    }

    // No rules for sheet so continue
    if (!rules)
      continue;

    for (j = rules.length - 1; j >= 0; j--) {

      // Skip if hover style or no selectText
      if (!rules[j].selectorText || rules[j].selectorText.indexOf("hover") !== -1)
        continue;

      $ele = $(rules[j].selectorText);

      $ele.each(function (i, elem) {
        if (nodes.index(elem) !== -1) {
          elem.style.cssText = rules[j].style.cssText +  elem.style.cssText;
        }
      });
    }
  }

};
