/**
 *image/tablet module
 */
var tablet = (function() {

	var IMAGE_DIV = "#imageDiv",
		TOP_MARGIN = 30,
		selectedItemUrl = "", selectedItemTitle = "",
		imageIndex = 0,	imageCount = 0,	imageNameMap = [], imageIndexMap = [],
		coverIndex = 0, coverCount = 0,	coverNameMap = [], coverIndexMap = [];
	
	/**
	 * main
	 */
	var	fn = {
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
						fn.setLastInfo();
					});
				}
				else {
					$lastImage.hide(effectHideTypes, {}, 500, function() {
						$(this).remove();
						fn.setLastInfo();
					});
				}
			}
			else {
				$lastImage.remove();
				fn.setLastInfo();
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
		next: function(showEffect, showOptions, showDuration) {
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
				fn.removeOld();
				fn.defocus(); // 기존 이미지의 테두리 초기화
				
				if (displayMethod.value == 1) {
					fn.tile();
				}

				var $image = $("<img>", {
					src: preloader.src,
					"class": "img-thumbnail img-card img-card-focus " + imageTypeClass 
				}).randomBG(0.5).css({
					display: "none"
				}).css(
					fn.position($(IMAGE_DIV).width(), $(IMAGE_DIV).height(), preloader.width, preloader.height, 0, $(IMAGE_DIV).offset().top, .9)	
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
						fn.defocus();
						if (displayMethod.value == 1 && $(this).data("tile")) {
							displayMethod.value == 1 && fn.tile();
							var data = $(this).data("data");
							var position = fn.position($(IMAGE_DIV).width(), $(IMAGE_DIV).height(), data.width, data.height, 0, $(IMAGE_DIV).offset().top, .9);
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
						fn.setLastInfo();
					} 
					else if (e.which == 2) { // mouse middle
						fn.shake();
					} 
					else if (e.which == 3) { // mouse right
						// do nothing
					} 
				}).appendTo(
						$(IMAGE_DIV)
				);
				fn.setLastInfo();

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
			fn.defocus();
			$(IMAGE_DIV).children().each(function() {
				if (getRandomBoolean()) {
					$(this).appendTo($(IMAGE_DIV));
				}
				$(this).animate(
					fn.position($(IMAGE_DIV).width(), $(IMAGE_DIV).height(), $(this).data("data").width, $(this).data("data").height, 0, $(IMAGE_DIV).offset().top, .9)		
				).data("tile", false);
			});
			fn.setLastInfo();
		},
		tile: function() {
//			$("#displayMethod").val(1).trigger("click");
			fn.defocus();
			var boxWidth = $(IMAGE_DIV).width() / 6, boxHeight = ($(IMAGE_DIV).height() - TOP_MARGIN) / 5;
			$(IMAGE_DIV).children().each(function(index) {
				var position = fn.position(boxWidth, boxHeight, $(this).data("data").width, $(this).data("data").height, 0, 0, 1);
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
			fn.resize();
		},
		resize: function() {
			$(IMAGE_DIV).height($(window).height() - TOP_MARGIN);
		},
		nav: function(signal) {
			console.log("table.fn.nav", signal);
			switch(signal) {
				case 69: // key : e
					fn.empty();
					break;
				case 16: // Shift
					fn.tile();
					break;
				case 17: // l Ctrl
				case 25: // r Ctrl
					fn.shake();
					break;
			}
		},
		eventListener: function() {
			$(window).on("resize", fn.resize);

			// for #navDiv
			$(".delete-image").on("click", fn.remove);
			$(".popup-image" ).on("click", fn.popup);
			
			// for #imageDiv
			$(IMAGE_DIV).off("mouseup"); // remove for draggable event
		},
		init: function(data) {
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

			fn.resize();
		}
	};

	return {
		init: function() {
			// prev, next, playCallback, extraNav, containerSelector, extraEventListener, start
			config.init(IMAGE_DIV, fn.prev, fn.next, fn.playCallback, fn.nav, fn.eventListener, fn.init);
		}
	};
}());

$.fn.rotateR = function(degree) {
	return this.each(function() {
		$(this).rotate(getRandomInteger(-degree, degree), getRandomInteger(1, 3), "cubic-bezier(0.6, -0.28, 0.74, 0.05)", .3);
	});
};
