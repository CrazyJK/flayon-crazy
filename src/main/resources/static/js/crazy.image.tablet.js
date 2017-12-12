/**
 *image/tablet module
 */

var tablet = (function() {

	var SLIDE_SOURCE_MODE   = "slide.source.mode",
		SLIDE_EFFECT_MODE   = "slide.effect.mode",
		SLIDE_ROTATE_DEG    = "slide.rotate.deg",
		SLIDE_PLAY_MODE     = "slide.play.mode",
		SLIDE_PLAY_INTERVAL = "slide.play.interval",
		IMAGE_DIV = "#imageDiv",
		selectedItemUrl   = "",
		selectedItemTitle = "",
		imageIndex    = 0,
		imageCount    = 0, 
		imageNameMap  = [], 
		imageIndexMap = [],
		coverIndex    = 0, 
		coverCount    = 0, 
		coverNameMap  = [], 
		coverIndexMap = [],
		showEffect, showDuration, showOptions;

	/**
	 * main
	 */
	var	image = {
		saveConfig: function() {
			setLocalStorageItem(SLIDE_SOURCE_MODE, sourceMode.value);
			setLocalStorageItem(SLIDE_EFFECT_MODE, effectMode.value);
			setLocalStorageItem(SLIDE_ROTATE_DEG, rotateDeg.value);
			setLocalStorageItem(SLIDE_PLAY_MODE,     playMode.value);
			setLocalStorageItem(SLIDE_PLAY_INTERVAL, interval.value);
			timerEngine.setTime(interval.value);
			image.displayConfigInfo();
		},
		setEffect: function setEffect() {
			var effects = ["blind", "bounce", "clip", "drop", "explode", "fade", "fold", "highlight", "puff", "pulsate", "scale", "shake", "size", "slide"];
			
			if (effectMode.value == 0) {
				showEffect   = "fade";
				showDuration = 500;
				showOptions  = {};
			}
			else {
				showEffect   = effects[getRandomInteger(0, effects.length-1)];
				showDuration = getRandomInteger(100, 2000);
				if (showEffect === "scale")
					showOptions = { percent: getRandomInteger(10, 50) };
				else if (showEffect === "size")
					showOptions = { to: { width: getRandomInteger(50, 200), height: getRandomInteger(50, 200) } };
				else
					showOptions = {};
			}
			$(".effectInfo").html(showEffect);
			//console.log("    setEffect", showEffect, showDuration, showOptions);
		},
		prev: function() {
			// 다 지웠으면 끝
			if ($(IMAGE_DIV).children().length < 1)
				return;

			image.setEffect();

			// 마지막 이미지 삭제 및 map배열 복원
			var $last = $(IMAGE_DIV).children().last();
			var data = $last.data("data");
			var mode = data.mode;
			var arrIdx = data.arrayIndex;
			var index = data.imageIndex;
			if (mode == 0) {
				imageIndexMap.splice(arrIdx, 0, index);
				//console.log("    prev image", arrIdx, index);
			}
			else {
				coverIndexMap.splice(arrIdx, 0, index);
				//console.log("    prev cover", arrIdx, index);
			}
			$last.remove();

			// 새로운 마지막 이미지 설정
			var $imageDivChildren = $(IMAGE_DIV).children();
			if ($imageDivChildren.length > 0) {
				var data = $imageDivChildren.last().addClass("img-card-focus").randomBG(0.5).data("data");
				$(".title").html(data.title).data("data", data);
				$(".displayCount").html($(IMAGE_DIV).children().length + " / " + (mode == 0 ? imageIndexMap.length : coverIndexMap.length));
			}
			else {
				$(".title").html("&nbsp;").data("data", {});
				$(".displayCount").html("&nbsp;");
			}
		},
		next: function() {
			var currentIndex = -1;
			if (sourceMode.value == 0) { // image
				if (playMode.value == 0) { // sequencial
					if (imageIndex >= imageIndexMap.length)
						imageIndex = 0;
				}
				else { // random
					imageIndex = getRandomInteger(0, imageIndexMap.length -1);
				}
				if (imageIndexMap.length == 0) {
					showSnackbar("image all shown");
					return;
				}
				currentIndex = imageIndexMap.splice(imageIndex, 1)[0];
				//console.log("    next imageIndex", imageIndex, "currentIndex", currentIndex);
				selectedItemUrl = PATH + "/image/" + currentIndex;
				selectedItemTitle = imageNameMap[currentIndex];
				setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, currentIndex);
			}
			else { // cover
				if (playMode.value == 0) { // sequencial
					if (coverIndex >= coverIndexMap.length)
						coverIndex = 0;
				}
				else { // random
					coverIndex = getRandomInteger(0, coverIndexMap.length -1);
				}
				if (coverIndexMap.length == 0) {
					showSnackbar("cover all shown");
					return;
				}
				currentIndex = coverIndexMap.splice(coverIndex, 1)[0];
				//console.log("    next coverIndex", coverIndex, "currentIndex", currentIndex);
				selectedItemUrl = PATH + "/video/" + coverNameMap[currentIndex] + "/cover";
				selectedItemTitle = coverNameMap[currentIndex];
				setLocalStorageItem(THUMBNAMILS_COVER_INDEX, currentIndex);
			}
			
			image.setEffect();
			
			// FIFO 오래된 이미지 지우기. 성능 때문에
			var IMAGE_DISPLAY_LIMIT = 30;
			var currentImageCount = $(IMAGE_DIV).children().length;
			var diffCount = currentImageCount - IMAGE_DISPLAY_LIMIT + 1;
			if (diffCount > 0) {
				for (var i=0; i < diffCount; i++) {
					$(IMAGE_DIV).children().first().remove();
				}
			}
			
			// 기존 이미지의 테두리 초기화
			$(IMAGE_DIV).children().removeClass("img-card-focus").css({backgroundColor: "#fff"});
			
			var preloader = new Image();
			preloader.onload = function() {
				var $image = $("<img>", {
					src: preloader.src,
					"class": "img-thumbnail img-card img-card-focus" 
				}).css(
					image.refactorImageInfo($(IMAGE_DIV).width(), $(IMAGE_DIV).height(), preloader.width, preloader.height, 0, $(IMAGE_DIV).offset().top)	
				).css({
					visibility: "visible"
				}).data("data", {
					"src": preloader.src,
					"mode": parseInt(sourceMode.value),
					"title": selectedItemTitle,
					"imageIndex": currentIndex,
					"arrayIndex": (sourceMode.value == 0 ? imageIndex : coverIndex),
					"width": preloader.width,
					"height": preloader.height
				}).on("mousedown", function() {
					var data = $(this).data("data");
					$(".title").html(data.title).data("data", data);
					$(IMAGE_DIV).children().removeClass("img-card-focus").css({backgroundColor: "#fff"});
					$(this).randomBG(0.5).addClass("img-card-focus").appendTo($(IMAGE_DIV)).css({transform: "rotateZ(0deg)"});
				}).appendTo(
						$(IMAGE_DIV)
				).draggable().randomBG(0.5).hide().show(showEffect, showOptions, showDuration, function() {
					if (rotateDeg.value > 0) {
						$(this).css({
							transition: "transform " + getRandomInteger(1, 3) + "s cubic-bezier(0.6, -0.28, 0.74, 0.05) .3s",
							transform: "rotateZ(" + getRandomInteger(-rotateDeg.value, rotateDeg.value) + "deg)"
						});
					}
				});

				$(".title").html(selectedItemTitle).data("data", $image.data("data"));
				$(".displayCount").html($(IMAGE_DIV).children().length + " / " + (sourceMode.value == 0 ? imageIndexMap.length : coverIndexMap.length));
				
				//console.log("    next", selectedItemUrl, selectedItemTitle);
			};
			preloader.src = selectedItemUrl;
		},
		clear: function() {
			$(IMAGE_DIV).empty();
			$(".displayCount").html("&nbsp;");
			$(".title").html("&nbsp;").data("data", {});
		},
		refactorImageInfo: function(divWidth, divHeight, originalWidth, originalHeight, offsetLeft, offsetTop) {
			var imgWidth  = originalWidth;
			var imgHeight = originalHeight;
			var imgLeft   = offsetLeft;
			var imgTop    = offsetTop;
			if (divHeight < imgHeight) { // 이미지가 더 크면
				imgHeight = divHeight;
				imgWidth = Math.floor(imgHeight * originalWidth / originalHeight);
			}
			if (divWidth < imgWidth) {
				imgWidth = divWidth;
				imgHeight = Math.floor(imgWidth * originalHeight / originalWidth);
			}
			if (divHeight > imgHeight) { // 이미지가 작으면
				imgTop += getRandomInteger(0, divHeight - imgHeight);
			}
			if (divWidth > imgWidth) { // 이미지가 작으면
				imgLeft += getRandomInteger(0, divWidth - imgWidth);
			}
			//console.log("refactorImageInfo", imgWidth, imgHeight, imgLeft, imgTop);
			return {
				width: imgWidth,
				height: imgHeight,
				left: imgLeft,
				top: imgTop
			};
		},
		shuffleImage: function() {
			$(IMAGE_DIV).children().each(function() {
				$(this).animate(
					image.refactorImageInfo($(IMAGE_DIV).width(), $(IMAGE_DIV).height(), $(this).data("data").width, $(this).data("data").height, 0, $(IMAGE_DIV).offset().top)		
				);
			});
		},
		remove: function(willDelete) {
			console.log("delete", willDelete);
			var data = $(".title").data("data");
			if (confirm('remove this image?\n' + data.src + "\n" + data.title)) {
				if (data && data.mode == 0) { // image
					if (willDelete)
						restCall(data.src, {method: "DELETE", title: "this image delete"});
				}
				$("img[src='" + data.src + "']").remove();
				$(".displayCount").html($(IMAGE_DIV).children().length + " / " + (data.mode == 0 ? imageIndexMap.length : coverIndexMap.length));
				$(".title").html("&nbsp;");
			}
		},
		popup: function(e) {
			var data = $(e.target).data("data");
			//console.log("    popup", data);
			if (data.mode == 0) { // image
				popupImage(data.src);
			}
			else {
				fnVideoDetail(data.title);
			}
		},
		playCallback: function(status) {
			$(".container-fluid").toggleClass("label-black", status);
			$(".progress-bar, .label, code", ".container-fluid").toggleClass("label-black", status);
			$(".modal-content", "#configModal").toggleClass("label-black", status);
			image.resize();
		},
		resize: function() {
			$(IMAGE_DIV).height($(window).height() - 30);
		},
		toggleSourceMode: function() {
			$("#sourceMode").val(sourceMode.value == 0 ? 1 : 0).trigger("click");
		},
		toggleEffect: function() {
			$("#effectMode").val(effectMode.value == 0 ? 1 : 0).trigger("click");
		},
		toggleRotateDeg: function(deg) {
			$("#rotateDeg").val(deg).trigger("click");
		},
		togglePlayMode: function() {
			$("#playMode").val(playMode.value == 0 ? 1 : 0).trigger("click");
		},
		toggleInterval: function(sec) {
			$("#interval").val(sec).trigger("click");
		},
		nav: function(signal) {
			switch(signal) {
				case 1 : // mousewheel : up
				case 37: // key : left
				case 38: // key : up
					image.prev();
					break;
				case -1 : // mousewheel : down
				case 39: // key : right
				case 40: // key : down
					image.next();
					break;
				case 32: // key : space
					timerEngine.toggle(image.playCallback);
					break;
				case 46 : // key Delete
					image.clear();
					break;
				case 34 : // key PageDown
					image.shuffleImage();
					break;
				case 45 : // key : Insert
					image.toggleSourceMode();
					break;
				case 36 : // key : home
					image.toggleEffect();
					break;
				case 33 : // key : PageUp
					image.togglePlayMode();
					break;
				case 97 : // key : keypad 1
					image.toggleInterval(1);
					break;
				case 98 : // key : keypad 2 
					image.toggleInterval(2);
					break;
				case 99 : // key : keypad 3
					image.toggleInterval(3);
					break;
				case 100 : // key : keypad 4 
					image.toggleInterval(4);
					break;
				case 101 : // key : keypad 5 
					image.toggleInterval(5);
					break;
				case 102 : // key : keypad 6 
					image.toggleInterval(6);
					break;
				case 103 : // key : keypad 7 
					image.toggleInterval(7);
					break;
				case 104 : // key : keypad 8 
					image.toggleInterval(8);
					break;
				case 105 : // key : keypad 9 
					image.toggleInterval(9);
					break;
				case 13: // key : enter
					break;
				case 1001 : // click : left
					break;
				case 1002 : // click : middle
					image.shuffleImage();
					break;
				case 1003 : // click : right
					break;
				case 83 : // key : 's'
					break;
			}
		},
		displayConfigInfo: function() {
			$(".configInfo > code.sourceInfo"   ).html(sourceMode.value == 0 ? "Image"    : "Cover");
			$(".configInfo > code.effectInfo"   ).html(effectMode.value == 0 ? "Fade"     : "Radndom");
			$(".configInfo > code.rotateDegInfo").html(rotateDeg.value + '˚');
			$(".configInfo > code.playInfo"     ).html(playMode.value == 0   ? "Sequence" : "Random");
			$(".configInfo > code.intervalInfo" ).html(interval.value + 's');
		}
	};
	
	/**
	 * add event listener
	 */
	var addEventListener = function() {

		$(window).on("resize", image.resize);

		// for #navDiv
		$(".delete-image").on("click", image.remove);
		$(".popup-image" ).on("click", image.popup);
		
		// for #imageDiv
		$(IMAGE_DIV).navEvent(image.nav);
		
		// for #configModal
		$("#configModal").on("hidden.bs.modal", function() {
			$(".delete-image").toggle(sourceMode.value == 0);
		});
		$("[data-role='switch']").on('click', function() {
			var target = $(this).attr("data-target");
			var value  = $(this).attr("data-value");
			var text   = $(this).text();
			$("#" + target).val(value);
			$("." + target).html(text);
			$("[data-target='" + target + "']").removeClass("active-switch");
			$(this).addClass("active-switch");
			image.saveConfig();
		});
		$("input[type='range'][role='switch']").on('click keyup', function(e) {
			var value = $(this).val();
			var target = $(this).attr("id");
			$("[data-target='" + target + "'][data-value='" + value + "']").click();
			stopEvent(e);
		});
		$("#rotateDeg").on('click keyup', function(e) {
			var value = $(this).val();
			$(".rotateDeg").html(value);
			image.saveConfig();
			stopEvent(e);
		});
		$("#interval").on('click keyup', function(e) {
			var value = $(this).val();
			$(".interval").html(value);
			image.saveConfig();
			stopEvent(e);
		});
		$(".btn-shuffle").on("click", function() {
			var shuffleOnce = function shuffleOnce() {
				$("[data-target='sourceMode'][data-value='" + getRandomInteger(0, 1) + "']").trigger("click");
				$("[data-target='effectMode'][data-value='" + getRandomInteger(0, 1) + "']").trigger("click");
				$("#rotateDeg").val(getRandomInteger(0, 360)).trigger("click");
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
				}
			}, 500);
		});
		$(".configInfo > code.sourceInfo").on("click", image.toggleSourceMode);
		$(".configInfo > code.effectInfo").on("click", image.toggleEffect);
		$(".configInfo > code.playInfo"  ).on("click", image.togglePlayMode);
	};
	
	/**
	 * manipulate dom element
	 */
	var manipulateDom = function() {
		var slideSourceMode   = getLocalStorageItem(SLIDE_SOURCE_MODE,   getRandomInteger(0, 1));
		var slideEffectMode   = getLocalStorageItem(SLIDE_EFFECT_MODE,   getRandomInteger(0, 1));
		var slideRotateDeg    = getLocalStorageItem(SLIDE_ROTATE_DEG,    getRandomInteger(0, 360));
		var slidePlayMode     = getLocalStorageItem(SLIDE_PLAY_MODE,     getRandomInteger(0, 1));
		var slidePlayInterval = getLocalStorageItem(SLIDE_PLAY_INTERVAL, getRandomInteger(5, 20));

		$("[data-role='switch'][data-target='sourceMode'][data-value='" + slideSourceMode + "']").trigger("click");
		$("[data-role='switch'][data-target='effectMode'][data-value='" + slideEffectMode + "']").trigger("click");
		$("#rotateDeg").val(slideRotateDeg).trigger("click");
		$("[data-role='switch'][data-target=  'playMode'][data-value='" + slidePlayMode   + "']").trigger("click");
		$("#interval").val(slidePlayInterval).trigger("click");

		image.resize();
	};

	/**
	 * initiate moudle
	 */
	var start = function() {
		restCall(PATH + '/rest/image/data', {}, function(data) {
			imageCount   = data['imageCount'];
			imageNameMap = data['imageNameMap'];
			coverCount   = data['coverCount'];
			coverNameMap = data['coverNameMap'];

			for (var i=0; i < imageCount; i++) {
				imageIndexMap.push(i);
			}
			for (var i=0; i < coverCount; i++) {
				coverIndexMap.push(i);
			}
			
			if (sourceMode.value == 0) { // image
				imageIndex = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, 0));
				if (imageIndex < 0 || imageIndex >= imageCount)
					imageIndex = getRandomInteger(0, imageCount-1);
			}
			else { // cover
				coverIndex = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, 0));
				if (coverIndex < 0 || coverIndex >= coverCount)
					coverIndex = getRandomInteger(0, coverCount-1);
			}
			//console.log("initModule", "getJSON", imageIndex, '/', imageCount, coverIndex, '/', coverCount);

			// play engine
			timerEngine.init(image.next, interval.value, "#progressWrapper", {width: 136, margin: 0}, "Play", image.playCallback);
			image.next();
		});
	};

	return {
		init: function() {
			addEventListener();
			manipulateDom();
			start();
		}
	};
}());

