;
(function($) {
	$.fn.swapClass = function(class1, class2, cond) {
		return this.each(function() {
			var $element = $(this);
			if (cond) {
				$element.switchClass(class1, class2);
			} else {
				$element.switchClass(class2, class1);
			}
		});
	};

	$.fn.randomBG = function(alpha) {
		return this.each(function() {
			var $element = $(this);
			$element.css("background-color", getRandomColor(alpha));
		});
	};

	$.fn.navEvent = function(callback) {
		/**
		 * detect event signal 
		 * @returns 
			case    1 : // mousewheel : up
			case   -1 : // mousewheel : down
			case 1001 : // mousedown  : left click
			case 1002 : // mousedown  : middle click
			case 1003 : // mousedown  : right click
			case   13 : // key : enter
			case   32 : // key : space
			case   33 : // key : PageUp
			case   34 : // key : PageDown
			case   36 : // key : home
			case   37 : // key : left
			case   38 : // key : up
			case   39 : // key : right
			case   40 : // key : down
			case   45 : // key : Insert
			case   46 : // key : delete
			case   83 : // key : 's'
			case   97 : // key : keypad 1
			case   98 : // key : keypad 2 
			case   99 : // key : keypad 3
			case  100 : // key : keypad 4 
			case  101 : // key : keypad 5 
			case  102 : // key : keypad 6 
			case  103 : // key : keypad 7 
			case  104 : // key : keypad 8 
			case  105 : // key : keypad 9 
		 */
		var detectEvent = function(e, method) {
			method(
				(e.type === 'mousewheel' || e.type === 'DOMMouseScroll') ? mousewheel(e) :
					(e.type === 'keyup') ? e.keyCode :
						(e.type === 'mouseup' || e.type === 'mousedown') ? e.which + 1000 :
							(e.type === 'contextmenu') ? 1003 : 0
			);
			stopEvent(e);
		};

		return this.each(function() {
			var self = $(this);
			self.off().on("mousewheel DOMMouseScroll mouseup", function(e) {
				detectEvent(e, callback);
			});
			browser === FIREFOX && self.on("contextmenu", function(e) {
				detectEvent(e, callback);
			});
			$(window).on("keyup", function(e) {
				detectEvent(e, callback);
			});
		});
	}

}(jQuery));
