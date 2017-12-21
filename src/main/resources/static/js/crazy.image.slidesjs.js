/**
 * 
 */
bgContinue = false;

(function (root, factory) {
    if (typeof define === 'function' && define.amd)
        define(['jquery'], factory);
    else if (typeof exports === 'object')
        module.exports = factory(require('jquery'));
    else
        root.slidesjsApp = factory(root.jQuery);
}(this, function ($) {

	var currentIndex,
		imageCount,
		imageMap,
		coverCount,
		coverMap,
		topOffset = 30+5,
		SlidejsApp = function() {
			this.init();
		},
		slidesjs,
		prevImageSource;
		
	var	slidesWrapper = {
			build: function buildSlidesJS() {
				console.log("slidesWrapper.build");
				var slideHeight = $(window).height() - topOffset;
				var itemCount;
	
				if (imageSource.value == 0) { // image
					currentIndex = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, 0)) - 1;
					if (currentIndex >= imageCount)
						currentIndex = getRandomInteger(0, imageCount-1);
					itemCount = imageCount;
				}
				else { // cover
					currentIndex = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, 0)) - 1;
					if (currentIndex >= coverCount)
						currentIndex = getRandomInteger(0, coverCount-1);
					itemCount = coverCount;
				}
				
				$("#container-slidesjs").empty().append(
						$("<div>", {id: "slides", "class": "slides"})
				);
				var $slides = $("#slides");
				for (var i = 0; i < itemCount; i++) {
					$slides.append(
							$("<div>").addClass("bg-image").height(slideHeight)
					);
				}
				$slides.slidesjs({
					start: currentIndex + 1,
					width: $(window).width(),
					height: slideHeight,
				    navigation: {active: true},
				    play: {active: false, interval: playInterval.value * 1000, auto: false},
				    callback: {
				    	loaded: function(number) {
				    		//console.log("slidejs callback loaded", number-1);
				    		//slidesWrapper.view(number-1);
				    	},
				    	start: function(number) {
				    		//console.log("slidejs callback start", number-1);
				    	},
				    	complete: function(number) {
				    		console.log("slidejs callback complete", number-1);
				    		slidesWrapper.view(number-1);
				    	}
				    }
				});
				slidesjs = $slides.data("plugin_slidesjs");
				
				prevImageSource = imageSource.value;
			},
			next: function() {
				if (nextMethod.value == 0) {
					slidesjs.next();
				}
				else {
					currentIndex = getRandomInteger(1, (imageSource.value == 0 ? imageCount : coverCount));
					slidesjs.goto(currentIndex);
				}
				console.log("slidesWrapper.next");
			},
			prev: function() {
				slidesjs.previous();
				console.log("slidesWrapper.prev");
			},
			view: function rePagination(index) {
				currentIndex = index;
			    
			    var slideSrc =   imageSource.value == 0 ? PATH + "/image/" + currentIndex : PATH + "/video/" + coverMap[currentIndex] + "/cover";
			    var slideTitle = imageSource.value == 0 ? imageMap[currentIndex] : coverMap[currentIndex];
			    
				$("div[slidesjs-index='" + currentIndex + "']").css({"background-image": "url(" + slideSrc + ")"});
			    $(".title").html(slideTitle);
			      
			    var range = 0;
			    $("li.slidesjs-pagination-item").each(function() {
			    	var itemIdx = parseInt($(this).children().attr("data-slidesjs-item"));
			    	if (itemIdx > currentIndex + range || itemIdx < currentIndex - range) {
			    		$(this).hide();
			    	}
			    	else {
			    		$(this).css({display: "inline-block"});
			    	}
			    });
			    $("ul.slidesjs-pagination").children().first().css({display: "inline-block"});
			    $("ul.slidesjs-pagination").children().last().css({display: "inline-block"});

				setLocalStorageItem((imageSource.value == 0 ? THUMBNAMILS_IMAGE_INDEX : THUMBNAMILS_COVER_INDEX), currentIndex);
				console.log("slidesWrapper.view", currentIndex);
			},
			resize: function(e) {
				$('.slides, .slidesjs-container, .slidesjs-control, .bg-image').height($(window).height() - topOffset).width($(window).width());
			},
			popup: function(e) {
				if (imageSource.value == 0) { // image
					popupImage(PATH + "/image/" + currentIndex);
				}
				else {
					fnVideoDetail(coverMap[currentIndex]);
				}
			}
	};

  	var fn = {
			prev: function(showEffect, showOptions, showDuration) {
				if (prevImageSource != imageSource.value)
					slidesWrapper.build();
				slidesWrapper.prev(); 
			},
			next: function(showEffect, showOptions, showDuration) {
				if (prevImageSource != imageSource.value)
					slidesWrapper.build();
				slidesWrapper.next(); 
			},
			playCallback: function(status) {
				if (status) {
					$("body, .progress-bar, .label").addClass("label-black");
					$(".slidesjs-pagination").hide();
					$(".slidesjs-navigation").css("background-color", "#000");
				}
				else {
					$("body, .progress-bar, .label").removeClass("label-black");
					$(".slidesjs-pagination").show();
					$(".slidesjs-navigation").css("background-color", "#5bc0de");
				}
			},
			nav: function(signal) {
			},
			eventListener: function() {
				$(window).on("resize", slidesWrapper.resize);
				$(".popup-image").on("click", slidesWrapper.popup);
			},
			init: function(data) {
				coverCount = data['coverCount'];
				coverMap   = data['coverNameMap'];
				imageCount = data['imageCount'];
				imageMap   = data['imageNameMap'];
				
				slidesWrapper.build();
				slidesWrapper.resize();
			}
	};
		
		
	SlidejsApp.prototype = {
			constructor: SlidejsApp,
			init: function() {
				var self = this;
				$(document).ready(function() { 
					self.start();
				});
			},
			start: function() {
				config.init("#container-slidesjs", fn.prev, fn.next, fn.playCallback, fn.nav, fn.eventListener, fn.init);
			}
	};

	return new SlidejsApp();

}));


