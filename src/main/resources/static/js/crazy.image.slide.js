/**
 *image/slide module
 */

var slide = (function() {

	var SLIDE_SOURCE_MODE   = "slide.source.mode",
		SLIDE_EFFECT_MODE   = "slide.effect.mode",
		SLIDE_PLAY_MODE     = "slide.play.mode",
		SLIDE_PLAY_INTERVAL = "slide.play.interval",

		currentIndex      = -1,
		selectedItemUrl   = "",
		selectedItemTitle = "",
		imageCount = 0,
		imageMap   = [],
		coverCount = 0,
		coverMap   = [],
		hideEffect, hideDuration, hideOptions,
		showEffect, showDuration, showOptions,
		prevMode = 0,

		image = {
				setLocalStorage: function() {
					setLocalStorageItem(SLIDE_SOURCE_MODE, sourceMode.value);
					setLocalStorageItem(SLIDE_EFFECT_MODE, effectMode.value);
					setLocalStorageItem(SLIDE_PLAY_MODE,     playMode.value);
					setLocalStorageItem(SLIDE_PLAY_INTERVAL, interval.value);
					timerEngine.setTime(interval.value);
					prevMode = sourceMode.value;
					console.log("    setLocalStorage", sourceMode.value, effectMode.value, playMode.value, interval.value);
				},
				nextEffect: function setNextEffect() {
					console.log("    nextEffect START");
					var effects = ["blind", "bounce", "clip", "drop", "explode", "fade", "fold", "highlight", "puff", "pulsate", "scale", "shake", "size", "slide"];
					if (effectMode.value == 1) {
						hideEffect   = effects[getRandomInteger(0, effects.length-1)];
						hideDuration = getRandomInteger(100, 1000);
						if (hideEffect === "scale")
							hideOptions = { percent: getRandomInteger(10, 50) };
						else if (hideEffect === "size")
							hideOptions = { to: { width: getRandomInteger(50, 200), height: getRandomInteger(50, 200) } };
						else
							hideOptions = {};
						showEffect   = effects[getRandomInteger(0, effects.length-1)];
						showDuration = getRandomInteger(100, 2000);
						if (showEffect === "scale")
							showOptions = { percent: getRandomInteger(10, 50) };
						else if (showEffect === "size")
							showOptions = { to: { width: getRandomInteger(50, 200), height: getRandomInteger(50, 200) } };
						else
							showOptions = {};
	
						$(".effectInfo").show().html(hideEffect + "(" + hideDuration + ") ▷ " + showEffect + "(" + showDuration + ")");
					}
					else {
						hideEffect = "fade";
						hideDuration = 500;
						hideOptions = {};
						showEffect = "fade";
						showDuration = 500;
						showOptions = {};
						$(".effectInfo").hide();
					}
					console.log("    nextEffect END", hideEffect, hideDuration, hideOptions, showEffect, showDuration, showOptions);
				},
				prevNumber: function getPrevNumber() {
					return currentIndex == 0 ? image.maxCount(-1) : currentIndex - 1;
				},
				nextNumber: function getNextNumber() {
					return currentIndex == image.maxCount(-1) ? 0 : currentIndex + 1;
				},
				first: function() {
					console.log("    first");
					image.view(0);
				},
				prev: function() {
					console.log("    prev");
					image.view(image.prevNumber());
				},
				next: function() {
					console.log("    next");
					image.view(image.nextNumber());
				},
				end: function() {
					console.log("    end");
					image.view(image.maxCount(-1));
				},
				random: function() {
					console.log("    random");
					image.view(getRandomInteger(0, image.maxCount(-1)));
				},
				view: function(current) {
					console.log("    view START", current);
					if (typeof current == 'undefined') { // first call
						if (sourceMode.value == 0) { // image
							currentIndex = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, 0));
							if (currentIndex >= imageCount)
								currentIndex = getRandomInteger(0, imageCount-1);
						}
						else { // cover
							currentIndex = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, 0));
							if (currentIndex >= coverCount)
								currentIndex = getRandomInteger(0, coverCount-1);
						}
					}
					else {
						currentIndex = parseInt(current);
					}
					
					if (sourceMode.value == 0) { // image
						selectedItemUrl = PATH + "/image/" + currentIndex;
						selectedItemTitle = imageMap[currentIndex];
						setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, currentIndex);
					}
					else {
						selectedItemUrl = PATH + "/video/" + coverMap[currentIndex] + "/cover";
						selectedItemTitle = coverMap[currentIndex];
						setLocalStorageItem(THUMBNAMILS_COVER_INDEX, currentIndex);
					}
					
					$("#imageDiv").hide(hideEffect, hideOptions, hideDuration, function() {
						$("#currNo").val(currentIndex);
						$("#endNo").html(image.maxCount(-1));
						$(".title").html(selectedItemTitle);
						console.log("    view call -> image.nextEffect");
						$(this).css({
							backgroundImage: "url('" + selectedItemUrl + "')"
						}).show(showEffect, showOptions, showDuration, image.nextEffect);
	
						console.log("    view call -> image.displayThumbnail");
						image.resize();
					});
					
					console.log("    view END", currentIndex, selectedItemUrl, selectedItemTitle);
				},
				delete: function() {
					console.log("    delete");
					if (sourceMode.value == 0) { // image
						var imgSrc = selectedItemUrl;
						if (confirm('Delete this image\n' + imgSrc)) {
							restCall(imgSrc, {method: "DELETE", title: "this image delete"});
							console.log("    delete call -> image.next");
							image.next();
						}
					}
				},
				popup: function() {
					console.log("    popup");
					if (sourceMode.value == 0) { // image
						popupImage(selectedItemUrl);
					}
					else {
						fnVideoDetail(coverMap[currentIndex]);
					}
				},
				play: function() {
					console.log("    play START");
					if (playMode.value == 1) {
						console.log("    play call -> image.random");
						image.random();
					}
					else { 
						console.log("    play call -> image.next");
						image.next();
					}
					console.log("    play END");
				},
				playCallback: function(status) {
					console.log("    playCallback START");
					if (status) {
						$("body, .progress-bar, .label").addClass("label-black");
						$("#thumbnailDiv").css('height', '5px').hide();
						$("#pagingArea, #effectInfoBox").hide();
					}
					else {
						$("body, .progress-bar, .label").removeClass("label-black");
						$("#thumbnailDiv").css('height', '105px').show('fade', {}, 1000);
						$("#pagingArea, #effectInfoBox").show();
					}
					console.log("    playCallback call -> image.resize");
					image.resize();
					console.log("    playCallback END");
				},
				resize: function() {
					console.log("    resize START");
					console.log("    resize call -> image.displayThumbnail");
					image.displayThumbnail();
					$("#imageDiv").height($(window).height() - $("#thumbnailDiv").outerHeight() - 35);
					console.log("    resize END");
				},
				displayThumbnail: function fnDisplayThumbnail() {
					console.log("    displayThumbnail START", currentIndex);
					if (currentIndex < 0)
						return;
					$("#thumbnailUL").empty();
					var itemCount = image.maxCount();
					var thumbnailRange = parseInt($(window).width() / (150 * 2));
					for (var current = currentIndex - thumbnailRange; current <= currentIndex + thumbnailRange; current++) {
						var thumbNo = current;
						if (thumbNo < 0 )
							thumbNo = itemCount + thumbNo;
						if (thumbNo >= itemCount)
							thumbNo = thumbNo - itemCount;
						var itemUrl = sourceMode.value == 0 ? PATH + "/image/" + thumbNo : PATH + "/video/" + coverMap[thumbNo] + "/cover";
						console.log("      displayThumbnail", itemUrl, thumbNo);
						$("<li>").append(
								$("<div>")
									.addClass("img-thumbnail " + (thumbNo == currentIndex ? "active" : ""))
									.css({backgroundImage: "url('" + itemUrl + "')"})
									.data("imgNo", thumbNo)
									.on("click", function() {
										image.view($(this).data("imgNo"));
									})
						).appendTo($("ul#thumbnailUL"));
					}
					console.log("    displayThumbnail END");
				},
				maxCount: function(i) {
					i = i || 0;
					return sourceMode.value == 0 ? imageCount + i : coverCount + i;
				},
				nav: function(signal) {
					switch(signal) {
						case 1 : // mouse : wheel up
						case 37: // key : left
						case 40: // key : down
						case 1003 : // click : right
							image.prev();
							break;
						case -1 : // mouse : wheel down
						case 39: // key : right
						case 38: // key : up
						case 1001 : // click : left
							image.next();
							break;
						case 32: // key : space
						case 1002 : // click : middle
							image.random();
							break;
						case 13: // key : enter
							image.view($(e.target).val());
							break;
					}
				}
		},
		/**
		 * add event listener
		 */
		addEventListener = function() {
	
			$(window).on("resize", image.resize);
	
			// for #navDiv
			$(".paging-first").on("click", image.first);
			$(".delete-image").on("click", image.delete);
			$(".popup-image" ).on("click", image.popup);
			$(".paging-end"  ).on("click", image.end);
			$("#currNo"      ).on("keyup", image.nav);
			
			// for #imageDiv
			$("#imageDiv").navEvent(image.nav);
	
			// for #configModal
			$("#configModal").on("hidden.bs.modal", function() {
				console.log("#configModal hidden.bs.modal", sourceMode.value, interval.value);
				$(".delete-image").toggle(sourceMode.value == 0);
				if (prevMode != sourceMode.value)
					image.view();
				image.setLocalStorage();
			});
			$("[data-role='switch']").on('click', function() {
				var target = $(this).attr("data-target");
				var value  = $(this).attr("data-value");
				var text   = $(this).text();
				$("#" + target).val(value);
				$("." + target).html(text);
				$("[data-target='" + target + "']").removeClass("active-switch");
				$(this).addClass("active-switch");
			});
			$("input[type='range'][role='switch']").on('click', function() {
				var value = $(this).val();
				var target = $(this).attr("id");
				$("[data-target='" + target + "'][data-value='" + value + "']").click();
			});
			$("#interval").on('click', function() {
				var value = $(this).val();
				$(".interval").html(value);
			});
			$(".btn-shuffle").on("click", function() {
				var shuffleOnce = function shuffleOnce() {
					$("[data-target='sourceMode'][data-value='" + getRandomInteger(0, 1) + "']").trigger("click");
					$("[data-target='effectMode'][data-value='" + getRandomInteger(0, 1) + "']").trigger("click");
					$("[data-target=  'playMode'][data-value='" + getRandomInteger(0, 1) + "']").trigger("click");
					$("#interval").val(getRandomInteger(5, 20)).trigger("click");
				};
				showSnackbar("shuffle start", 1000);
				var count = 0, maxShuffle = getRandomInteger(3, 9);
				var shuffler = setInterval(function() {
					shuffleOnce();
					if (++count > maxShuffle) {
					 	clearInterval(shuffler);
					 	showSnackbar("shuffle completed. try " + maxShuffle, 1000);
					 	image.setLocalStorage();
					}
				}, 500);
			});
		},
		/**
		 * manipulate dom
		 */
		manipulateDom = function() {
			console.log("  manipulateDom START");
			var slideSourceMode   = getLocalStorageItem(SLIDE_SOURCE_MODE,   getRandomInteger(0, 1));
			var slideEffectMode   = getLocalStorageItem(SLIDE_EFFECT_MODE,   getRandomInteger(0, 1));
			var slidePlayMode     = getLocalStorageItem(SLIDE_PLAY_MODE,     getRandomInteger(0, 1));
			var slidePlayInterval = getLocalStorageItem(SLIDE_PLAY_INTERVAL, getRandomInteger(5, 20));
			prevMode = slideSourceMode;
	
			$("[data-role='switch'][data-target='sourceMode'][data-value='" + slideSourceMode + "']").trigger("click");
			$("[data-role='switch'][data-target='effectMode'][data-value='" + slideEffectMode + "']").trigger("click");
			$("[data-role='switch'][data-target=  'playMode'][data-value='" + slidePlayMode   + "']").trigger("click");
			$("#interval").val(slidePlayInterval).trigger("click");
	
			console.log("  manipulateDom call -> image.resize");
			image.resize();
			console.log("  manipulateDom call -> image.nextEffect");
			image.nextEffect();
	
			console.log("  manipulateDom END", slideSourceMode, slideEffectMode, slidePlayMode, slidePlayInterval);
		},
		/**
		 * init module
		 */
		initModule = function() {
			restCall(PATH + '/rest/image/data', {}, function(data) {
				imageCount = data['imageCount'];
				imageMap   = data['imageNameMap'];
				coverCount = data['coverCount'];
				coverMap   = data['coverNameMap'];
				
				console.log("initModule", "getJSON", imageCount, coverCount, currentIndex);
	
				// play engine
				timerEngine.init(image.play, interval.value, "#progressWrapper", {width: 136, margin: 0}, "Play", image.playCallback);
				image.view();
			});
		},
		/**
		 * initiate
		 */
		init = function() {
			console.log("init START");
			
			console.log("init call -> addEventListener");
			addEventListener();
			
			console.log("init call -> manipulateDom");
			manipulateDom();
	
			console.log("init call -> initModule");
			initModule();
			
			console.log("init END");
		};
	
	return {
		init: init
	};
	
}());

