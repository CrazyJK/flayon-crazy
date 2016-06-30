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
})(jQuery);
