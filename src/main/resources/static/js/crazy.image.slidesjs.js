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

	var SLIDESJS_SOURCE_MODE   = "slidesjs.source.mode",
		SLIDESJS_PLAY_INTERVAL = "slidesjs.play.interval",
		currentIndex,
		imageCount,
		imageMap,
		coverCount,
		coverMap,
		topOffset = 30+5,
		SlidejsApp = function() {
			this.init();
		},
		configBox = (function() {
			var previousMode;
			return {
				init: function() {
					// event
					$("[data-role='switch']").on('click', function() {
						var target = $(this).attr("data-target");
						var value  = $(this).attr("data-value");
						var text   = $(this).text();
						$("#" + target).val(value);
						$("." + target).html(text);
						$("[data-target='" + target + "']").removeClass("active-switch");
						$(this).addClass("active-switch");
					});
					$("input[type='range'][role='switch']").on('click keyup', function(e) {
						var value = $(this).val();
						var target = $(this).attr("id");
						$("[data-target='" + target + "'][data-value='" + value + "']").click();
						e.stopImmediatePropagation();
						e.preventDefault();
						e.stopPropagation();
					});
					$("#interval").on('click keyup', function(e) {
						$(".interval").html($(this).val());
						e.stopImmediatePropagation();
						e.preventDefault();
						e.stopPropagation();
					});
					$("#configModal").on("hidden.bs.modal", function() {
						setLocalStorageItem(SLIDESJS_SOURCE_MODE,   sourceMode.value);
						setLocalStorageItem(SLIDESJS_PLAY_INTERVAL, interval.value);
						if (previousMode != sourceMode.value)
							slidesWrapper.init();
						previousMode == sourceMode.value;
						
						slidesWrapper.setPlayInterval(interval.value);
					});
	
					// initiate
					var slidesjsSouuceMode   = getLocalStorageItem(SLIDESJS_SOURCE_MODE,   getRandomInteger(0, 1));
					var slidesjsPlayInterval = getLocalStorageItem(SLIDESJS_PLAY_INTERVAL, getRandomInteger(5, 20));
					$("[data-target='sourceMode'][data-value='" + slidesjsSouuceMode + "']").click();
					$("#interval").val(slidesjsPlayInterval).click();
					previousMode = slidesjsSouuceMode;
					console.log("configBox.init");
				}
			};
		}()),
		slidesWrapper = (function() {
			
			var slidesjs,
				addEventListener = function() {
					$(window).on("resize", event.resize);
		//			$("#slides").off().on("mousedown", event.nav);
					$(".slidesjs-control").navEvent(event.nav);
					$(".slidesjs-play").on('click', event.play);
					$(".slidesjs-stop").on('click', event.stop);
					$(".label-title").on("click", event.popup);
					console.log("slidesWrapper.addEventListener");
				},
				event = {
					nav: function(signal) {
						console.log("slidesWrapper.event.nav", signal);
						switch(signal) {
							case 1 : // mouse : wheel up
							case 37: // key : left
							case 40: // key : down
							case 1003 : // click : right
								slidesWrapper.prev(); 
								break;
							case -1 : // mouse : wheel down
							case 39: // key : right
							case 38: // key : up
							case 1001 : // click : left
								slidesWrapper.next(); 
								break;
							case 32: // key : space
							case 1002 : // click : middle
								slidesWrapper.random(); 
								break;
							case 13: // key : enter
								break;
						}
					},
					resize: function(e) {
						$('.slides, .slidesjs-container, .slidesjs-control, .bg-image').height($(window).height() - topOffset).width($(window).width());
					},
					play: function(e) {
						$("body").css("background", "#000");
						$(".slidesjs-pagination").hide();
						$(".slidesjs-navigation, .label-title").css("background-color", "#000");
					},
					stop: function(e) {
						$("body").css("background", "#fff");
						$(".slidesjs-pagination").show();
						$(".slidesjs-navigation, .label-title").css("background-color", "#5bc0de");
					},
					popup: function(e) {
						if (sourceMode.value == 0) { // image
							popupImage(PATH + "/image/" + currentIndex);
						}
						else {
							fnVideoDetail(coverMap[currentIndex]);
						}
					}
				},
				build = function buildSlidesJS() {
					var slideHeight     = $(window).height() - topOffset;
					var thumbnailsIndex = sourceMode.value == 0 ? THUMBNAMILS_IMAGE_INDEX : THUMBNAMILS_COVER_INDEX; 
					var itemCount       = sourceMode.value == 0 ? imageCount : coverCount;
					currentIndex        = parseInt(getLocalStorageItem(thumbnailsIndex, getRandomInteger(0, itemCount-1)));
		
					$("#container-slidesjs").empty().append(
							$("<div>", {id: "slides", "class": "slides"})
					);
					var $slides = $("#slides");
					for (var i=0; i<itemCount; i++) {
						$slides.append(
								$("<div>").addClass("bg-image").height(slideHeight)
						);
					}
					$slides.slidesjs({
						start: currentIndex + 1,
						width: $(window).width(),
						height: slideHeight,
					    navigation: {active: true},
					    play: {active: true, interval: interval.value * 1000, auto: false},
					    callback: {
					    	loaded: function(number) {
					    		console.log("slidejs loaded", number);
					    		slidesWrapper.view(number-1);
					    	},
					    	start: function(number) {
					    		console.log("slidejs start", number);
					    	},
					    	complete: function(number) {
					    		console.log("slidejs complete", number);
					    		slidesWrapper.view(number-1);
					    	}
					    }
					});
					slidesjs = $slides.data("plugin_slidesjs");
					showSnackbar(sourceMode.value == 0 ? "Image mode" : "Cover mode");
					console.log("slidesWrapper.build", sourceMode.value == 0 ? "Image mode" : "Cover mode", "itemCount", itemCount, "currentIndex", currentIndex, "interval", interval.value);
				};
		
			return {
				init: function() {
					build();
					addEventListener();
				},
				next: function() {
					slidesjs.next();
					console.log("slidesWrapper.next");
				},
				prev: function() {
					slidesjs.previous();
					console.log("slidesWrapper.prev");
				},
				random: function(chosenNumber) {
					currentIndex = getRandomInteger(1, (sourceMode.value == 0 ? imageCount : coverCount));
					slidesjs.goto(currentIndex);
					console.log("slidesWrapper.random", currentIndex);
				},
				view: function rePagination(index) {
					currentIndex = index;
				    
				    var slideSrc =   sourceMode.value == 0 ? PATH + "/image/" + currentIndex : PATH + "/video/" + coverMap[currentIndex] + "/cover";
				    var slideTitle = sourceMode.value == 0 ? imageMap[currentIndex] : coverMap[currentIndex];
				    
					$("div[slidesjs-index='" + currentIndex + "']").css({"background-image": "url(" + slideSrc + ")"});
				    $(".label-title").html(slideTitle);
				        
				    $(".slidesjs-pagination-item").each(function() {
				    	var itemIdx = parseInt($(this).children().attr("data-slidesjs-item"));
				    	if (itemIdx > currentIndex + 1 || itemIdx < currentIndex - 1) {
				    		$(this).hide();
				    	}
				    	else {
				    		$(this).show();
				    	}
				    });
					setLocalStorageItem((sourceMode.value == 0 ? THUMBNAMILS_IMAGE_INDEX : THUMBNAMILS_COVER_INDEX), currentIndex);
					console.log("slidesWrapper.view", currentIndex);
				},
				setPlayInterval : function(second) {
					slidesjs.setPlayInterval(second * 1000);
				}
			};
		}());

	SlidejsApp.prototype = {
			constructor: SlidejsApp,
			init: function() {
				var self = this;
				$(document).ready(function() { 
					self.start();
				});
			},
			start: function() {
				console.log("SlidejsApp.start START");
				$.ajax({
					type: "GET",
					url: PATH + "/rest/image/data"
				}).done(function(data, textStatus, jqXHR) {
					coverCount = data['coverCount'];
					coverMap   = data['coverNameMap'];
					imageCount = data['imageCount'];
					imageMap   = data['imageNameMap'];
					console.log("requestData DONE", textStatus, jqXHR.status);
					
					configBox.init();
					slidesWrapper.init();
				});
				console.log("SlidejsApp.start END");
			}
	};

	return new SlidejsApp();

}));


