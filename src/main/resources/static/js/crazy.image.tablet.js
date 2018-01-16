/**
 *image/tablet module
 */

var tablet = (function() {

	var	TOP_MARGIN = 30;
	var IMAGE_DIV = "#imageDiv";
	var selectedItemUrl = "", selectedItemTitle = "";
	var	imageIndex = 0,	imageCount = 0,	imageNameMap = [], imageIndexMap = [];
	var	coverIndex = 0, coverCount = 0,	coverNameMap = [], coverIndexMap = [];
	var tileWidth = 0, tileHeight = 0;
	
	/**
	 * main
	 */
	var	fn = {
		nav: {
			prev: function() {
				// 다 지웠으면 끝
				if ($(IMAGE_DIV).children().length < 1)
					return;

				// 직전 이미지 삭제 및 map배열 복원
				var $prevImage = $(IMAGE_DIV).children().last();
				var prevData = $prevImage.data("data");
				if (prevData.mode == 0) {
					imageIndexMap.splice(prevData.arrayIndex, 0, prevData.imageIndex);
				}
				else {
					coverIndexMap.splice(prevData.arrayIndex, 0, prevData.imageIndex);
				}
				
				if (hideMethod.value == 0) {
					var effectHideType = $("#effectHideTypes option:selected").val();
					if (effectHideType === "own") {
						$prevImage.hide(prevData.effect, prevData.options, prevData.duration, function() {
							$(this).remove();
						});
					}
					else {
						$prevImage.hide(effectHideType, {}, 500, function() {
							$(this).remove();
						});
					}
				}
				else {
					$prevImage.remove();
				}
				fn.container.setLastInfo();
			},
			next: function(showEffect, showOptions, showDuration) {
				var currentIndex = -1;
				var imageTypeClass = "";
				if (imageSource.value == 0) { // image
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
					imageTypeClass = "img-image";
					currentIndex = imageIndexMap.splice(imageIndex, 1)[0];
					selectedItemUrl = PATH + "/image/" + currentIndex;
					selectedItemTitle = imageNameMap[currentIndex];
					setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, currentIndex);
				}
				else { // cover
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
					imageTypeClass = "img-cover";
					currentIndex = coverIndexMap.splice(coverIndex, 1)[0];
					selectedItemUrl = PATH + "/video/" + coverNameMap[currentIndex] + "/cover";
					selectedItemTitle = coverNameMap[currentIndex];
					setLocalStorageItem(THUMBNAMILS_COVER_INDEX, currentIndex);
				}
				
				var preloader = new Image();
				preloader.onload = function() {
					fn.container.removeOld();
					fn.container.defocus(); // 기존 이미지의 테두리 초기화
					
					if (displayMethod.value == 1) {
						fn.tablet.tile();
					}

					var $image = $("<img>", {
						src: preloader.src,
						"class": "img-thumbnail img-card img-card-focus " + imageTypeClass
					}).randomBG(0.5).css({
						display: "none",
						height: tileHeight,
						right: 0,
						top: tileHeight * 4 + TOP_MARGIN
					}).data("data", {
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
						fn.container.defocus();
						var isTile = $(this).data("tile");
						if (e.which == 1) { // mouse left : 선택
							if (isTile) {
							}
							else {
								$(this).appendTo($(IMAGE_DIV));
								fn.container.setLastInfo();
							}
						} 
						else if (e.which == 2) { // mouse middle : 확대/축소
							//fn.shake();
							if (isTile) {
								$(this)
									.appendTo($(IMAGE_DIV))
									.removeClass("img-card-tile")
									.animate(fn.container.position.focus($(this).data("data")))
									.data("tile", false);
								fn.container.setLastInfo();
							}
							else {
								fn.tablet.tile();
							}
						} 
						else if (e.which == 3) { // mouse right : 회전 0
							if (isTile) {
							}
							else {
								$(this).appendTo($(IMAGE_DIV));
								fn.container.setLastInfo();
							}
							$(this).addClass("rotate0");
						}
					}).appendTo(
							$(IMAGE_DIV)
					).draggable();
					
					fn.container.setLastInfo();

					var position = fn.container.position.focus(preloader);
					if (showEffect === 'throw') {
						$image.show().animate({
							left: position.left + position.width / 2, 
							top: position.top + position.height / 2
						}, {
							duration: getRandomInteger(400, 1000),
							complete: function() {
								$(this).rotateR(rotateDegree.value).animate(position);
							}
						});
					}
					else {
						$image.css(position).show(showEffect, showOptions, showDuration, function() {
							$(this).rotateR(rotateDegree.value);
						});
					}
					
				};
				preloader.src = selectedItemUrl;
			},
			event: function(signal) {
				//console.log("table.fn.nav", signal);
				switch(signal) {
					case 69: // key : e
						fn.container.empty();
						return true;
					case 16: // Shift
						fn.tablet.tile();
						return true;
					case 17: // l Ctrl
					case 25: // r Ctrl
						fn.tablet.shake();
						return true;
				}
			}
		},
		container: {
			empty: function() {
				$(IMAGE_DIV).empty();
				this.setLastInfo();
			},
			defocus: function() {
				$(".img-card", IMAGE_DIV).css({backgroundColor: "transparent"}).removeClass("img-card-focus");
			},
			setLastInfo: function() { // 새로운 마지막 이미지 설정
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
			removeOld: function() { // FIFO 오래된 이미지 지우기. 성능 때문에
				var IMAGE_DISPLAY_LIMIT = 30;
				var currentImageCount = $(IMAGE_DIV).children().length;
				var diffCount = currentImageCount - IMAGE_DISPLAY_LIMIT + 1;
				if (diffCount > 0)
					for (var i=0; i < diffCount; i++)
						$(IMAGE_DIV).children().first().remove();
			},
			position: {
				focus: function(imageData) {
					return this.calc($(IMAGE_DIV).width(), $(IMAGE_DIV).height(), imageData.width, imageData.height, 0, $(IMAGE_DIV).offset().top, .9);
				},
				tile: function(imageData) {
					return this.calc(tileWidth, tileHeight, imageData.width, imageData.height, 0, 0, 1);
				},
				calc: function(divWidth, divHeight, originalWidth, originalHeight, offsetLeft, offsetTop, ratio) {
					var imgWidth  = originalWidth;
					var imgHeight = originalHeight;
					var imgLeft   = offsetLeft;
					var imgTop    = offsetTop;
					if (divHeight < imgHeight) { // 이미지 높이가 더 크면
						imgHeight = divHeight * ratio;
						imgWidth = imgHeight * originalWidth / originalHeight;
					}
					if (divWidth < imgWidth) { // 이미지 넓이가 더 크면
						imgWidth = divWidth * ratio;
						imgHeight = imgWidth * originalHeight / originalWidth;
					}
					if (divHeight > imgHeight) { // 이미지 높이가 작으면
						imgTop += getRandomInteger(0, divHeight - imgHeight);
					}
					if (divWidth > imgWidth) { // 이미지 넓이가 작으면
						imgLeft += getRandomInteger(0, divWidth - imgWidth);
					}
					//console.log("position", imgWidth, imgHeight, imgLeft, imgTop);
					return {
						width:  Math.floor(imgWidth),
						height: Math.floor(imgHeight),
						left:   Math.floor(imgLeft),
						top:    Math.floor(imgTop)
					};
				}
			},
			playCallback: function(status) {
				$(".container-tablet, .progress-bar, .label, code, .container-tablet, .modal-content, #configModal").toggleClass("label-black", status);
			},
			resize: function() {
				$(IMAGE_DIV).height($(window).height() - TOP_MARGIN);
				tileWidth = $(IMAGE_DIV).width() / 6;
				tileHeight = ($(IMAGE_DIV).height() - TOP_MARGIN) / 5;
			}
		},
		image: {
			delete: function() {
				var data = $(".title").data("data");
				if (data.src && confirm('remove this image?\n' + data.src + "\n" + data.title)) {
					if (data.mode == 0) { // image
						restCall(data.src, {method: "DELETE", title: "this image delete"});
					}
					$("img[src='" + data.src + "']").remove();
					fn.container.setLastInfo();
				}
			},
			popup: function(e) {
				var data = $(e.target).data("data");
				if (data.mode == 0) // image
					popupImage(data.src);
				else
					fnVideoDetail(data.title);
			}
		},
		tablet: {
			shake: function() {
				fn.container.defocus();
				$(IMAGE_DIV).children().each(function() {
					if (getRandomBoolean()) {
						$(this).appendTo($(IMAGE_DIV));
					}
					var position = fn.container.position.focus($(this).data("data"));
					$(this).animate(position, {
						duration: getRandomInteger(200, 1000)
					}).data("tile", false).removeClass("img-card-tile");
				});
				fn.container.setLastInfo();
			},
			tile: function() {
				fn.container.defocus();
				$(IMAGE_DIV).children().each(function(index) {
					var position = fn.container.position.tile($(this).data("data"));
					position.left = Math.floor(        (index % 6) * tileWidth  + (tileWidth  - position.width)  / 2);
					position.top  = Math.floor(parseInt(index / 6) * tileHeight + (tileHeight - position.height) / 2 + TOP_MARGIN);
					$(this).animate(position, {
						duration: getRandomInteger(200, 1000),
						easing: getRandomBoolean() ? "easeOutBounce" : "swing"
					}).data("tile", true).addClass("img-card-tile");
				});
			}
		},
		eventListener: function() {
			$(window).on("resize", fn.container.resize);
			$(".popup-image" ).on("click", fn.image.popup);
			$(".delete-image").on("click", fn.image.delete);
			// for #imageDiv
			$(IMAGE_DIV).off("mouseup"); // remove for draggable event
		},
		init: function(data) {
			imageCount   = data['imageCount'];
			imageNameMap = data['imageNameMap'];
			coverCount   = data['coverCount'];
			coverNameMap = data['coverNameMap'];

			for (var i = 0; i < imageCount; i++)
				imageIndexMap.push(i);
			for (var i = 0; i < coverCount; i++)
				coverIndexMap.push(i);
			
			imageIndex = getLocalStorageItemInteger(THUMBNAMILS_IMAGE_INDEX, 0);
			if (imageIndex < 0 || imageIndex >= imageCount)
				imageIndex = getRandomInteger(0, imageCount-1);

			coverIndex = getLocalStorageItemInteger(THUMBNAMILS_COVER_INDEX, 0);
			if (coverIndex < 0 || coverIndex >= coverCount)
				coverIndex = getRandomInteger(0, coverCount-1);

			fn.container.resize();
		}
	};

	return {
		init: function() {
			config.init(IMAGE_DIV, fn.nav.prev, fn.nav.next, fn.container.playCallback, fn.nav.event, fn.eventListener, fn.init);
		}
	};
	
}());

$.fn.rotateR = function(degree) {
	return this.each(function() {
		/* 
		 * cubic-bezier(0.12, -0.25, 0.48, 1.17)
		 * cubic-bezier(0.6, -0.28, 0.74, 0.05)
		 */
		$(this).rotate(getRandomInteger(-degree, degree), getRandomInteger(1, 3), 
				"cubic-bezier(" + getRandom(0, 1) + ", " + getRandom(-1, 1) + ", " + getRandom(0, 1) + ", " + getRandom(-1, 1) + ")", .3);
	});
};
