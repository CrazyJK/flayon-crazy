;(function($) {
	var $slidesjs, viewHistory = [];

	$.fn.slideview = function(options) {

		$.fn.slideview.defaults = {
				width: 800,
				height: 550,
				interval: 5000
		};

		var opts = $.extend({}, $.fn.slideview.defaults, options);
		
		$("#slides").css({width: opts.width});
		
		$(this).slidesjs({
			start: currentVideoIndex,
	        width: opts.width,
	        height: opts.height,
	        navigation: {active: true, effect: "slide"},
	        pagination: {active: true, effect: "fade"},
	        play: {active: true, interval: opts.interval, auto: false, effect: "slide"},
	        callback: {
	        	loaded: function(number) {
	        		$.fn.rePagination(number-1);
	        	},
	        	start: function(number) {
	        	},
	        	complete: function(number) {
	        		$.fn.rePagination(number-1);
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
		$slidesjs = $(this).data("plugin_slidesjs");
		
		// UI : navigation position
		$(".slidesjs-navigation").hide();
		$(".slidesjs-play, .slidesjs-stop").css({
		    position: 'fixed',
	    	left: '20px',
	    	bottom: '15px'
		});
		$(".slidesjs-play, .slidesjs-random").show();

		// Event
	    $(".slidesjs-random").on("click", $.fn.randomView);
	    $("#content_div").on("mousewheel mousedown", $.fn.navEvent);
	    $(window).on("keyup", $.fn.navEvent);
	};

	$.fn.rePagination = function(index) {
		//console.log("$.fn.rePagination", index);
	    if (totalVideoSize == 1) {
	    	$(".slidesjs-slide").css({left: 0});
	    }
	    $(".slidesjs-pagination-item").each(function() {
	    	var itemIdx = parseInt($(this).children().attr("data-slidesjs-item"));
	    	if ((itemIdx < index + 5 && itemIdx > index - 5) || itemIdx == 0 || itemIdx == totalVideoSize-1)
	    		$(this).show();
	    	else
	    		$(this).hide();
	    });
		$(".slidesjs-slide[slidesjs-index='" + index + "'] > div").randomBG(0.5);
		setLocalStorageItem(THUMBNAMILS_COVER_INDEX, index);
		
		var slideNo = index + 1;
		//console.log("rePagination slideNo=", slideNo);
		if (!viewHistory.includes(slideNo)) {
			viewHistory.push(slideNo);
		}
	}
	
	$.fn.randomView = function(e) {
    	if (viewHistory.length == totalVideoSize) {
    		viewHistory = [];
    		showSnackbar('All video seen');
    	}
		var selectedNo = getRandomInteger(1, totalVideoSize);
		if (viewHistory.includes(selectedNo)) {
			//console.log("randomView 본거", selectedNo);
			$.fn.randomView();
		}
		else {
			viewHistory.push(selectedNo);
	    	$slidesjs.goto(selectedNo);
	    	//console.log("randomView", viewHistory, selectedNo);
		}
	}

	$.fn.navEvent = function(e) {
		if (e.target.tagName === 'SELECT' || e.target.tagName === 'INPUT') {
			console.log("navEvent", e.target.tagName, "pass", e.target);
			return;
		}
			
		var delta  = mousewheel(e);
		var which  = mouseClick(e);
		var signal = delta || e.keyCode || which;
		// console.log(e.target.tagName, "event.type", e.type, "[mousewheel delta", delta, "] [keyup : keyCode", e.keyCode, "] [mousedown : which", which, "] = " + signal);
		switch(signal) {
			case 1 : // mouse : wheel up
			case 37: // key : left
			case 40: // key : down
				$slidesjs.previous();
				break;
			case -1 : // mouse : wheel down
			case 39: // key : right
			case 38: // key : up
				$slidesjs.next();
				break;
			case 34 : // key : PageDown
				$.fn.randomView();
				break;
			case 1002 : // click : middle
				fnRandomPlay();
				break;
			case 1001 : // click : left
			case 1003 : // click : right
			case 32: // key : space
			case 13: // key : enter
				break;
		}
		e.stopImmediatePropagation();
		e.preventDefault();
		e.stopPropagation();
	}

	$.slide = {
			focusVideo: function(opus) { // random play로 선태된 슬라이드 보이기 
				var idx = parseInt($("#opus-" + opus).attr("slidesjs-index")) + 1;
				$slidesjs.goto(idx);
			}
	}
	
}(jQuery));
