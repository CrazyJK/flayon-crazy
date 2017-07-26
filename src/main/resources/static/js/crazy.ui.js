;(function($) {
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
}(jQuery));


var randomColor = function(alpha) {
	if (!alpha)
		alpha = 1;
	else if (alpha === 'r')
		alpha = getRandom(0, 1);
	return "rgba(" + getRandomInteger(0,255) + "," + getRandomInteger(0,255) + "," + getRandomInteger(0,255) + "," + alpha + ")";
};
