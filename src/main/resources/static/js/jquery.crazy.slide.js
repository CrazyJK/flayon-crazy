(function($) {
	$.fn.slideview = function(options) {

		var opts = $.extend({}, $.fn.slideview.defaults, options);
		
		$(this).slidesjs({
			start: currentVideoIndex,
	        width: opts.width,
	        height: opts.height,
	        navigation: {active: true, effect: "slide"},
	        pagination: {active: true, effect: "slide"},
	        play: {active: true, interval:5000, auto: false, effect: "fade"},
	        callback: {
	        	loaded: function(number) {
	        		$.fn.rePagination();
	        	},
	        	start: function(number) {
	        		$.fn.rePagination();
	        	},
	        	complete: function(number) {
	        	}
	        },
	        effect: {
	            slide: {
	            	speed: 1000
	            },
	            fade: {
	            	speed: 1000, crossfade: true
	            }
	        }
		});
	    $(".slidesjs-previous").html("Prev");
	    $(".slidesjs-random").click(function() {
			var selectedNumber = getRandomInteger(0, totalVideoSize);
			$("a[data-slidesjs-item='" + selectedNumber + "']").click();
		});

		$(window).bind("mousewheel DOMMouseScroll", function(e) {
			var delta = mousewheel(e);
			if (delta > 0) 
				$(".slidesjs-previous").click(); // 휠 위로
		    else 	
		    	$(".slidesjs-next").click(); // 휠 아래로
		});
		$(window).bind("keyup", function(e) {
			var event = window.event || e;
			switch(event.keyCode) {
			case 37: // left
			case 40: // down
				$(".slidesjs-previous").click(); break;
			case 39: // right
			case 38: // up
				$(".slidesjs-next").click(); break;
			//case 32: // space
			case 34: // PageDown key
				$(".slidesjs-random").click(); break;
			case 13: // enter
				break;
			}
		});
		$(window).on("mousedown", function(event) {
			switch (event.which) {
			case 1: // left click
				break;
			case 2: // middle click
				fnRandomPlay();
				break;
			case 3: // right click
				break;
			}
		});

	};

	$.fn.slideview.defaults = {
			width: 800,
			height: 550
	};
	
	$.fn.rePagination = function() {
	    if (totalVideoSize == 1) {
	    	console.log("slidesjs-slide left 0");
	    	$(".slidesjs-slide").css("left", "0");
	    }
		var index = parseInt($(".slidesjs-pagination-item>.active").attr("data-slidesjs-item"));
	    //console.log("active index", index);
	    $(".slidesjs-pagination-item").each(function() {
	    	var itemIdx = parseInt($(this).children().attr("data-slidesjs-item"));
	    	
	    	if ((itemIdx < index + 5 && itemIdx > index - 5) || itemIdx == 0 || itemIdx == totalVideoSize-1) {
	    		$(this).show();
	    	}
	    	else {
	    		$(this).hide();
	    	}
	    });
	}

	$.slide = {
		focusVideo: function(opus) {
			var idx = $("#opus-" + opus).attr("slidesjs-index");
			$("a[data-slidesjs-item='" + idx + "']").click();
		}
	}
	
})(jQuery);
