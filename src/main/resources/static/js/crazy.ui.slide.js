(function($) {
	$.fn.slideview = function(options) {

		var opts = $.extend({}, $.fn.slideview.defaults, options);
		
		$(this).slidesjs({
			start: currentVideoIndex,
	        width: opts.width,
	        height: opts.height,
	        navigation: {active: true, effect: "slide"},
	        pagination: {active: true, effect: "fade"},
	        play: {active: true, interval:5000, auto: false, effect: "slide"},
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
	            	speed: 300
	            },
	            fade: {
	            	speed: 1000, crossfade: true
	            }
	        }
		});
		$(".slidesjs-navigation").hide();
//	    $(".slidesjs-previous").html("Prev");
		$(".slidesjs-play, .slidesjs-stop").css({
		    position: 'fixed',
	    	left: '20px',
	    	bottom: '15px'
		});
		$(".slidesjs-play").show();
	    $(".slidesjs-random").show().click(function() {
			var selectedNumber = getRandomVideoIndex() -1; // getRandomInteger(0, totalVideoSize);
			$("a[data-slidesjs-item='" + selectedNumber + "']").click();
		});

		$(window).bind("mousewheel DOMMouseScroll", function(e) {
			var delta = mousewheel(e);
			if (delta > 0) // 휠 위로
				$.fn.previousView();
		    else // 휠 아래로
		    	$.fn.nextView();
		});
		$(window).bind("keyup", function(e) {
			var event = window.event || e;
			switch(event.keyCode) {
			case 37: // left
			case 40: // down
				$.fn.previousView();
				break;
			case 39: // right
			case 38: // up
				$.fn.nextView(); 
				break;
			//case 32: // space
			case 34: // PageDown key
				$.fn.randomView(); 
				break;
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
		var index = currentIndex();
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
		$(".slidesjs-slide[slidesjs-index='" + index + "'] > div").randomBG(0.5);
		setLocalStorageItem(THUMBNAMILS_COVER_INDEX, index);
	}
	$.fn.previousView = function() {
		$(".slidesjs-previous").click();
	}
	$.fn.nextView = function() {
    	$(".slidesjs-next").click(); 
	}
	$.fn.randomView = function() {
		$(".slidesjs-random").click();
	}

	function currentIndex() {
		return parseInt($(".slidesjs-pagination-item>.active").attr("data-slidesjs-item"));
	}
	
	$.slide = {
		focusVideo: function(opus) {
			var idx = $("#opus-" + opus).attr("slidesjs-index");
			$("a[data-slidesjs-item='" + idx + "']").click();
		}
	}
	
})(jQuery);
