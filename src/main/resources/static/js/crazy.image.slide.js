/**
 *image/slide module
 */

var slide = (function() {

	var currentIndex      = -1,
		selectedItemUrl   = "",
		selectedItemTitle = "",
		imageCount = 0,
		imageMap   = [],
		coverCount = 0,
		coverMap   = [],
		hideEffect = "fade", hideOptions = {}, hideDuration = 300;

	var	image = {
			prevNumber: function getPrevNumber() {
				return currentIndex == 0 ? image.maxCount(-1) : currentIndex - 1;
			},
			nextNumber: function getNextNumber() {
				if (nextMethod.value == 0) {
					return currentIndex == image.maxCount(-1) ? 0 : currentIndex + 1;
				}
				else {
					return getRandomInteger(0, image.maxCount(-1));
				}
			},
			maxCount: function(i) {
				i = i || 0;
				return imageSource.value == 0 ? imageCount + i : coverCount + i;
			},
			first: function() {
				image.view(0);
			},
			end: function() {
				image.view(image.maxCount(-1));
			},
			view: function(current, showEffect, showOptions, showDuration) {
				currentIndex = parseInt(current);
				
				if (imageSource.value == 0) { // image
					selectedItemUrl = PATH + "/image/" + currentIndex;
					selectedItemTitle = imageMap[currentIndex];
					setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, currentIndex);
				}
				else {
					selectedItemUrl = PATH + "/video/" + coverMap[currentIndex] + "/cover";
					selectedItemTitle = coverMap[currentIndex];
					setLocalStorageItem(THUMBNAMILS_COVER_INDEX, currentIndex);
				}
				
				if (hideMethod.value == 0) {
					var effectHideType = $("#effectHideTypes option:selected").val();
					if (effectHideType != "own") {
						hideEffect = effectHideType;
						hideDuration = 500
					}
				}
				else {
					hideEffect = "fade";
					hideDuration = 300
				}
				
				$("#imageDiv").hide(hideEffect, hideOptions, hideDuration, function() {
					$(".paging-curr").html(currentIndex);
					$(".paging-end").html(image.maxCount(-1));
					$(".title").html(selectedItemTitle);

					image.displayThumbnail();
					image.resize();
					
					$(this).css({
						backgroundImage: "url('" + selectedItemUrl + "')"
					}).show(showEffect, showOptions, showDuration);

				});
				
				console.log("slide.image.view", currentIndex, selectedItemUrl, selectedItemTitle);
			},
			resize: function() {
				$("#imageDiv").height($(window).height() - $("#thumbnailDiv").outerHeight() - 35);
			},
			displayThumbnail: function fnDisplayThumbnail() {
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
					var itemUrl = imageSource.value == 0 ? PATH + "/image/" + thumbNo : PATH + "/video/" + coverMap[thumbNo] + "/cover";

					$("<li>").append(
							$("<div>").addClass("img-thumbnail " + (thumbNo == currentIndex ? "active" : "")).css({
								backgroundImage: "url('" + itemUrl + "')"
							}).data("imgNo", thumbNo).on("click", function() {
								image.view($(this).data("imgNo"));
							})
					).appendTo($("ul#thumbnailUL"));
				}
			},
			delete: function() {
				console.log("slide.image.delete");
				if (imageSource.value == 0) { // image
					var imgSrc = selectedItemUrl;
					if (confirm('Delete this image\n' + imgSrc)) {
						restCall(imgSrc, {method: "DELETE", title: "this image delete"});
						console.log("slide.image.delete call");
						fn.next();
					}
				}
			},
			popup: function() {
				if (imageSource.value == 0) { // image
					popupImage(selectedItemUrl);
				}
				else {
					fnVideoDetail(coverMap[currentIndex]);
				}
			}
	};
	
	var fn = {
			prev: function(showEffect, showOptions, showDuration) {
				image.view(image.prevNumber(), showEffect, showOptions, showDuration);
			},
			next: function(showEffect, showOptions, showDuration) {
				image.view(image.nextNumber(), showEffect, showOptions, showDuration);
			},
			playCallback: function(status) {
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
				image.resize();
			},
			nav: function(signal) {
			},
			eventListener: function() {
				$(window).on("resize", image.resize);
				
				// for #navDiv
				$(".paging-first").on("click", image.first);
				$(".paging-end"  ).on("click", image.end);
				$(".delete-image").on("click", image.delete);
				$(".popup-image" ).on("click", image.popup);
			},
			init: function(data) {
				imageCount = data['imageCount'];
				imageMap   = data['imageNameMap'];
				coverCount = data['coverCount'];
				coverMap   = data['coverNameMap'];

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

				image.resize();
			}
	};
	
	return {
		init: function() {
			config.init("#imageDiv", fn.prev, fn.next, fn.playCallback, fn.nav, fn.eventListener, fn.init);
		}
	};
	
}());

