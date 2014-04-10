String.prototype.hashCode = function(){
    var hash = 0, i, char;
    if (this.length == 0) return hash;
    for (i = 0, l = this.length; i < l; i++) {
        char  = this.charCodeAt(i);
        hash  = ((hash<<5)-hash)+char;
        hash |= 0; // Convert to 32bit integer
    }
    return hash;
};

d3.selection.prototype.moveToFront = function() {
  return this.each(function(){
    this.parentNode.appendChild(this);
  });
};

(function( $, undefined ) {

    $.extend($.ui.slider.prototype.options, {
        dragAnimate: true
    });

    var _mouseCapture = $.ui.slider.prototype._mouseCapture;
    $.widget("ui.slider", $.extend({}, $.ui.slider.prototype, {
        _mouseCapture: function(event) {
            _mouseCapture.apply(this, arguments);
            this.options.dragAnimate ? this._animateOff = false : this._animateOff = true;
            return true;
        }
    }));

}(jQuery));


