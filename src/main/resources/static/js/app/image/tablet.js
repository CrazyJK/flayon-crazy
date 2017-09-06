/**
 *image/tablet module
 */

var slide = (function() {

	var SLIDE_SOURCE_MODE   = "slide.source.mode";
	var SLIDE_EFFECT_MODE   = "slide.effect.mode";
	var SLIDE_PLAY_MODE     = "slide.play.mode";
	var SLIDE_PLAY_INTERVAL = "slide.play.interval";

	var selectedItemUrl   = "";
	var selectedItemTitle = "";
	var imageIndex        = 0;
	var imageCount        = 0;
	var imageNameMap      = [];
	var imageIndexMap     = [];
	var coverIndex        = 0;
	var coverCount        = 0;
	var coverNameMap      = [];
	var coverIndexMap     = [];
	var showEffect, showDuration, showOptions;

	var image = {
			saveConfig: function() {
				setLocalStorageItem(SLIDE_SOURCE_MODE, sourceMode.value);
				setLocalStorageItem(SLIDE_EFFECT_MODE, effectMode.value);
				setLocalStorageItem(SLIDE_PLAY_MODE,     playMode.value);
				setLocalStorageItem(SLIDE_PLAY_INTERVAL, interval.value);
				timerEngine.setTime(interval.value);
				image.displayConfigInfo();
				console.log("    setLocalStorage", sourceMode.value, effectMode.value, playMode.value, interval.value);
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
				console.log("    setEffect", showEffect, showDuration, showOptions);
			},
			prev: function() {
				console.log("    prev");
				// 다 지웠으면 끝
				if ($("#imageDiv").children().length < 1)
					return;

				image.setEffect();

				// 마지막 이미지 삭제 및 map배열 복원
				var $last = $("#imageDiv").children().last();
				var data = $last.data("data");
				var mode = data.mode;
				var arrIdx = data.arrayIndex;
				var index = data.imageIndex;
				if (mode == 0) {
					imageIndexMap.splice(arrIdx, 0, index);
					console.log("    prev image", arrIdx, index);
				}
				else {
					coverIndexMap.splice(arrIdx, 0, index);
					console.log("    prev cover", arrIdx, index);
				}
				$last.remove();

				// 새로운 마지막 이미지 설정
				var $imageDivChildren = $("#imageDiv").children();
				if ($imageDivChildren.length > 0) {
					var data = $imageDivChildren.last().addClass("img-card-focus").randomBG(0.5).data("data");
					$(".title").html(data.title).data("data", data);
					$(".displayCount").html($("#imageDiv").children().length + " / " + (mode == 0 ? imageIndexMap.length : coverIndexMap.length));
				}
				else {
					$(".title").html("&nbsp;").data("data", {});
					$(".displayCount").html("&nbsp;");
				}
			},
			next: function() {
				console.log("    next");
				var currentIndex      = -1;
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
					console.log("    next imageIndex", imageIndex, "currentIndex", currentIndex);
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
					console.log("    next coverIndex", coverIndex, "currentIndex", currentIndex);
					selectedItemUrl = PATH + "/video/" + coverNameMap[currentIndex] + "/cover";
					selectedItemTitle = coverNameMap[currentIndex];
					setLocalStorageItem(THUMBNAMILS_COVER_INDEX, currentIndex);
				}
				
				image.setEffect();
				
				// FIFO 오래된 이미지 지우기. 성능 때문에
				var IMAGE_DISPLAY_LIMIT = 30;
				var currentImageCount = $("#imageDiv").children().length;
				var diffCount = currentImageCount - IMAGE_DISPLAY_LIMIT + 1;
				if (diffCount > 0) {
					for (var i=0; i < diffCount; i++) {
						$("#imageDiv").children().first().remove();
					}
				}
				
				// 기존 이미지의 테두리 초기화
				$("#imageDiv").children().removeClass("img-card-focus").css({backgroundColor: "#fff"});
				
				var preloader = new Image();
				preloader.onload = function() {
					var $image = $("<img>", {
						src: preloader.src,
						"class": "img-thumbnail img-card img-card-focus" 
					}).css(
						image.refactorImageInfo($("#imageDiv").width(), $("#imageDiv").height(), preloader.width, preloader.height, 0, $("#imageDiv").offset().top)	
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
						$("#imageDiv").children().removeClass("img-card-focus").css({backgroundColor: "#fff"});
						$(this).addClass("img-card-focus").randomBG(0.5).appendTo($("#imageDiv"));
					}).appendTo(
							$("#imageDiv")
					).draggable().randomBG(0.5).hide().show(showEffect, showOptions, showDuration);

					$(".title").html(selectedItemTitle).data("data", $image.data("data"));
					$(".displayCount").html($("#imageDiv").children().length + " / " + (sourceMode.value == 0 ? imageIndexMap.length : coverIndexMap.length));
					
					console.log("    next", selectedItemUrl, selectedItemTitle);
				};
				preloader.src = selectedItemUrl;
			},
			clear: function() {
				$("#imageDiv").empty();
				$(".displayCount").html("&nbsp;");
				$(".title").html("&nbsp;").data("data", {});
				console.log("    clear");
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
				return {
					width: imgWidth,
					height: imgHeight,
					left: imgLeft,
					top: imgTop
				};
			},
			shuffleImage: function() {
				$("#imageDiv").children().each(function() {
					$(this).animate(
						image.refactorImageInfo($("#imageDiv").width(), $("#imageDiv").height(), $(this).data("data").width, $(this).data("data").height, 0, $("#imageDiv").offset().top)		
					);
				});
				console.log("    shuffleImage");
			},
			remove: function(willDelete) {
				console.log("delete", willDelete);
				var data = $(".title").data("data");
				if (confirm('remove this image?\n' + data.src + "\n" + data.title)) {
					if (data && data.mode == 0) { // image
						if (willDelete)
							actionFrame(data.src, {}, "DELETE", "this image delete");
					}
					$("img[src='" + data.src + "']").remove();
					$(".displayCount").html($("#imageDiv").children().length + " / " + (data.mode == 0 ? imageIndexMap.length : coverIndexMap.length));
					$(".title").html("&nbsp;");
				}
			},
			popup: function(e) {
				var data = $(e.target).data("data");
				console.log("    popup", data);
				if (data.mode == 0) { // image
					popupImage(data.src);
				}
				else {
					fnVideoDetail(data.title);
				}
			},
			playCallback: function(status) {
				console.log("    playCallback", status);
				$("body, .progress-bar, .label, code").toggleClass("label-black", status);
				image.resize();
			},
			resize: function() {
				console.log("    resize");
				$("#imageDiv").height($(window).height() - 30);
			},
			toggleSourceMode: function() {
				$("#sourceMode").val(sourceMode.value == 0 ? 1 : 0).trigger("click");
			},
			toggleEffect: function() {
				$("#effectMode").val(effectMode.value == 0 ? 1 : 0).trigger("click");
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
					case 40: // key : down
						image.prev();
						break;
					case -1 : // mousewheel : down
					case 39: // key : right
					case 38: // key : up
						image.next();
						break;
					case 32: // key : space
						timerEngine.toggle(image.playCallback);
						break;
					case 46 : // key delete
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
				$(".configInfo > code.sourceInfo"  ).html(sourceMode.value == 0 ? "Image"    : "Cover");
				$(".configInfo > code.effectInfo"  ).html(effectMode.value == 0 ? "Fade"     : "Radndom");
				$(".configInfo > code.playInfo"    ).html(playMode.value == 0   ? "Sequence" : "Random");
				$(".configInfo > code.intervalInfo").html(interval.value);
			}
	};
	
	var addEventListener = function() {

		$(window).on("resize", image.resize);

		// for #navDiv
		$(".delete-image").on("click", image.remove);
		$(".popup-image" ).on("click", image.popup);
		
		// for #imageDiv
		$("#imageDiv").navEvent(image.nav);
		
		// for #configModal
		$("#configModal").on("hidden.bs.modal", function() {
			console.log("#configModal hidden.bs.modal", sourceMode.value, interval.value);
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
			console.log("input range", e);
			var value = $(this).val();
			var target = $(this).attr("id");
			$("[data-target='" + target + "'][data-value='" + value + "']").click();
			e.stopImmediatePropagation();
			e.preventDefault();
			e.stopPropagation();
		});
		$("#interval").on('click keyup', function(e) {
			var value = $(this).val();
			$(".interval").html(value);
			image.saveConfig();
			e.stopImmediatePropagation();
			e.preventDefault();
			e.stopPropagation();
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
				}
			}, 500);
		});
		$(".configInfo > code.sourceInfo"  ).on("click", image.toggleSourceMode);
		$(".configInfo > code.effectInfo"  ).on("click", image.toggleEffect);
		$(".configInfo > code.playInfo"    ).on("click", image.togglePlayMode);
	};
	
	var manipulateDom = function() {
		console.log("  manipulateDom START");
		var slideSourceMode   = getLocalStorageItem(SLIDE_SOURCE_MODE,   getRandomInteger(0, 1));
		var slideEffectMode   = getLocalStorageItem(SLIDE_EFFECT_MODE,   getRandomInteger(0, 1));
		var slidePlayMode     = getLocalStorageItem(SLIDE_PLAY_MODE,     getRandomInteger(0, 1));
		var slidePlayInterval = getLocalStorageItem(SLIDE_PLAY_INTERVAL, getRandomInteger(5, 20));

		$("[data-role='switch'][data-target='sourceMode'][data-value='" + slideSourceMode + "']").trigger("click");
		$("[data-role='switch'][data-target='effectMode'][data-value='" + slideEffectMode + "']").trigger("click");
		$("[data-role='switch'][data-target=  'playMode'][data-value='" + slidePlayMode   + "']").trigger("click");
		$("#interval").val(slidePlayInterval).trigger("click");

		console.log("  manipulateDom call -> image.resize");
		image.resize();

		console.log("  manipulateDom END", slideSourceMode, slideEffectMode, slidePlayMode, slidePlayInterval);
	};
	
	var initModule = function() {
		$.getJSON(PATH + "/image/data.json" ,function(data) {
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
			console.log("initModule", "getJSON", imageIndex, '/', imageCount, coverIndex, '/', coverCount);

			// play engine
			timerEngine.init(image.next, interval.value, "#progressWrapper", {width: 136, margin: 0}, "Play", image.playCallback);
			image.next();
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

