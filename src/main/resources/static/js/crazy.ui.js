(function($) {
	$.fn.swapClass = function(class1, class2, cond) {
		return this.each(function() {
			var $element = $(this);
			if (cond) {
				$element.removeClass(class1).addClass(class2);
			} else {
				$element.removeClass(class2).addClass(class1);
			}
		});
	};
	$.fn.randomBG = function(alpha) {
		return this.each(function() {
			var $element = $(this);
			$element.css("background-color", randomColor(alpha));
		});
	};
})(jQuery);
