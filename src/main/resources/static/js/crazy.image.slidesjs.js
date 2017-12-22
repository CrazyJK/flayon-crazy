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
		slidesjs;
		
	var	slidesWrapper = {
			build: function buildSlidesJS() {
				console.log("slidesWrapper.build");
				var slideHeight = $(window).height() - topOffset;
				var itemCount = Math.max(imageCount, coverCount);
	
				if (imageSource.value == 0) { // image
					currentIndex = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, 0)) - 1;
					if (currentIndex >= imageCount)
						currentIndex = getRandomInteger(0, imageCount-1);
				}
				else { // cover
					currentIndex = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, 0)) - 1;
					if (currentIndex >= coverCount)
						currentIndex = getRandomInteger(0, coverCount-1);
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
				    navigation: {active: false},
				    pagination: {active: false},
				    play: {active: false, interval: playInterval.value * 1000, auto: false},
				    callback: {
				    	loaded: function(number) {
				    	},
				    	start: function(number) {
				    	},
				    	complete: function(number) {
				    		console.log("slidejs callback complete", number-1);
				    		slidesWrapper.view(number-1);
				    	}
				    }
				});
				slidesjs = $slides.data("plugin_slidesjs");
			},
			next: function() {
				if (nextMethod.value == 0) {
					if (currentIndex < (imageSource.value == 0 ? imageCount : coverCount)) {
						slidesjs.next();
					}
					else {
						slidesjs.goto(1);
					}
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
			    $(".page-no").html(currentIndex);

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
				slidesWrapper.prev(); 
			},
			next: function(showEffect, showOptions, showDuration) {
				slidesWrapper.next(); 
			},
			playCallback: function(status) {
				if (status) {
					$("body, .progress-bar, .label, .page-no").addClass("label-black");
				}
				else {
					$("body, .progress-bar, .label, .page-no").removeClass("label-black");
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


