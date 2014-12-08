# Javascripts

Here you can find all folders related to the frontend javsascript.

### Collections

These are the Backbone collections in the app. They all extend Backbone.Collection. They are namespaced under `Visio.Collections`. The actual class name uses the singular form. For example, the `Operation` class will be named `Visio.Collections.Operation` rather than `Visio.Collections.Operations` since Collections already denotes plural.

### Figures

These are the figure views found in Axis. A figure can be a dashboard or a small graph. A figure is essentially one <svg> element and its containing svg elements. There are no html elements embedded in the svg. These are namespaced under `Visio.Figures`. Each figure has its own naming shortcute. For example, ABSY stands for Achievement Budget Single Year. The last two characters will be either `sy` or `my` to signify if it's over time or a single year. The first two digits describe what the graph is showing (`ab` is Achievement Budget). See `visio.js.coffee` for documentation of each acronym.

### Helpers

Helpers are global utility classes. Namely you will find `Visio.Utils` here. However, this also where any native `prototype` modification is done.

### Labels

Very few figure have labels, but labels are changing text on the figure. They are not tooltips (so they do not appear in a popup) and they are not legends because the text changes dynamically with different data. For example, the ISY (Indicator Single Year) figure has labels, tooltips and a legend. The labels show the hierarchy of the indicator while the tooltip shows the values of the indicator. They are namespaced under `Visio.Labels`.

### Legends

Legends are the description to the figure. The legend filenames have the same conventions as the figures to easily find legends that match with the figure. They are namespaced under `Visio.Legends`.

### Managers

These are all the managers for the different pages. The only one currently is for the CMS. The one used for most pages can be found in `manager.js.coffee`

### Mixins

These are mixins that can be added to any class/views. For example, views that need to be a `modal` can simply include the modal mixin and become a modal. These are namespaced under `Visio.Mixins`.

### Models

These are the Backbone models in the app. They all extend `Backbone.Model`. They are namespaced under `Visio.Models`.

### Routers

These are the Backbone routers in the app. They all extend `Backbone.Router`. The are namespaced under `Visio.Routers`. In general, each page has a different router.

### Templates

These are the templates that match up with the views expressed in the `views` folder and `figures` folders. It attempts to mirror the same folder structure but diverges in some cases. To find the template, simple check the view for it's `template` property.

### Vendor

These are all 3rd party libraries used in the app.

### Views

These are the Backbone views in the app. The all extend `Backbone.View`. They are namespaced under `Visio.Views`.
