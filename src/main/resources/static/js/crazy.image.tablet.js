/**
 *image/tablet module
 */
var tablet = (function() {

	var IMAGE_SOURCE         = "image.source",
		IMAGE_SHOW_METHOD    = "image.show.method",
		IMAGE_SHOW_SPECIFIC  = "image.show.specific",
		IMAGE_ROTATE_DEGREE  = "image.rotate.degree",
		IMAGE_NEXT_METHOD    = "image.next.method",
		IMAGE_PLAY_INTERVAL  = "image.play.interval",
		IMAGE_HIDE_METHOD    = "image.hide.method",
		IMAGE_HIDE_SPECIFIC  = "image.hide.specific",
		IMAGE_TABLET_DISPLAY = "image.tablet.display.method",
		IMAGE_DIV = "#imageDiv",
		selectedItemUrl = "", selectedItemTitle = "",
		imageIndex = 0,	imageCount = 0,	imageNameMap = [], imageIndexMap = [],
		coverIndex = 0, coverCount = 0,	coverNameMap = [], coverIndexMap = [],
		showEffect, showDuration, showOptions,
		effects = ["blind", "bounce", "clip", "drop", "explode", "fade", "fold", "puff", "pulsate", "scale", "shake", "size", "slide"],
		TOP_MARGIN = 30;

	var config = {
			display: function() {
				$(".imageSource"  ).html(imageSource.value == 0 ? "Image" : "Cover");
				$(".showMethod"   ).html(showMethod.value == 0 ? "Specific[" + $("#effectShowTypes option:selected").val() + "]" : "Radndom[" + showEffect + "]");
				$(".rotateDegree" ).html(rotateDegree.value + '˚');
				$(".nextMethod"   ).html(nextMethod.value == 0 ? "Sequencial" : "Random");
				$(".playInterval" ).html(playInterval.value + 's');
				$(".hideMethod"   ).html(hideMethod.value == 0 ? "Effect[" + $("#effectHideTypes option:selected").val() + "]" : "Remove");
				$(".displayMethod").html(displayMethod.value == 0 ? "Tablet" : "Tile");
			},
			save: function() {
				setLocalStorageItem(IMAGE_SOURCE,           imageSource.value);
				setLocalStorageItem(IMAGE_SHOW_METHOD,       showMethod.value);
				setLocalStorageItem(IMAGE_HIDE_METHOD,       hideMethod.value);
				setLocalStorageItem(IMAGE_ROTATE_DEGREE,   rotateDegree.value);
				setLocalStorageItem(IMAGE_NEXT_METHOD,       nextMethod.value);
				setLocalStorageItem(IMAGE_PLAY_INTERVAL,   playInterval.value);
				setLocalStorageItem(IMAGE_TABLET_DISPLAY, displayMethod.value);
				setLocalStorageItem(IMAGE_SHOW_SPECIFIC,  $("#effectShowTypes option:selected").val());
				setLocalStorageItem(IMAGE_HIDE_SPECIFIC,  $("#effectHideTypes option:selected").val());
				
				timerEngine.setTime(playInterval.value);
				config.display();
			},
			toggleImageSource: function() {
				$("#imageSource").val(imageSource.value == 0 ? 1 : 0).trigger("click");
			},
			toggleShowEffect: function() {
				$("#showMethod").val(showMethod.value == 0 ? 1 : 0).trigger("click");
			},
			setRotateDegree: function(deg) {
				var val;
				if (typeof deg === 'number')
					val = deg;
				else if (deg === '-')
					val = parseInt($("#rotateDegree").val()) - 1;
				else if (deg === '+')
					val = parseInt($("#rotateDegree").val()) + 1;
				else 
					val = 0;
				$("#rotateDegree").val(val).trigger("click");
			},
			toggleNextMethod: function() {
				$("#nextMethod").val(nextMethod.value == 0 ? 1 : 0).trigger("click");
			},
			togglePlayInterval: function(sec) {
				var val;
				if (typeof sec === 'number')
					val = sec;
				else if (sec === '-')
					val = parseInt($("#playInterval").val()) - 1;
				else if (sec === '+')
					val = parseInt($("#playInterval").val()) + 1;
				else 
					val = 0;
				$("#playInterval").val(val).trigger("click");
			},
			toggleHideMethod: function() {
				$("#hideMethod").val(hideMethod.value == 0 ? 1 : 0).trigger("click");
			},
			toggleDisplayMethod: function() {
				$("#displayMethod").val(displayMethod.value == 0 ? 1 : 0).trigger("click");
			},
			eventListener: function() {
				$("#configModal").on({
					"hidden.bs.modal": function() {
						$(".delete-image").toggle(imageSource.value == 0);
					},
					"shown.bs.modal": function() {}
				});
				$(".label-switch").on('click', function() { // switch label
					var target = $(this).attr("data-target");
					var value  = $(this).attr("data-value");
					var text   = $(this).text();
					$("#" + target).val(value);
					$("." + target).html(text);
					$("[data-target='" + target + "']").removeClass("active-switch");
					$(this).addClass("active-switch");
					config.save();
				});
				$(".config-switch-range").on('click keyup', function(e) { // range for switch 
					var value = $(this).val();
					var target = $(this).attr("id");
					$("[data-target='" + target + "'][data-value='" + value + "']").click();
					stopEvent(e);
				});
				$(".config-range").on('click keyup', function(e) {
					var value = $(this).val();
					var target = $(this).attr("id");
					$("." + target).html(value);
					config.save();
					stopEvent(e);
				});
				$(".config-select").on("change", function() {
					config.save();
				});
				$(".btn-shuffle").on("click", function() {
					var shuffleOnce = function shuffleOnce() {
						$("#imageSource"  ).val(getRandomInteger(0, 1)).trigger("click");
						$("#showMethod"   ).val(getRandomInteger(0, 1)).trigger("click");
						$("#hideMethod"   ).val(getRandomInteger(0, 1)).trigger("click");
						$("#nextMethod"   ).val(getRandomInteger(0, 1)).trigger("click");
						$("#displayMethod").val(getRandomInteger(0, 1)).trigger("click");
						$("#rotateDegree" ).val(getRandomInteger(0, 360)).trigger("click");
						$("#playInterval" ).val(getRandomInteger(5, 20)).trigger("click");
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
			},
			initiate: function() {
				var imageSource        = getLocalStorageItem(IMAGE_SOURCE,         getRandomInteger(0, 1));
				var showMethod         = getLocalStorageItem(IMAGE_SHOW_METHOD,    getRandomInteger(0, 1));
				var hideMethod         = getLocalStorageItem(IMAGE_HIDE_METHOD,    getRandomInteger(0, 1));
				var rotateDegree       = getLocalStorageItem(IMAGE_ROTATE_DEGREE,  getRandomInteger(0, 360));
				var nextMethod         = getLocalStorageItem(IMAGE_NEXT_METHOD,    getRandomInteger(0, 1));
				var playInterval       = getLocalStorageItem(IMAGE_PLAY_INTERVAL,  getRandomInteger(5, 20));
				var displayMethod      = getLocalStorageItem(IMAGE_TABLET_DISPLAY, getRandomInteger(0, 1));
				var showSpecificEffect = getLocalStorageItem(IMAGE_SHOW_SPECIFIC,  effects[getRandomInteger(0, effects.length-1)]);
				var hideSpecificEffect = getLocalStorageItem(IMAGE_HIDE_SPECIFIC,  effects[getRandomInteger(0, effects.length-1)]);

				$("#imageSource"  ).val(imageSource  ).trigger("click");
				$("#showMethod"   ).val(showMethod   ).trigger("click");
				$("#hideMethod"   ).val(hideMethod   ).trigger("click");
				$("#nextMethod"   ).val(nextMethod   ).trigger("click");
				$("#displayMethod").val(displayMethod).trigger("click");
				$("#playInterval" ).val(playInterval ).trigger("click");
				$("#rotateDegree" ).val(rotateDegree ).trigger("click");
				
				for (var i in effects) {
					$("#effectShowTypes, #effectHideTypes").append(
							$("<option>", {value: effects[i]}).html(capitalize(effects[i]))
					);
				}
				$("#effectShowTypes").val(showSpecificEffect).prop("selected", true).trigger("change");
				$("#effectHideTypes").val(hideSpecificEffect).prop("selected", true).trigger("change");
			},
			nav: function(signal) {
				switch(signal) {
				case 67 : // key : c
					$("#configModal").modal("toggle");
					break;
				case 70 : // key : f
					$(".btn-shuffle").trigger("click");
					break;
				case 45 : // key : Insert
					config.toggleImageSource();
					break;
				case 36 : // key : Home
					config.toggleShowEffect();
					break;
				case 33 : // key : PageUp
					config.toggleNextMethod();
					break;
				case 35 : // key : End
					config.toggleHideMethod();
					break;
				case 34 : // key : PageDown
					config.toggleDisplayMethod();
					break;
				case 48 : // key : 0
					config.setRotateDegree(0);
					break;
				case 189 : // key : -
					config.setRotateDegree('-');
					break;
				case 187 : // key : +
					config.setRotateDegree('+');
					break;
				case 97 : // key : keypad 1
					config.togglePlayInterval(1);
					break;
				case 98 : // key : keypad 2 
					config.togglePlayInterval(2);
					break;
				case 99 : // key : keypad 3
					config.togglePlayInterval(3);
					break;
				case 100 : // key : keypad 4 
					config.togglePlayInterval(4);
					break;
				case 101 : // key : keypad 5 
					config.togglePlayInterval(5);
					break;
				case 102 : // key : keypad 6 
					config.togglePlayInterval(6);
					break;
				case 103 : // key : keypad 7 
					config.togglePlayInterval(7);
					break;
				case 104 : // key : keypad 8 
					config.togglePlayInterval(8);
					break;
				case 105 : // key : keypad 9 
					config.togglePlayInterval(9);
					break;
				case 109 : // key : keypad - 
					config.togglePlayInterval('-');
					break;
				case 107 : // key : keypad + 
					config.togglePlayInterval('+');
					break;
				}
			}
	};
	
	/**
	 * main
	 */
	var	image = {
		setEffect: function setEffect() {
			if (showMethod.value == 0) {
				showEffect   = $("#effectShowTypes option:selected").val();
				showDuration = 500;
			}
			else {
				showEffect   = effects[getRandomInteger(0, effects.length-1)];
				showDuration = getRandomInteger(100, 2000);
			}
			if (showEffect === "scale")
				showOptions = { percent: getRandomInteger(10, 50) };
			else if (showEffect === "size")
				showOptions = { to: { width: getRandomInteger(50, 200), height: getRandomInteger(50, 200) } };
			else
				showOptions = {};
			//console.log("    setEffect", showEffect, showDuration, showOptions);
			config.display();
		},
		prev: function() {
			// 다 지웠으면 끝
			if ($(IMAGE_DIV).children().length < 1)
				return;

			// 마지막 이미지 삭제 및 map배열 복원
			var $lastImage = $(IMAGE_DIV).children().last();
			var lastData = $lastImage.data("data");
			if (lastData.mode == 0) {
				imageIndexMap.splice(lastData.arrayIndex, 0, lastData.imageIndex);
				//console.log("    prev image", arrIdx, index);
			}
			else {
				coverIndexMap.splice(lastData.arrayIndex, 0, lastData.imageIndex);
				//console.log("    prev cover", arrIdx, index);
			}
			
			if (hideMethod.value == 0) {
				var effectHideTypes = $("#effectHideTypes option:selected").val();
				if (effectHideTypes === "own") {
					$lastImage.hide(lastData.effect, lastData.options, lastData.duration, function() {
						$(this).remove();
						image.setLastInfo();
					});
				}
				else {
					$lastImage.hide(effectHideTypes, {}, 500, function() {
						$(this).remove();
						image.setLastInfo();
					});
				}
			}
			else {
				$lastImage.remove();
				image.setLastInfo();
			}
		},
		defocus: function() {
			$(".img-card", IMAGE_DIV).css({backgroundColor: "#fff"}).removeClass("img-card-focus");
		},
		setLastInfo: function() {
			// 새로운 마지막 이미지 설정
			var $imageDivChildren = $(IMAGE_DIV).children();
			if ($imageDivChildren.length > 0) {
				var data = $imageDivChildren.last().addClass("img-card-focus").randomBG(0.5).data("data");
				$(".title").html(data.title).data("data", data);
				$(".displayCount").html($("." + data.imageTypeClass, IMAGE_DIV).length + " in " + (data.mode == 0 ? imageIndexMap.length : coverIndexMap.length));
			}
			else {
				$(".title").html("&nbsp;").data("data", {});
				$(".displayCount").html("&nbsp;");
			}
		},
		next: function() {
			var currentIndex = -1;
			var imageTypeClass = "";
			if (imageSource.value == 0) { // image
				imageTypeClass = "img-image";
				if (nextMethod.value == 0) { // sequencial
					if (imageIndex >= imageIndexMap.length)
						imageIndex = 0;
				}
				else { // random
					imageIndex = getRandomInteger(0, imageIndexMap.length -1);
				}
				if (imageIndexMap.length == 0) {
					showSnackbar("image all shown");
					timerEngine.off();
					return;
				}
				currentIndex = imageIndexMap.splice(imageIndex, 1)[0];
				//console.log("    next imageIndex", imageIndex, "currentIndex", currentIndex);
				selectedItemUrl = PATH + "/image/" + currentIndex;
				selectedItemTitle = imageNameMap[currentIndex];
				setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, currentIndex);
			}
			else { // cover
				imageTypeClass = "img-cover";
				if (nextMethod.value == 0) { // sequencial
					if (coverIndex >= coverIndexMap.length)
						coverIndex = 0;
				}
				else { // random
					coverIndex = getRandomInteger(0, coverIndexMap.length -1);
				}
				if (coverIndexMap.length == 0) {
					showSnackbar("cover all shown");
					timerEngine.off();
					return;
				}
				currentIndex = coverIndexMap.splice(coverIndex, 1)[0];
				//console.log("    next coverIndex", coverIndex, "currentIndex", currentIndex);
				selectedItemUrl = PATH + "/video/" + coverNameMap[currentIndex] + "/cover";
				selectedItemTitle = coverNameMap[currentIndex];
				setLocalStorageItem(THUMBNAMILS_COVER_INDEX, currentIndex);
			}
			
			var preloader = new Image();
			preloader.onload = function() {
				image.removeOld();
				image.defocus(); // 기존 이미지의 테두리 초기화

				console.log("displayMethod.value", displayMethod.value);
				if (displayMethod.value == 1) {
					image.tile();
				}

				var $image = $("<img>", {
					src: preloader.src,
					"class": "img-thumbnail img-card img-card-focus " + imageTypeClass 
				}).randomBG(0.5).css({
					display: "none"
				}).css(
					image.position($(IMAGE_DIV).width(), $(IMAGE_DIV).height(), preloader.width, preloader.height, 0, $(IMAGE_DIV).offset().top, .9)	
				).data("data", {
					src: preloader.src,
					mode: parseInt(imageSource.value),
					title: selectedItemTitle,
					imageIndex: currentIndex,
					arrayIndex: (imageSource.value == 0 ? imageIndex : coverIndex),
					width: preloader.width,
					height: preloader.height,
					imageTypeClass: imageTypeClass,
					effect: showEffect,
					options: showOptions,
					duration: showDuration
				}).on("mousedown", function(e) {
					if (e.which == 1) { // mouse left
						image.defocus();
						if (displayMethod.value == 1 || $(this).data("tile")) {
							displayMethod.value == 1 && image.tile();
							var data = $(this).data("data");
							var position = image.position($(IMAGE_DIV).width(), $(IMAGE_DIV).height(), data.width, data.height, 0, $(IMAGE_DIV).offset().top, .9);
							$(this).animate(position).data("tile", false);
							/* for center
							$(this).animate({
								width: position.width,
								height: position.height,
								left: ($(IMAGE_DIV).width() - position.width) / 2, 
								top: ($(IMAGE_DIV).height() - position.height) / 2 + TOP_MARGIN
							}); */
						}
						$(this).appendTo($(IMAGE_DIV)).addClass("rotate0");
						image.setLastInfo();
					} 
					else if (e.which == 2) { // mouse middle
						image.shake();
					} 
					else if (e.which == 3) { // mouse right
						// do nothing
					} 
				}).appendTo(
						$(IMAGE_DIV)
				);
				image.setLastInfo();

				image.setEffect();
				$image.show(showEffect, showOptions, showDuration, function() {
					$(this).rotateR(rotateDegree.value).draggable();
				});
			};
			preloader.src = selectedItemUrl;
		},
		removeOld: function() {
			// FIFO 오래된 이미지 지우기. 성능 때문에
			var IMAGE_DISPLAY_LIMIT = 30;
			var currentImageCount = $(IMAGE_DIV).children().length;
			var diffCount = currentImageCount - IMAGE_DISPLAY_LIMIT + 1;
			if (diffCount > 0) {
				for (var i=0; i < diffCount; i++) {
					$(IMAGE_DIV).children().first().remove();
				}
			}
		},
		empty: function() {
			$(IMAGE_DIV).empty();
			$(".title").html("&nbsp;").data("data", {});
			$(".displayCount").html("&nbsp;");
		},
		position: function(divWidth, divHeight, originalWidth, originalHeight, offsetLeft, offsetTop, ratio) {
			var imgWidth  = originalWidth;
			var imgHeight = originalHeight;
			var imgLeft   = offsetLeft;
			var imgTop    = offsetTop;
			if (divHeight < imgHeight) { // 이미지 높이가 더 크면
				imgHeight = divHeight * ratio;
				imgWidth = Math.floor(imgHeight * originalWidth / originalHeight);
			}
			if (divWidth < imgWidth) { // 이미지 넓이가 더 크면
				imgWidth = divWidth * ratio;
				imgHeight = Math.floor(imgWidth * originalHeight / originalWidth);
			}
			if (divHeight > imgHeight) { // 이미지 높이가 작으면
				imgTop += getRandomInteger(0, divHeight - imgHeight);
			}
			if (divWidth > imgWidth) { // 이미지 넓이가 작으면
				imgLeft += getRandomInteger(0, divWidth - imgWidth);
			}
			//console.log("position", imgWidth, imgHeight, imgLeft, imgTop);
			return {
				width: imgWidth,
				height: imgHeight,
				left: imgLeft,
				top: imgTop
			};
		},
		shake: function() {
//			$("#displayMethod").val(0).trigger("click");
			image.defocus();
			$(IMAGE_DIV).children().each(function() {
				if (getRandomBoolean()) {
					$(this).appendTo($(IMAGE_DIV));
				}
				$(this).animate(
					image.position($(IMAGE_DIV).width(), $(IMAGE_DIV).height(), $(this).data("data").width, $(this).data("data").height, 0, $(IMAGE_DIV).offset().top, .9)		
				).data("tile", false);
			});
			image.setLastInfo();
		},
		tile: function() {
//			$("#displayMethod").val(1).trigger("click");
			image.defocus();
			var boxWidth = $(IMAGE_DIV).width() / 6, boxHeight = ($(IMAGE_DIV).height() - TOP_MARGIN) / 5;
			$(IMAGE_DIV).children().each(function(index) {
				var position = image.position(boxWidth, boxHeight, $(this).data("data").width, $(this).data("data").height, 0, 0, 1);
				position.left =         (index % 6) * boxWidth  + (boxWidth  - position.width)  / 2;
				position.top  = parseInt(index / 6) * boxHeight + (boxHeight - position.height) / 2 + TOP_MARGIN;
				$(this).animate(position).rotateR(0).data("tile", true);
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
			$(".container-tablet").toggleClass("label-black", status);
			$(".progress-bar, .label, code", ".container-tablet").toggleClass("label-black", status);
			$(".modal-content", "#configModal").toggleClass("label-black", status);
			image.resize();
		},
		resize: function() {
			$(IMAGE_DIV).height($(window).height() - TOP_MARGIN);
		},
		nav: function(signal) {
			console.log("nav signal", signal);
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
				case 69: // key : e
					image.empty();
					break;
				case 16: // numpad : -
					image.tile();
					break;
				case 17: // numpad : +
					image.shake();
					break;
				default :
					config.nav(signal);
			}
		},
		eventListener: function() {
			$(window).on("resize", image.resize);

			// for #navDiv
			$(".delete-image").on("click", image.remove);
			$(".popup-image" ).on("click", image.popup);
			
			// for #imageDiv
			$(IMAGE_DIV).navEvent(image.nav).off("mouseup"); // remove for draggable event
		},
		start: function() {
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
				
				imageIndex = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, 0));
				if (imageIndex < 0 || imageIndex >= imageCount)
					imageIndex = getRandomInteger(0, imageCount-1);

				coverIndex = parseInt(getLocalStorageItem(THUMBNAMILS_COVER_INDEX, 0));
				if (coverIndex < 0 || coverIndex >= coverCount)
					coverIndex = getRandomInteger(0, coverCount-1);

				image.next();
			});
			// play engine
			timerEngine.init(image.next, playInterval.value, "#progressWrapper", {width: 136, margin: 0}, "Play", image.playCallback);
			image.resize();
		}
	};

	return {
		init: function() {
			config.eventListener();
			config.initiate();
			image.eventListener();
			image.start();
		}
	};
}());

$.fn.rotateR = function(degree) {
	return this.each(function() {
		$(this).rotate(getRandomInteger(-degree, degree), getRandomInteger(1, 3), "cubic-bezier(0.6, -0.28, 0.74, 0.05)", .3);
	});
};
