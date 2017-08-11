/**
 *image/slide module
 */

var slide = (function() {

	var SLIDE_SOURCE_MODE   = "slide.source.mode";
	var SLIDE_EFFECT_MODE   = "slide.effect.mode";
	var SLIDE_PLAY_MODE     = "slide.play.mode";
	var SLIDE_PLAY_INTERVAL = "slide.play.interval";

	var selectedNumber    = -1;
	var selectedItemUrl   = "";
	var selectedItemTitle = "";
	var imageCount = 0;
	var imageMap   = [];
	var coverCount = 0;
	var coverMap   = [];
	var windowWidth  = $(window).width();
	var windowHeight = $(window).height();
	var playInterval = 10;
	var hideEffect, hideDuration, hideOptions;
	var showEffect, showDuration, showOptions;

	var image = {
			setConfig: function() {
				setLocalStorageItem(SLIDE_SOURCE_MODE,   sourceMode.value);
				setLocalStorageItem(SLIDE_EFFECT_MODE, effectMethod.value);
				setLocalStorageItem(SLIDE_PLAY_MODE,       playMode.value);
				setLocalStorageItem(SLIDE_PLAY_INTERVAL,   interval.value);
				console.log("    setConfig", sourceMode.value, effectMethod.value, playMode.value, interval.value);
			},
			nextEffect: function setNextEffect() {
				console.log("    nextEffect START");
				var effects = ["blind", "bounce", "clip", "drop", "explode", "fade", "fold", "highlight", "puff", "pulsate", "scale", "shake", "size", "slide"];
				if (effectMethod.value == 1) {
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
				return selectedNumber == 0 ? image.maxCount(-1) : selectedNumber - 1;
			},
			nextNumber: function getNextNumber() {
				return selectedNumber == image.maxCount(-1) ? 0 : selectedNumber + 1;
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
				if (!current) { // first call
					if (sourceMode.value == 0) { // image
						selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, 0));
						if (selectedNumber >= imageCount)
							selectedNumber = getRandomInteger(0, imageCount-1);
					}
					else { // cover
						selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, 0));
						if (selectedNumber >= coverCount)
							selectedNumber = getRandomInteger(0, coverCount-1);
					}
				}
				else {
					selectedNumber = parseInt(current);
				}
				
				if (sourceMode.value == 0) { // image
					selectedItemUrl = PATH + "/image/" + selectedNumber;
					selectedItemTitle = imageMap[selectedNumber];
					setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, selectedNumber);
				}
				else {
					selectedItemUrl = PATH + "/video/" + coverMap[selectedNumber] + "/cover";
					selectedItemTitle = coverMap[selectedNumber];
					setLocalStorageItem(THUMBNAMILS_COVER_INDEX, selectedNumber);
				}
				$("#endNo").html(image.maxCount(-1));
				$("#imageDiv").hide(hideEffect, hideOptions, hideDuration, function() {
					$("#leftNo").html(image.prevNumber());
					$("#currNo").val(selectedNumber);
					$("#rightNo").html(image.nextNumber());
					$(".title").html(selectedItemTitle);
					console.log("    view call -> image.nextEffect");
					$(this).css({
						backgroundImage: "url('" + selectedItemUrl + "')"
					}).show(showEffect, showOptions, showDuration, image.nextEffect);

					console.log("    view call -> image.displayThumbnail");
					image.displayThumbnail();
				});
				console.log("    view END", selectedNumber, selectedItemUrl, selectedItemTitle);
			},
			delete: function() {
				console.log("    delete");
				if (sourceMode.value == 0) { // image
					var imgSrc = selectedItemUrl;
					if (confirm('Delete this image\n' + imgSrc)) {
						actionFrame(imgSrc, {}, "DELETE", "this image delete");
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
					fnVideoDetail(coverMap[selectedNumber]);
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
					$("body").css("background", "#000");
					$("#thumbnailDiv").css('height', '5px').hide();
					$(".progress").css("background", "linear-gradient(to bottom,#403a3a 0,#2f2626 100%)");
					$(".progress-bar").css("background", "#000");
					$(".label-info").css("background", "#000");
					$(".paging").hide();
					$("#navDiv").css("opacity", ".5");
					$("#title-area").addClass("top-center");
				}
				else {
					$("body").css("background", "#fff");
					$("#thumbnailDiv").css('height', '105px').show('fade', {}, 1000);
					$(".progress").css("background", "linear-gradient(to bottom,#ebebeb 0,#f5f5f5 100%)");
					$(".progress-bar").css("background", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
					$(".label-info").css("background", "linear-gradient(rgb(91, 192, 222) 0px, rgb(49, 176, 213) 100%)");
					$(".paging").show();
					$("#navDiv").css("opacity", "1");
					$("#title-area").removeClass("top-center");
				}
				console.log("    playCallback call -> image.resize");
				image.resize();
				console.log("    playCallback END");
			},
			resize: function() {
				console.log("    resize START");
				console.log("    resize call -> image.displayThumbnail");
				image.displayThumbnail();
				windowHeight = $(window).height();
				$("#imageDiv").height(windowHeight - $("#thumbnailDiv").outerHeight() - 35);
				console.log("    resize END");
			},
			displayThumbnail: function fnDisplayThumbnail() {
				console.log("    displayThumbnail START", selectedNumber);
				windowWidth = $(window).width();
				$("#thumbnailUL").empty();
				var itemCount = image.maxCount();
				var thumbnailRange = parseInt(windowWidth / (150 * 2));
				for (var current = selectedNumber - thumbnailRange; current <= selectedNumber + thumbnailRange; current++) {
					var thumbNo = current;
					if (thumbNo < 0 )
						thumbNo = itemCount + thumbNo;
					if (thumbNo >= itemCount)
						thumbNo = thumbNo - itemCount;
					var itemUrl = sourceMode.value == 0 ? PATH + "/image/" + thumbNo : PATH + "/video/" + coverMap[thumbNo] + "/cover";
					//console.log("      displayThumbnail", itemUrl, thumbNo);
					$("<li>").append(
							$("<div>")
								.addClass("img-thumbnail " + (thumbNo == selectedNumber ? "active" : ""))
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
			}
	};
	
	var manipulateDom = function() {
		console.log("  manipulateDom START");
		var slideSourceMode   = getLocalStorageItem(SLIDE_SOURCE_MODE,   getRandomInteger(0, 1));
		var slideEffectMode   = getLocalStorageItem(SLIDE_EFFECT_MODE,   getRandomInteger(0, 1));
		var slidePlayMode     = getLocalStorageItem(SLIDE_PLAY_MODE,     getRandomInteger(0, 1));
		var slidePlayInterval = getLocalStorageItem(SLIDE_PLAY_INTERVAL, getRandomInteger(5, 20));

		$("[data-role='switch'][data-target='sourceMode'][data-value='" + slideSourceMode + "']").trigger("click");
		$("[data-role='switch'][data-target='effectMethod'][data-value='" + slideEffectMode + "']").trigger("click");
		$("[data-role='switch'][data-target='playMode'][data-value='" + slidePlayMode + "']").trigger("click");
		$("#interval").val(slidePlayInterval).trigger("click");

		console.log("  manipulateDom call -> image.resize");
		image.resize();
		console.log("  manipulateDom call -> image.nextEffect");
		image.nextEffect();

		console.log("  manipulateDom END", slideSourceMode, slideEffectMode, slidePlayMode, slidePlayInterval);
	};
	
	var addEventListener = function() {

		$(window).on("keyup", function(e) {
			var event = window.event || e;
			console.log("window keyup event", event.keyCode);
			switch (event.keyCode) {
			case 37: // left
			case 40: // down
				image.prev(); break;
			case 39: // right
			case 38: // up
				image.next(); break;
			case 32: // space
				image.random();
			case 13: // enter
				break;
			}
		}).on("resize", image.resize);

		// for #navDiv
		$(".paging-first").on("click", image.first);
		$(".delete-image").on("click", image.delete);
		$(".popup-image" ).on("click", image.popup);
		$(".paging-end"  ).on("click", image.end);
		$("#currNo"      ).on("keyup", function(e) {
			var event = window.event || e;
			event.stopPropagation();
			console.log("#currNo keyup event", event.keyCode);
			if (event.keyCode === 13) {
				image.view($(this).val());
			}
		});
		
		// for #imageDiv
		$("#imageDiv").on("click", function(event) {
			console.log("#imageDiv click", event.which);
			switch (event.which) {
			case 1: // left click
				image.next();
				break;
			case 2: // middle click
				image.random();
				break;
			case 3: // right click
				break;
			}
			event.stopImmediatePropagation();
			event.preventDefault();
			event.stopPropagation();
		}).on("mousewheel DOMMouseScroll", function(e) {
			var delta = mousewheel(e);
			console.log("#imageDiv mousewheel", delta);
			if (delta > 0) 
				image.prev(); //alert("마우스 휠 위로~");
		    else 	
		    	image.next(); //alert("마우스 휠 아래로~");
		});

		// for #configModal
		$("#configModal").on("hidden.bs.modal", function() {
			if (sourceMode.value == 0) {
				selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, getRandomInteger(0, imageCount-1)));
				$(".delete-image").show();
			}
			else {
				selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, getRandomInteger(0, coverCount-1)));
				$(".delete-image").hide();
			}
			console.log("#configModal hidden.bs.modal", sourceMode.value, selectedNumber);
			timerEngine.setTime(playInterval);
			image.view(selectedNumber);
		});
		$("[data-role='switch']").on('click', function() {
			var target = $(this).attr("data-target");
			var value  = $(this).attr("data-value");
			var text   = $(this).text();
			$("#" + target).val(value);
			$("." + target).html(text);
			$("[data-target='" + target + "']").removeClass("active-switch");
			$(this).addClass("active-switch");
			image.setConfig();
		});
		$("input[type='range'][role='switch']").on('click', function() {
			var value = $(this).val();
			var target = $(this).attr("id");
			$("[data-target='" + target + "'][data-value='" + value + "']").click();
		});
		$("#interval").on('click', function() {
			var value = $(this).val();
			$(".interval").html(value);
			$("#timerBar").attr({"aria-valuemax": value});
			playInterval = value;
			image.setConfig();
		});
		$(".btn-shuffle").on("click", function() {
			var shuffleOnce = function shuffleOnce() {
				$("[data-target='sourceMode'][data-value='" + getRandomInteger(0, 1) + "']").trigger("click");
				$("[data-target='effectMethod'][data-value='" + getRandomInteger(0, 1) + "']").trigger("click");
				$("[data-target='playMode'][data-value='" + getRandomInteger(0, 1) + "']").trigger("click");
				$("#interval").val(getRandomInteger(5, 20)).trigger("click");
			};
			showSnackbar("shuffle start", 1000);
			var count = 0, maxShuffle = getRandomInteger(3, 9);
			var shuffler = setInterval(function() {
				shuffleOnce();
				if (++count > maxShuffle) {
				 	clearInterval(shuffler);
				 	showSnackbar("shuffle completed. try " + maxShuffle, 1000);
				 	image.setConfig();
				}
			}, 500);
		});
	};
	
	var initModule = function() {
		$.getJSON(PATH + "/image/data.json" ,function(data) {
			imageCount = data['imageCount'];
			imageMap   = data['imageNameMap'];
			coverCount = data['coverCount'];
			coverMap   = data['coverNameMap'];
			
			console.log("initModule", "getJSON", imageCount, coverCount, selectedNumber);

			// play engine
			timerEngine.init(image.play, playInterval, "#progressWrapper", {}, "Play", image.playCallback);
			image.view();
		});
	};
	
	var init = function() {
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

